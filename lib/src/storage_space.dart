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

/// Makes a platform method call and returns an integer
MethodChannel _channel = const MethodChannel('storage_space');
Future<int> _invokeMethodInt(String method) async {
  var result = await _channel.invokeMethod(method);
  return int.parse(result.toString());
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
String _trimTrailingZeros(String value) {
  RegExp regex = new RegExp(r"\.?0+$");
  return value.replaceAll(regex, '');
}
