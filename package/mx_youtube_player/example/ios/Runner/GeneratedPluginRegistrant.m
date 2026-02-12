//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_volume_controller/FlutterVolumeControllerPlugin.h>)
#import <flutter_volume_controller/FlutterVolumeControllerPlugin.h>
#else
@import flutter_volume_controller;
#endif

#if __has_include(<screen_brightness_ios/ScreenBrightnessIosPlugin.h>)
#import <screen_brightness_ios/ScreenBrightnessIosPlugin.h>
#else
@import screen_brightness_ios;
#endif

#if __has_include(<url_launcher_ios/URLLauncherPlugin.h>)
#import <url_launcher_ios/URLLauncherPlugin.h>
#else
@import url_launcher_ios;
#endif

#if __has_include(<webview_flutter_wkwebview/WebViewFlutterPlugin.h>)
#import <webview_flutter_wkwebview/WebViewFlutterPlugin.h>
#else
@import webview_flutter_wkwebview;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterVolumeControllerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterVolumeControllerPlugin"]];
  [ScreenBrightnessIosPlugin registerWithRegistrar:[registry registrarForPlugin:@"ScreenBrightnessIosPlugin"]];
  [URLLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"URLLauncherPlugin"]];
  [WebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"WebViewFlutterPlugin"]];
}

@end
