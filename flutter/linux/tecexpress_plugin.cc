#include "include/tecexpress/tecexpress_plugin.h"
#include <gtk/gtk.h>
#include <gio/gio.h>
#include <glib/gstdio.h>
#include <cstring>

struct _TecexpressPlugin {
  GObject parent_instance;
  FlMethodChannel* channel;
  GtkWidget* view;
  FlValue* targets;
  GHashTable* owned;
  GHashTable* outputs;
  GtkFileChooserNative* dialog;
  FlMethodCall* pending;
  gboolean saving;
  gint next_token;
};
G_DEFINE_TYPE(TecexpressPlugin, tecexpress_plugin, g_object_get_type())

static void respond(FlMethodCall* call, FlValue* value) {
  g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  fl_method_call_respond(call, response, nullptr);
}
static void fail(FlMethodCall* call, const gchar* message) {
  g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_error_response_new("file_error", message, nullptr));
  fl_method_call_respond(call, response, nullptr);
}
static void remove_owned(gpointer path) {
  g_unlink(static_cast<const gchar*>(path));
  g_autofree gchar* parent = g_path_get_dirname(static_cast<const gchar*>(path));
  g_rmdir(parent); g_free(path);
}
static FlValue* take_file(TecexpressPlugin* self, GFile* file, GError** error) {
  if (g_file_query_file_type(file, G_FILE_QUERY_INFO_NONE, nullptr) == G_FILE_TYPE_DIRECTORY) {
    g_set_error_literal(error, G_IO_ERROR, G_IO_ERROR_NOT_SUPPORTED, "Directory drops are not supported"); return nullptr;
  }
  g_autofree gchar* dir = g_dir_make_tmp("tecexpress-XXXXXX", error);
  if (!dir) return nullptr;
  g_autofree gchar* name = g_file_get_basename(file);
  g_autofree gchar* path = g_build_filename(dir, name, nullptr);
  g_autoptr(GFile) destination = g_file_new_for_path(path);
  if (!g_file_copy(file, destination, G_FILE_COPY_NONE, nullptr, nullptr, nullptr, error)) { g_rmdir(dir); return nullptr; }
  g_hash_table_add(self->owned, g_strdup(path));
  FlValue* value = fl_value_new_map();
  fl_value_set_string_take(value, "path", fl_value_new_string(path));
  fl_value_set_string_take(value, "name", fl_value_new_string(name));
  fl_value_set_string_take(value, "owned", fl_value_new_bool(TRUE));
  return value;
}
static FlValue* target(TecexpressPlugin* self, gdouble x, gdouble y) {
  for (size_t i = fl_value_get_length(self->targets); i > 0; --i) {
    FlValue* t = fl_value_get_list_value(self->targets, i - 1);
    auto number = [t](const char* key) { FlValue* v = fl_value_lookup_string(t, key); return fl_value_get_type(v) == FL_VALUE_TYPE_FLOAT ? fl_value_get_float(v) : static_cast<double>(fl_value_get_int(v)); };
    if (x >= number("left") && x < number("right") && y >= number("top") && y < number("bottom")) return t;
  }
  return nullptr;
}
static void dialog_response(GtkNativeDialog* dialog, gint response, gpointer user_data) {
  auto self = TECEXPRESS_PLUGIN(user_data);
  auto call = self->pending; self->pending = nullptr;
  g_autoptr(GError) error = nullptr;
  if (response != GTK_RESPONSE_ACCEPT) {
    if (self->saving) respond(call, nullptr);
    else { g_autoptr(FlValue) empty = fl_value_new_list(); respond(call, empty); }
  } else if (self->saving) {
    g_autoptr(GFile) file = gtk_file_chooser_get_file(GTK_FILE_CHOOSER(dialog));
    auto output = g_file_replace(file, nullptr, FALSE, G_FILE_CREATE_NONE, nullptr, &error);
    if (!output) fail(call, error->message);
    else {
      g_autofree gchar* token = g_strdup_printf("%d", ++self->next_token);
      g_hash_table_insert(self->outputs, g_strdup(token), output);
      g_autoptr(FlValue) value = fl_value_new_string(token); respond(call, value);
    }
  } else {
    GSList* files = gtk_file_chooser_get_files(GTK_FILE_CHOOSER(dialog));
    g_autoptr(FlValue) list = fl_value_new_list();
    for (GSList* it = files; it; it = it->next) {
      FlValue* value = take_file(self, G_FILE(it->data), &error);
      if (!value) break;
      fl_value_append_take(list, value);
    }
    g_slist_free_full(files, g_object_unref);
    if (error) fail(call, error->message); else respond(call, list);
  }
  gtk_native_dialog_destroy(dialog); g_clear_object(&self->dialog); g_object_unref(call);
}
static void method_call(FlMethodChannel*, FlMethodCall* call, gpointer user_data) {
  auto self = TECEXPRESS_PLUGIN(user_data);
  const gchar* method = fl_method_call_get_name(call);
  FlValue* args = fl_method_call_get_args(call);
  g_autoptr(GError) error = nullptr;
  if (strcmp(method, "targets") == 0) {
    fl_value_unref(self->targets); self->targets = fl_value_ref(args); respond(call, nullptr);
  } else if (strcmp(method, "pick") == 0 || strcmp(method, "beginSave") == 0) {
    if (self->pending) { fail(call, "Another file dialog is open"); return; }
    self->saving = strcmp(method, "beginSave") == 0;
    GtkWidget* parent = gtk_widget_get_toplevel(self->view);
    self->dialog = gtk_file_chooser_native_new(self->saving ? "Save file" : "Select files",
      GTK_IS_WINDOW(parent) ? GTK_WINDOW(parent) : nullptr,
      self->saving ? GTK_FILE_CHOOSER_ACTION_SAVE : GTK_FILE_CHOOSER_ACTION_OPEN,
      self->saving ? "Save" : "Open", "Cancel");
    auto chooser = GTK_FILE_CHOOSER(self->dialog);
    if (self->saving) {
      gtk_file_chooser_set_current_name(chooser, fl_value_get_string(fl_value_lookup_string(args, "name")));
      gtk_file_chooser_set_do_overwrite_confirmation(chooser, TRUE);
    } else {
      gtk_file_chooser_set_select_multiple(chooser, fl_value_get_bool(fl_value_lookup_string(args, "multiple")));
      FlValue* extensions = fl_value_lookup_string(args, "extensions");
      if (fl_value_get_length(extensions)) {
        auto filter = gtk_file_filter_new(); gtk_file_filter_set_name(filter, "Files");
        for (size_t i = 0; i < fl_value_get_length(extensions); ++i) {
          g_autofree gchar* pattern = g_strconcat("*.", fl_value_get_string(fl_value_get_list_value(extensions, i)), nullptr);
          gtk_file_filter_add_pattern(filter, pattern);
        }
        gtk_file_chooser_add_filter(chooser, filter);
      }
    }
    self->pending = FL_METHOD_CALL(g_object_ref(call));
    g_signal_connect(self->dialog, "response", G_CALLBACK(dialog_response), self);
    gtk_native_dialog_show(GTK_NATIVE_DIALOG(self->dialog));
  } else if (strcmp(method, "release") == 0) {
    g_hash_table_remove(self->owned, fl_value_get_string(fl_value_lookup_string(args, "path"))); respond(call, nullptr);
  } else if (strcmp(method, "writeSave") == 0) {
    const auto token = fl_value_get_string(fl_value_lookup_string(args, "token"));
    auto output = G_OUTPUT_STREAM(g_hash_table_lookup(self->outputs, token));
    FlValue* bytes = fl_value_lookup_string(args, "bytes");
    if (!output) { fail(call, "Unknown save handle"); return; }
    if (!g_output_stream_write_all(output, fl_value_get_uint8_list(bytes), fl_value_get_length(bytes), nullptr, nullptr, &error)) fail(call, error->message);
    else respond(call, nullptr);
  } else if (strcmp(method, "finishSave") == 0 || strcmp(method, "abortSave") == 0) {
    const auto token = fl_value_get_string(fl_value_lookup_string(args, "token"));
    auto output = G_OUTPUT_STREAM(g_hash_table_lookup(self->outputs, token));
    if (output && !g_output_stream_close(output, nullptr, &error)) fail(call, error->message); else respond(call, nullptr);
    g_hash_table_remove(self->outputs, token);
  } else {
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(call, response, nullptr);
  }
}
static gboolean drag_motion(GtkWidget*, GdkDragContext* context, gint x, gint y, guint time, gpointer user_data) {
  auto self = TECEXPRESS_PLUGIN(user_data);
  gdk_drag_status(context, target(self, x, y) ? GDK_ACTION_COPY : static_cast<GdkDragAction>(0), time);
  return TRUE;
}
static void drag_data(GtkWidget*, GdkDragContext* context, gint x, gint y, GtkSelectionData* selection, guint info, guint time, gpointer user_data) {
  auto self = TECEXPRESS_PLUGIN(user_data);
  FlValue* t = target(self, x, y);
  if (!t) { gtk_drag_finish(context, FALSE, FALSE, time); return; }
  g_auto(GStrv) uris = nullptr;
  g_autoptr(GDBusConnection) bus = nullptr;
  g_autoptr(GError) error = nullptr;
  g_autofree gchar* portal_key = nullptr;
  if (info == 1) {
    const auto bytes = gtk_selection_data_get_data(selection);
    const auto size = gtk_selection_data_get_length(selection);
    if (size <= 0) { gtk_drag_finish(context, FALSE, FALSE, time); return; }
    portal_key = g_strndup(reinterpret_cast<const gchar*>(bytes), static_cast<gsize>(size));
    g_strstrip(portal_key);
    bus = g_bus_get_sync(G_BUS_TYPE_SESSION, nullptr, &error);
    if (bus) {
      GVariantBuilder options; g_variant_builder_init(&options, G_VARIANT_TYPE_VARDICT);
      g_autoptr(GVariant) reply = g_dbus_connection_call_sync(bus, "org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop",
        "org.freedesktop.portal.FileTransfer", "RetrieveFiles", g_variant_new("(sa{sv})", portal_key, &options), G_VARIANT_TYPE("(as)"),
        G_DBUS_CALL_FLAGS_NONE, 10000, nullptr, &error);
      if (reply) g_variant_get(reply, "(^as)", &uris);
    }
  } else { uris = gtk_selection_data_get_uris(selection); }
  g_autoptr(FlValue) files = fl_value_new_list();
  if (uris && !error) {
    for (gchar** uri = uris; *uri; ++uri) {
      g_autoptr(GFile) file = g_file_new_for_commandline_arg(*uri);
      FlValue* value = take_file(self, file, &error);
      if (!value) break;
      fl_value_append_take(files, value);
    }
  }
  if (bus && portal_key) {
    g_dbus_connection_call(bus, "org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop", "org.freedesktop.portal.FileTransfer",
      "StopTransfer", g_variant_new("(s)", portal_key), nullptr, G_DBUS_CALL_FLAGS_NONE, -1, nullptr, nullptr, nullptr);
  }
  const gboolean success = !error && fl_value_get_length(files) > 0;
  if (success) {
    g_autoptr(FlValue) payload = fl_value_new_map();
    fl_value_set_string_take(payload, "x", fl_value_new_float(x)); fl_value_set_string_take(payload, "y", fl_value_new_float(y));
    fl_value_set_string_take(payload, "viewId", fl_value_ref(fl_value_lookup_string(t, "viewId")));
    fl_value_set_string_take(payload, "files", fl_value_ref(files));
    fl_method_channel_invoke_method(self->channel, "drop", payload, nullptr, nullptr, nullptr);
  }
  gtk_drag_finish(context, success, FALSE, time);
}
static void tecexpress_plugin_dispose(GObject* object) {
  auto self = TECEXPRESS_PLUGIN(object);
  if (self->view) { g_signal_handlers_disconnect_by_data(self->view, self); gtk_drag_dest_unset(self->view); g_object_remove_weak_pointer(G_OBJECT(self->view), reinterpret_cast<gpointer*>(&self->view)); self->view = nullptr; }
  if (self->pending) { fail(self->pending, "Plugin detached"); g_clear_object(&self->pending); }
  if (self->dialog) { gtk_native_dialog_destroy(GTK_NATIVE_DIALOG(self->dialog)); g_clear_object(&self->dialog); }
  g_clear_object(&self->channel);
  if (self->targets) { fl_value_unref(self->targets); self->targets = nullptr; }
  g_clear_pointer(&self->owned, g_hash_table_unref); g_clear_pointer(&self->outputs, g_hash_table_unref);
  G_OBJECT_CLASS(tecexpress_plugin_parent_class)->dispose(object);
}
static void tecexpress_plugin_class_init(TecexpressPluginClass* klass) { G_OBJECT_CLASS(klass)->dispose = tecexpress_plugin_dispose; }
static void tecexpress_plugin_init(TecexpressPlugin* self) {
  self->targets = fl_value_new_list();
  self->owned = g_hash_table_new_full(g_str_hash, g_str_equal, remove_owned, nullptr);
  self->outputs = g_hash_table_new_full(g_str_hash, g_str_equal, g_free, g_object_unref);
}
void tecexpress_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  auto self = TECEXPRESS_PLUGIN(g_object_new(tecexpress_plugin_get_type(), nullptr));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->channel = fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar), "tecexpress/files", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->channel, method_call, g_object_ref(self), g_object_unref);
  self->view = GTK_WIDGET(fl_plugin_registrar_get_view(registrar));
  g_object_add_weak_pointer(G_OBJECT(self->view), reinterpret_cast<gpointer*>(&self->view));
  GtkTargetEntry entries[] = {{const_cast<gchar*>("application/vnd.portal.filetransfer"), 0, 1}, {const_cast<gchar*>("text/uri-list"), 0, 2}};
  gtk_drag_dest_set(self->view, GTK_DEST_DEFAULT_DROP, entries, 2, GDK_ACTION_COPY);
  g_signal_connect(self->view, "drag-motion", G_CALLBACK(drag_motion), self);
  g_signal_connect(self->view, "drag-data-received", G_CALLBACK(drag_data), self);
  g_object_unref(self);
}
