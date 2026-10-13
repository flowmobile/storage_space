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
        case "getAppStorageUsage":
            // Walking the app's directories can be slow, so keep it off the main thread
            DispatchQueue.global(qos: .utility).async {
                let usage = StorageSpacePlugin.appStorageUsage()
                DispatchQueue.main.async {
                    result(usage)
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Storage used by this app in bytes, close to Settings > General > iPhone Storage
    ///
    /// "data" includes "cache", and "app" + "data" is the total
    private static func appStorageUsage() -> [String: Int64] {
        let fileManager = FileManager.default
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return [
            "app": sizeOf(Bundle.main.bundleURL),
            "data": sizeOf(URL(fileURLWithPath: NSHomeDirectory())),
            "cache": caches.reduce(0) { $0 + sizeOf($1) } + sizeOf(fileManager.temporaryDirectory),
        ]
    }

    /// Total allocated size of the files in a directory tree (symlinks are not followed)
    private static func sizeOf(_ url: URL) -> Int64 {
        let keys: [URLResourceKey] = [.isRegularFileKey, .totalFileAllocatedSizeKey]
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
            return 0
        }
        var size: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: Set(keys)),
                  values.isRegularFile == true else {
                continue
            }
            size += Int64(values.totalFileAllocatedSize ?? 0)
        }
        return size
    }
}
