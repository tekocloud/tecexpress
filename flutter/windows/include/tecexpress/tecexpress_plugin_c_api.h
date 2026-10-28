#ifndef FLUTTER_PLUGIN_TECEXPRESS_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_TECEXPRESS_PLUGIN_C_API_H_
#include <flutter_plugin_registrar.h>
#ifdef FLUTTER_PLUGIN_IMPL
#define TECEXPRESS_EXPORT __declspec(dllexport)
#else
#define TECEXPRESS_EXPORT __declspec(dllimport)
#endif
#ifdef __cplusplus
extern "C" {
#endif
TECEXPRESS_EXPORT void TecexpressPluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar);
#ifdef __cplusplus
}
#endif
#endif
