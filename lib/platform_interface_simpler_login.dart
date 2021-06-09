import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class SimplerLoginPlatformInterface extends PlatformInterface {
  SimplerLoginPlatformInterface() : super(token: _token);

  static Object _token = Object();

  ///[Variables]
  var _auth = FirebaseAuth.instance;
  String? verificationId;
  int? forceResendingToken;
  var _errorStreamController = StreamController<String?>.broadcast();
  var _otpSentController = StreamController<bool>.broadcast();
  final googleSignIn = GoogleSignIn();

  ///FirebaseAuth
  FirebaseAuth get auth => _auth;

  ///Get Current User
  User? get user => _auth.currentUser;

  ///Stream userchanges
  Stream<User?> get userStream => _auth.userChanges();

  ///Stream Error
  Stream<String?> get errorStream => _errorStreamController.stream;

  ///Stream whether OTP is sent or not
  Stream<bool> get otpSent => _otpSentController.stream;

  ///
  ///[CreateAccountWithEmailAndPassword] method to login to existing account
  ///
  /// Following [error] will be added to [stream] if conditions aren't met
  /// - **Account already exists**:
  ///  - Thrown if there already exists an account with the given email address.
  /// - **Provided email is invalid**:
  ///  - Thrown if the email address is not valid.
  /// - **Error occured. Contact admin!!**:
  ///  - Thrown if email/password accounts are not enabled. Enable
  ///    email/password accounts in the Firebase Console, under the Auth tab.
  /// - **Provided password is weak**:
  ///  - Thrown if the password is not strong enough.
  Future<UserCredential?> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      print(email);
      var creds = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (creds.user != null) _errorStreamController.sink.add(null);
      return creds;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _errorStreamController.sink.add('Account already exists');
          break;
        case 'invalid-email':
          _errorStreamController.sink.add('Provided email is invalid');
          break;
        case 'weak-password':
          _errorStreamController.sink.add('Provided password is weak');
          break;
        default:
          _errorStreamController.add('Error occured. Contact admin!!');
          break;
      }
    }
  }

  ///
  ///[signInWithEmailAndPassword] method to login to existing account
  ///
  /// Following [error] will be added to [_errorStreamController] if conditions aren't met
  /// - **Provided email is invalid**:
  ///  - Thrown if the email address is not valid.
  /// - **Account has been banned**:
  ///  - Thrown if the user corresponding to the given email has been disabled.
  /// - **Account does not exist**:
  ///  - Thrown if there is no user corresponding to the given email.
  /// - **Provided password is wrongss**:
  ///  - Thrown if the password is invalid for the given email, or the account
  ///    corresponding to the email does not have a password set.
  Future<UserCredential?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      var creds = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (creds.user != null) _errorStreamController.sink.add(null);
      return creds;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-disabled':
          _errorStreamController.sink.add('Account has been banned');
          break;
        case 'invalid-email':
          _errorStreamController.sink.add('Provided email is invalid');
          break;
        case 'user-not-found':
          _errorStreamController.sink.add('Account does not exist');
          break;
        case 'wrong-password':
          _errorStreamController.sink.add('Provided password is wrong');
          break;
        default:
          _errorStreamController.add('Error occured. Contact admin!!');
          break;
      }
    }
  }

  /// Starts a sign-in flow for a phone number.
  ///
  /// You can optionally provide a [RecaptchaVerifier] instance to control the
  /// reCAPTCHA widget apperance and behaviour.
  ///
  /// Once the reCAPTCHA verification has completed, called [ConfirmationResult.confirm]
  /// with the users SMS verification code to complete the authentication flow.
  ///
  /// This method is only available on web based platforms.
  verifyPhoneNumber({
    required String phoneNumber,
    TextEditingController? otpController,
    bool signInOnAutoRetrival = true,
    void Function(String, int?)? codeSent,
    void Function(FirebaseAuthException)? verificationFailed,
    void Function(PhoneAuthCredential)? verificationCompleted,
    void Function(String)? codeAutoRetrievalTimeout,
    RecaptchaVerifier? verifier,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted ??
          (credential) async {
            if (otpController != null) {
              otpController.text = credential.smsCode!;
            }
            if (signInOnAutoRetrival) {
              await _auth.signInWithCredential(credential);
            }
            _otpSentController.sink.add(true);
            _errorStreamController.sink.add(null);
          },
      verificationFailed: verificationFailed ??
          (exception) {
            _otpSentController.sink.add(false);
            _errorStreamController.sink.add(exception.message);
          },
      codeSent: codeSent ??
          (verificationId, forceResendingToken) {
            this.verificationId = verificationId;
            this.forceResendingToken = forceResendingToken;
            _otpSentController.sink.add(true);
            _errorStreamController.sink.add(null);
          },
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout ?? (verificationId) {},
    );
  }

  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **account-exists-with-different-credential**:
  ///  - Thrown if there already exists an account with the email address
  ///    asserted by the credential.
  ///    Resolve this by calling [fetchSignInMethodsForEmail] and then asking
  ///    the user to sign in using one of the returned providers.
  ///    Once the user is signed in, the original credential can be linked to
  ///    the user with [linkWithCredential].
  /// - **invalid-credential**:
  ///  - Thrown if the credential is malformed or has expired.
  /// - **operation-not-allowed**:
  ///  - Thrown if the type of account corresponding to the credential is not
  ///    enabled. Enable the account type in the Firebase Console, under the
  ///    Auth tab.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given credential has been
  ///    disabled.
  /// - **user-not-found**:
  ///  - Thrown if signing in with a credential from [EmailAuthProvider.credential]
  ///    and there is no user corresponding to the given email.
  /// - **wrong-password**:
  ///  - Thrown if signing in with a credential from [EmailAuthProvider.credential]
  ///    and the password is invalid for the given email, or if the account
  ///    corresponding to the email does not have a password set.
  /// - **invalid-verification-code**:
  ///  - Thrown if the credential is a [PhoneAuthProvider.credential] and the
  ///    verification code of the credential is not valid.
  /// - **invalid-verification-id**:
  ///  - Thrown if the credential is a [PhoneAuthProvider.credential] and the
  ///    verification ID of the credential is not valid.id.
  Future<UserCredential?> verifyOtp({
    required String smsCode,
    String verificationId = '',
  }) async {
    // assert(this.verificationId != null && verificationId == null);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId:
              verificationId.isEmpty ? this.verificationId! : verificationId,
          smsCode: smsCode);
      var creds = await _auth.signInWithCredential(credential);
      if (creds.user != null) _errorStreamController.sink.add(null);
      return creds;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          _errorStreamController.sink.add('Phonenumber already in use');
          break;
        case 'invalid-credential':
          _errorStreamController.sink.add('Credential provided are invalid');
          break;
        case 'user-disabled':
          _errorStreamController.sink.add('Account banned');
          break;
        case 'invalid-verification-code':
          _errorStreamController.sink.add('OTP provided is Invalid');
          break;
        default:
          _errorStreamController.add('Error occured. Contact admin!!');
          break;
      }
    }
  }

  ///
  ///
  ///
  Future<UserCredential?> signInWithGoogle() async {
    final googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      try {
        final googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        var creds = await auth.signInWithCredential(credential);
        if (creds.user != null) _errorStreamController.sink.add(null);
        return creds;
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            _errorStreamController.sink.add('Phonenumber already in use');
            break;
          case 'invalid-credential':
            _errorStreamController.sink.add('Credential provided are invalid');
            break;
          case 'user-disabled':
            _errorStreamController.sink.add('Account banned');
            break;
          case 'invalid-verification-code':
            _errorStreamController.sink.add('OTP provided is Invalid');
            break;
          default:
            _errorStreamController.add('Error occured. Contact admin!!');
            break;
        }
      }
    } else {
      _errorStreamController.add('Sign In Failed. Try again afetr sometime');
      return null;
    }
  }

  ///[Dispose]
  dispose() {
    _errorStreamController.close();
    _otpSentController.close();
  }
}
