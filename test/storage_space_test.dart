import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage_space/storage_space.dart';

const int kb = 1024;
const int mb = 1024 * kb;
const int gb = 1024 * mb;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('storage_space');

  void mockChannel(Map<String, Object?> responses) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (!responses.containsKey(call.method)) {
        throw MissingPluginException();
      }
      return responses[call.method];
    });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('getStorageSpace', () {
    test('reads free and total space from the platform', () async {
      mockChannel({'getFreeSpace': 16 * gb, 'getTotalSpace': 64 * gb});

      final space = await getStorageSpace(
        lowOnSpaceThreshold: 2 * gb,
        fractionDigits: 1,
      );

      expect(space.free, 16 * gb);
      expect(space.total, 64 * gb);
      expect(space.used, 48 * gb);
      expect(space.usageValue, 0.75);
      expect(space.usagePercent, 75);
      expect(space.freeSize, '16 GB');
      expect(space.usedSize, '48 GB');
      expect(space.totalSize, '64 GB');
      expect(space.lowOnSpace, isFalse);
    });

    test('propagates a missing platform implementation', () async {
      mockChannel({});

      expect(
        getStorageSpace(lowOnSpaceThreshold: 0, fractionDigits: 1),
        throwsA(isA<MissingPluginException>()),
      );
    });
  });

  group('getAppStorageUsage', () {
    test('reads app, data and cache sizes from the platform', () async {
      mockChannel({
        'getAppStorageUsage': {
          'app': 48 * mb,
          'data': (1.5 * gb).round(),
          'cache': 200 * mb,
        },
      });

      final usage = await getAppStorageUsage(fractionDigits: 1);

      expect(usage.app, 48 * mb);
      expect(usage.data, (1.5 * gb).round());
      expect(usage.cache, 200 * mb);
      expect(usage.total, 48 * mb + (1.5 * gb).round());
      expect(usage.appSize, '48 MB');
      expect(usage.dataSize, '1.5 GB');
      expect(usage.cacheSize, '200 MB');
      expect(usage.totalSize, '1.5 GB');
    });

    test('propagates platform errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        throw PlatformException(code: 'APP_USAGE_ERROR');
      });

      expect(
        getAppStorageUsage(fractionDigits: 1),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('StorageSpace', () {
    StorageSpace space({
      required int free,
      int total = 64 * gb,
      int lowOnSpaceThreshold = 2 * gb,
      int fractionDigits = 1,
    }) =>
        StorageSpace(
          free: free,
          total: total,
          lowOnSpaceThreshold: lowOnSpaceThreshold,
          fractionDigits: fractionDigits,
        );

    test('lowOnSpace is true when free space is at or below the threshold', () {
      expect(space(free: 2 * gb + 1).lowOnSpace, isFalse);
      expect(space(free: 2 * gb).lowOnSpace, isTrue);
      expect(space(free: 2 * gb - 1).lowOnSpace, isTrue);
    });

    test('human readable sizes pick the right unit', () {
      expect(space(free: 102).freeSize, '102 B');
      expect(space(free: kb).freeSize, '1 KB');
      expect(space(free: 43 * mb).freeSize, '43 MB');
      expect(space(free: (21.1 * gb).round()).freeSize, '21.1 GB');
      expect(space(free: 1536 * gb, total: 2048 * gb).freeSize, '1.5 TB');
    });

    test('human readable sizes trim trailing zeros after the decimal point', () {
      expect(space(free: 10 * gb, fractionDigits: 2).freeSize, '10 GB');
      expect(space(free: (10.5 * gb).round(), fractionDigits: 2).freeSize,
          '10.5 GB');
    });

    test('human readable sizes keep whole numbers intact with no fraction digits',
        () {
      expect(space(free: 10, fractionDigits: 0).freeSize, '10 B');
      expect(space(free: 100 * mb, fractionDigits: 0).freeSize, '100 MB');
      expect(space(free: 20 * gb, fractionDigits: 0).freeSize, '20 GB');
    });
  });
}
