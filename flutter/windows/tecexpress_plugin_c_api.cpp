#include "include/tecexpress/tecexpress_plugin_c_api.h"
#include <flutter/plugin_registrar_windows.h>
void RegisterTecexpress(flutter::PluginRegistrarWindows* registrar);
void TecexpressPluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
  RegisterTecexpress(flutter::PluginRegistrarManager::GetInstance()->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
