import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

import 'login.dart';
import 'votingscreen.dart';

class EmailVerification extends StatefulWidget {
  static const String routeName = '/email_verification';

  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  bool isEmailVerified = false;
  Timer? timer;
  bool isEmailSent = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    print("Email is verified: $isEmailVerified");

    if (!isEmailVerified) {
      try {
        FirebaseAuth.instance.currentUser!.sendEmailVerification();
      } catch (e) {
        print("An error occured while trying to send email verification");
        print(e);
      }

      timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await FirebaseAuth.instance.currentUser!.reload();
        var user = FirebaseAuth.instance.currentUser;
        if (user!.emailVerified) {
          timer.cancel();
          Navigator.pushReplacementNamed(context, VotingPage.routeName);
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Email Verification'),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.deepPurple],
        ),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.blue], // Gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Please verify your email address',
                style: TextStyle(color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  // Resend email verification logic
                },
                child: const Text('Resend Email Verification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, LoginPage.routeName);
                },
                child: const Text("Cancel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resendEmailVerification() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      setState(() {
        isEmailSent = false;
      });
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        isEmailSent = true;
      });
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e);
    }
  }
}
