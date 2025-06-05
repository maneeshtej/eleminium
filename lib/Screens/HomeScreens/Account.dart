import 'package:course_app/Screens/landingPage.dart';
import 'package:course_app/Services/Auth.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Auth auth = Auth();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _firebaseAuth.signOut(); // Sign out from Firebase
      print("[DEBUG] User signed out successfully.");
    } catch (e) {
      print("[ERROR] Sign-out failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade900,
        title: Text(
          "Account",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: 400,
              child: Container(
                color: Colors.grey.shade900,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        Icon(EvaIcons.google, color: Colors.white, size: 15),
                        Text(
                          user?.email ?? 'unknown',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, left: 20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Headline",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward, color: Colors.white),
                    title: Text(
                      "Setting",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward, color: Colors.white),
                    title: Text(
                      "Setting",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, left: 20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Headline",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward, color: Colors.white),
                    title: Text(
                      "Setting",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward, color: Colors.white),
                    title: Text(
                      "Setting",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, left: 20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Headline",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward, color: Colors.white),
                    title: Text(
                      "Setting",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward, color: Colors.white),
                    title: Text(
                      "Setting",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: Center(
                child: TextButton(
                  onPressed: () async {
                    await signOut();
                    Get.offAll(() => Landingpage());
                  },
                  child: Text(
                    "Log Out",
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "v1.4",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
