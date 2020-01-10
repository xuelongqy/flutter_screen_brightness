#import "FlutterScreenBrightnessPlugin.h"
#if __has_include(<flutter_screen_brightness/flutter_screen_brightness-Swift.h>)
#import <flutter_screen_brightness/flutter_screen_brightness-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_screen_brightness-Swift.h"
#endif

@implementation FlutterScreenBrightnessPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterScreenBrightnessPlugin registerWithRegistrar:registrar];
}
@end
