import 'package:flutter/material.dart';
import 'package:course_app/Screens/signInandUp/signIn.dart';
import 'package:course_app/Screens/signInandUp/signUp.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void togglePage() {
    final nextPage = _currentPage == 0 ? 1 : 0;
    _pageController.animateToPage(
      nextPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = nextPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [SignUp(), Signin()],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade900,
        child: Row(
          mainAxisAlignment:
              _currentPage == 0
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: togglePage,
              child: Row(
                children: [
                  Text(
                    _currentPage == 0 ? "Sign In" : "Sign Up",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    _currentPage == 0 ? Icons.arrow_forward : Icons.arrow_back,
                    size: 17,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
