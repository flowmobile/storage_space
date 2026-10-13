import Flutter
import Foundation
import UIKit

public class StorageSpacePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "storage_space", binaryMessenger: registrar.messenger())
        let instance = StorageSpacePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getFreeSpace":
            do {
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let resourceValues = try documentDirectory.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
                    if let freeSpace = resourceValues.volumeAvailableCapacityForImportantUsage {
                        return result(freeSpace)
                    }
                }
                result(FlutterError(code: "NO_SPACE_INFO",
                                    message: "Could not get free space info",
                                    details: nil))
            } catch {
                result(FlutterError(code: "ERROR",
                                    message: error.localizedDescription,
                                    details: nil))
            }
        case "getTotalSpace":
            do {
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let resourceValues = try documentDirectory.resourceValues(forKeys: [.volumeTotalCapacityKey])
                    if let totalSpace = resourceValues.volumeTotalCapacity {
                        return result(totalSpace)
                    }
                }
                result(FlutterError(code: "NO_SPACE_INFO",
                                    message: "Could not get total space info",
                                    details: nil))
            } catch {
                result(FlutterError(code: "ERROR",
                                    message: error.localizedDescription,
                                    details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
