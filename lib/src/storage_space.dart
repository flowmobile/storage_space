import 'dart:async';
import 'package:flutter/services.dart';

class StorageSpace {
  /// Free space in Bytes
  int free;

  /// Used space in Bytes
  late int used;

  /// Total space in Bytes
  int total;

  /// Usage as a percentage
  late int usagePercent;

  /// Usage as a number from 0...1
  late double usageValue;

  /// Free space in a Human Readable format
  late String freeSize;

  /// Used space in a Human Readable format
  late String usedSize;

  /// Total space in a Human Readable format
  late String totalSize;

  /// Threshold in Bytes for showing `lowOnSpace`
  late int lowOnSpaceThreshold;

  /// Flag to show if the free space is below the lowOnSpaceThreshold
  late bool lowOnSpace;

  /// Number of digits to use for the Human Readable values
  int fractionDigits;

  StorageSpace({
    required this.free,
    required this.total,
    required this.lowOnSpaceThreshold,
    required this.fractionDigits,
  }) {
    used = total - free;
    freeSize = _toHuman(free, fractionDigits);
    totalSize = _toHuman(total, fractionDigits);
    usedSize = _toHuman(used, fractionDigits);
    usageValue = used / total;
    usagePercent = (usageValue * 100).round();
    lowOnSpace = free <= lowOnSpaceThreshold;
  }
}

/// Returns the storage space for the device
Future<StorageSpace> getStorageSpace({
  /// Threshold in Bytes for showing `lowOnSpace`
  required int lowOnSpaceThreshold,

  /// Number of digits to use for the Human Readable values
  required int fractionDigits,
}) async {
  int free = await _invokeMethodInt('getFreeSpace');
  int total = await _invokeMethodInt('getTotalSpace');
  return StorageSpace(
    free: free,
    total: total,
    lowOnSpaceThreshold: lowOnSpaceThreshold,
    fractionDigits: fractionDigits,
  );
}

class AppStorageUsage {
  /// Size of the app itself (the installed app bundle / APK) in Bytes
  int app;

  /// Size of the app's data in Bytes, including the cache
  int data;

  /// Size of the app's cache in Bytes (already counted in `data`)
  int cache;

  /// Total space used by the app (`app` + `data`) in Bytes
  late int total;

  /// App size in a Human Readable format
  late String appSize;

  /// Data size in a Human Readable format
  late String dataSize;

  /// Cache size in a Human Readable format
  late String cacheSize;

  /// Total size in a Human Readable format
  late String totalSize;

  /// Number of digits to use for the Human Readable values
  int fractionDigits;

  AppStorageUsage({
    required this.app,
    required this.data,
    required this.cache,
    required this.fractionDigits,
  }) {
    total = app + data;
    appSize = _toHuman(app, fractionDigits);
    dataSize = _toHuman(data, fractionDigits);
    cacheSize = _toHuman(cache, fractionDigits);
    totalSize = _toHuman(total, fractionDigits);
  }
}

/// Returns the storage space used by this app
///
/// * Android: matches Settings > Apps > Storage (API 26+), an estimate before that
/// * iOS: the app bundle plus the app's sandbox, close to Settings > iPhone Storage
Future<AppStorageUsage> getAppStorageUsage({
  /// Number of digits to use for the Human Readable values
  required int fractionDigits,
}) async {
  Map<String, int> usage = await _invokeMethodIntMap('getAppStorageUsage');
  return AppStorageUsage(
    app: usage['app']!,
    data: usage['data']!,
    cache: usage['cache']!,
    fractionDigits: fractionDigits,
  );
}

/// Makes a platform method call and returns an integer
MethodChannel _channel = const MethodChannel('storage_space');
Future<int> _invokeMethodInt(String method) async {
  var result = await _channel.invokeMethod(method);
  return int.parse(result.toString());
}

/// Makes a platform method call and returns a map of integers
Future<Map<String, int>> _invokeMethodIntMap(String method) async {
  var result = await _channel.invokeMapMethod<String, Object>(method);
  return result!.map((key, value) => MapEntry(key, int.parse(value.toString())));
}

/// Units used for the `_toHuman` method
List<String> _units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

/// Returns bytes as a human readable string
///
/// Trailing 0's are automatically trimmed
///
/// * 102 B
/// * 43 MB
/// * 21.1 GB
String _toHuman(int bytes, int fractionDigits) {
  int multiplier = 1024;
  int lowerBoundary = 1;
  int upperBoundary = multiplier;
  for (var i = 0; i < _units.length; i++) {
    if (bytes < upperBoundary) {
      String fixed = (bytes / lowerBoundary).toStringAsFixed(fractionDigits);
      return '${_trimTrailingZeros(fixed)} ${_units[i]}';
    }
    lowerBoundary = upperBoundary;
    upperBoundary *= multiplier;
  }
  return 'Huge';
}

/// Trims trailing zeros (and possibly the dot) from a string
///
/// Whole numbers (no dot) are returned untouched, so `10` stays `10`
String _trimTrailingZeros(String value) {
  if (!value.contains('.')) return value;
  RegExp regex = new RegExp(r"\.?0+$");
  return value.replaceAll(regex, '');
}
