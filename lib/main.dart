import 'package:e_election/screens/addcompititor.dart';
import 'package:e_election/screens/email_verification.dart';
import 'package:e_election/screens/signup.dart';
import 'package:e_election/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/reults.dart';
import 'screens/votingscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      // home: LoginPage(),
      debugShowCheckedModeBanner: false,

      initialRoute: SplashScreen.routeName,

      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        LoginPage.routeName: (context) => const LoginPage(),
        SignUpPage.routeName: (context) => const SignUpPage(),
        EmailVerification.routeName: (context) => const EmailVerification(),
        VotingPage.routeName: (context) => const VotingPage(),
        AddCompetitorPage.routeName: (context) => const AddCompetitorPage(),
        ShowResultsScreen.routeName: (context) =>
            ShowResultsScreen(resultsDisplayed: ModalRoute.of(context)?.settings.arguments,),
      },
    );
  }
}
