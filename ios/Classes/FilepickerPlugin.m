#import "FilepickerPlugin.h"
#if __has_include(<filepicker/filepicker-Swift.h>)
#import <filepicker/filepicker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "filepicker-Swift.h"
#endif

@implementation FilepickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFilepickerPlugin registerWithRegistrar:registrar];
}
@end
