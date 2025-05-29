import 'package:course_app/Screens/homeScreen.dart';
import 'package:course_app/Services/Auth.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Text(
              "Sign In",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 250,
              height: 50,
              child: MaterialButton(
                color: Colors.white,
                onPressed: () async {
                  await auth.googleSignIn().whenComplete(() {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: Homescreen(),
                      ),
                    );
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(EvaIcons.google),
                    SizedBox(width: 5),
                    Text("Sign in with Google"),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 250,
              height: 50,
              child: MaterialButton(
                color: Colors.white,
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.apple),
                    SizedBox(width: 5),
                    Text("Sign in with Apple"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
