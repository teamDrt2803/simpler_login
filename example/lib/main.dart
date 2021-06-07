import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simpler_login/simpler_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var simplerLogin = SimplerLogin.instance;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phonrController = TextEditingController();
  var otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: StreamBuilder<User?>(
            stream: simplerLogin.userStream,
            builder: (context, snapshot) {
              return snapshot.data != null
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Logged In'),
                            TextButton(
                                onPressed: () async {
                                  await simplerLogin.auth.signOut();
                                },
                                child: Text('Log Out'))
                          ],
                        ),
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          StreamBuilder<String?>(
                              stream: simplerLogin.errorStream,
                              builder: (context, snapshot) {
                                return Text(snapshot.data ?? '');
                              }),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustTFF(
                                  controller: emailController,
                                  hint: 'Email',
                                ),
                                CustTFF(
                                  obscureText: true,
                                  controller: passwordController,
                                  hint: 'Password',
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          await simplerLogin
                                              .signInWithEmailAndPassword(
                                                  email: emailController.text
                                                      .trim(),
                                                  password: passwordController
                                                      .text
                                                      .trim());
                                        },
                                        child: Text('SignIn')),
                                    TextButton(
                                        onPressed: () async {
                                          await simplerLogin
                                              .createUserWithEmailAndPassword(
                                                  email: emailController.text
                                                      .trim(),
                                                  password: passwordController
                                                      .text
                                                      .trim());
                                        },
                                        child: Text('Create Account'))
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder<bool>(
                                stream: simplerLogin.otpSent,
                                builder: (context, snapshot) {
                                  bool otpSent = snapshot.data ?? false;
                                  return Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CustTFF(
                                        prefixText: '+91 ',
                                        readOnly: otpSent,
                                        controller: phonrController,
                                        hint: 'PhoneNumber',
                                      ),
                                      Visibility(
                                        visible: otpSent,
                                        child: CustTFF(
                                          controller: otpController,
                                          hint: 'OTP',
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                              onPressed: () async {
                                                if (otpSent) {
                                                  await simplerLogin.verifyOtp(
                                                      smsCode:
                                                          otpController.text);
                                                } else {
                                                  simplerLogin.verifyPhoneNumber(
                                                      phoneNumber:
                                                          '+91${phonrController.text}');
                                                }
                                              },
                                              child: Text(otpSent
                                                  ? 'Verify OTP'
                                                  : 'Send OTP')),
                                        ],
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ],
                      ),
                    );
            }),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    simplerLogin.dispose();
  }
}

class CustTFF extends StatelessWidget {
  const CustTFF({
    Key? key,
    this.hint,
    required this.controller,
    this.readOnly = false,
    this.prefixText,
    this.obscureText = false,
  }) : super(key: key);
  final String? hint, prefixText;
  final TextEditingController controller;
  final bool readOnly, obscureText;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      readOnly: readOnly,
      controller: controller,
      decoration: InputDecoration(
        prefixText: prefixText,
        border: OutlineInputBorder(),
        labelText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
