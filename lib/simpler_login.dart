import 'package:simpler_login/platform_interface_simpler_login.dart';

class SimplerLogin extends SimplerLoginPlatformInterface {
  SimplerLogin._internal();

  static final SimplerLogin _simplerLogin = SimplerLogin._internal();

  static SimplerLogin get instance => _simplerLogin;
}
