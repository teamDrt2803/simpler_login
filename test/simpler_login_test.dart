import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpler_login/simpler_login.dart';

void main() {
  const MethodChannel channel = MethodChannel('simpler_login');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
