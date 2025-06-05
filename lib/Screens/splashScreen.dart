import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Make sure get is in pubspec.yaml

import 'package:course_app/Screens/homeScreen.dart';
import 'package:course_app/Screens/landingPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Start listening to auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (!mounted || _navigated) return;

      _navigated = true; // Prevent multiple navigations

      if (user == null) {
        Get.offAll(() => Landingpage());
      } else {
        Get.offAll(() => Homescreen());
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
            const Padding(
              padding: EdgeInsets.only(top: 200),
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }
}
