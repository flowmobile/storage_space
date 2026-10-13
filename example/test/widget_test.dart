import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage_space_example/main.dart';

void main() {
  testWidgets('shows device and app storage once loaded', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('storage_space'),
            (MethodCall call) async {
      switch (call.method) {
        case 'getFreeSpace':
          return 16 * 1024 * 1024 * 1024;
        case 'getTotalSpace':
          return 64 * 1024 * 1024 * 1024;
        case 'getAppStorageUsage':
          return {
            'app': 40 * 1024 * 1024,
            'data': 24 * 1024 * 1024,
            'cache': 4 * 1024 * 1024,
          };
      }
      return null;
    });

    await tester.pumpWidget(MyApp());
    expect(find.text('Loading'), findsOneWidget);

    await tester.pump();
    expect(find.text('16 GB'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('48 GB of 64 GB used'), findsOneWidget);
    expect(find.text('This app uses 64 MB'), findsOneWidget);
    expect(find.text('App 40 MB · Data 24 MB · Cache 4 MB'), findsOneWidget);
  });
}
