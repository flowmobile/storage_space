import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage_space_example/main.dart';

void main() {
  testWidgets('shows the free space once loaded', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('storage_space'),
            (MethodCall call) async {
      switch (call.method) {
        case 'getFreeSpace':
          return 16 * 1024 * 1024 * 1024;
        case 'getTotalSpace':
          return 64 * 1024 * 1024 * 1024;
      }
      return null;
    });

    await tester.pumpWidget(MyApp());
    expect(find.text('Loading'), findsOneWidget);

    await tester.pump();
    expect(find.text('16 GB'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
  });
}
