#ifndef FLUTTER_PLUGIN_TECEXPRESS_PLUGIN_H_
#define FLUTTER_PLUGIN_TECEXPRESS_PLUGIN_H_
#include <flutter_linux/flutter_linux.h>
G_BEGIN_DECLS
#ifdef FLUTTER_PLUGIN_IMPL
#define TECEXPRESS_EXPORT __attribute__((visibility("default")))
#else
#define TECEXPRESS_EXPORT
#endif
G_DECLARE_FINAL_TYPE(TecexpressPlugin, tecexpress_plugin, TECEXPRESS, PLUGIN, GObject)
TECEXPRESS_EXPORT void tecexpress_plugin_register_with_registrar(FlPluginRegistrar* registrar);
G_END_DECLS
#endif
