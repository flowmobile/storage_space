import Flutter
import Foundation
import UIKit

public class SwiftStorageSpacePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "storage_space", binaryMessenger: registrar.messenger())
        let instance = SwiftStorageSpacePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getFreeSpace" {
            do {
                let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())

                return result(attributes[FileAttributeKey.systemFreeSize] as! Int64)
            } catch {
                return result("")
            }
        } else if call.method == "getTotalSpace" {
            do {
                let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
                return result(attributes[FileAttributeKey.systemSize] as! Int64)
            } catch {
                return result("")
            }
        }
    }
}
