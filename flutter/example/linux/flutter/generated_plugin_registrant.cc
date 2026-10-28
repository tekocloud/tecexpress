//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <tecexpress/tecexpress_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) tecexpress_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TecexpressPlugin");
  tecexpress_plugin_register_with_registrar(tecexpress_registrar);
}
