import 'package:firebase_auth/firebase_auth.dart';
import 'package:course_app/Screens/homeScreen.dart';
import 'package:course_app/Screens/landingPage.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    final user = _firebaseAuth.currentUser;

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: Homescreen(),
            type: PageTransitionType.rightToLeftWithFade,
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: Landingpage(),
            type: PageTransitionType.rightToLeftWithFade,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 150, child: Image.asset('images/logo.png')),
            Text(
              "Eleminum",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 200),
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }
}
