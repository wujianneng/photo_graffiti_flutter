#import "PhotograffitiflutterPlugin.h"
#if __has_include(<photograffitiflutter/photograffitiflutter-Swift.h>)
#import <photograffitiflutter/photograffitiflutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "photograffitiflutter-Swift.h"
#endif

@implementation PhotograffitiflutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPhotograffitiflutterPlugin registerWithRegistrar:registrar];
}
@end
