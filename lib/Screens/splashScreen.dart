import 'dart:async';

import 'package:flutter/material.dart';
import 'package:course_app/Screens/landingPage.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      Navigator.push(
        context,
        PageTransition(
          child: Landingpage(),
          type: PageTransitionType.rightToLeftWithFade,
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }
}
