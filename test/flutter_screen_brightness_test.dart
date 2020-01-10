import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_brightness/flutter_screen_brightness.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_screen_brightness');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getBrightness', () async {
    expect(await ScreenBrightness.brightness, '42');
  });
}
