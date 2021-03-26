#import "StorageSpacePlugin.h"
#if __has_include(<storage_space/storage_space-Swift.h>)
#import <storage_space/storage_space-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "storage_space-Swift.h"
#endif

@implementation StorageSpacePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftStorageSpacePlugin registerWithRegistrar:registrar];
}
@end
