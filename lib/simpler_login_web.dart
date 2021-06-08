import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:simpler_login/platform_interface_simpler_login.dart';

/// A web implementation of the SimplerLogin plugin.
class SimplerLoginWeb extends SimplerLoginPlatformInterface {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'simpler_login',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = SimplerLoginWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getPlatformVersion':
        return getPlatformVersion();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'simpler_login for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }

  @override
  verifyPhoneNumber({
    required String phoneNumber,
    TextEditingController? otpController,
    bool signInOnAutoRetrival = true,
    void Function(String, int?)? codeSent,
    void Function(FirebaseAuthException)? verificationFailed,
    void Function(PhoneAuthCredential)? verificationCompleted,
    void Function(String)? codeAutoRetrievalTimeout,
    RecaptchaVerifier? verifier,
  }) {
    return auth.signInWithPhoneNumber(phoneNumber);
  }
}
