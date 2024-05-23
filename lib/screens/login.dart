import 'package:e_election/screens/email_verification.dart';
import 'package:e_election/screens/votingscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

import 'signup.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Login'),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.deepPurple], // Gradient colors
        ), // Styling the AppBar
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.blue], // Gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorStyle: TextStyle(color: Colors.white), // Add this
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white),
                      // Styling the label
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius:
                              BorderRadius.circular(50.0) // Border color
                          ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(
                              20.0) // Border color when focused
                          ),
                      errorStyle: TextStyle(color: Colors.white), // Add this
        
                    ),
                    style: const TextStyle(color: Colors.white),
        
                    // Text color
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            // Navigate to the home screen
                            bool isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
                            if(isEmailVerified){
                              Navigator.pushNamed(context, VotingPage.routeName);
                            }
                            else{
                              Navigator.pushNamed(context, EmailVerification.routeName);
                            }

                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No user found for that email.'),
                                ),
                              );
                            } else if (e.code == 'wrong-password') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Wrong password provided for that user.'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        // Button background color
                        foregroundColor: Colors.white,
                        // Button text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16), // Button padding
                      ),
                      child: const Text('Login'),
                    ),
                  ),

                  const SizedBox(height: 15.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?', style: TextStyle(color: Colors.white),),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, SignUpPage.routeName);
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
