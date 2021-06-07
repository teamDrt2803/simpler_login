#import "SimplerLoginPlugin.h"
#if __has_include(<simpler_login/simpler_login-Swift.h>)
#import <simpler_login/simpler_login-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "simpler_login-Swift.h"
#endif

@implementation SimplerLoginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSimplerLoginPlugin registerWithRegistrar:registrar];
}
@end
