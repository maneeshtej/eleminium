import 'package:course_app/Screens/HomeScreens/account.dart';
import 'package:course_app/Screens/HomeScreens/featured.dart';
import 'package:course_app/Screens/HomeScreens/library.dart';
import 'package:course_app/Screens/HomeScreens/Search.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  PageController pageController = PageController();
  int currentIndex = 0;

  void onTap(int page) {
    setState(() {
      currentIndex = page;
    });
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: PageView(
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        controller: pageController,
        children: [
          // Featured(),
          Search(),
          Library(),
          Account(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.grey.shade900,
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade500),
        selectedItemColor: Colors.deepPurple.shade300,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: TextStyle(fontSize: 10),
        unselectedLabelStyle: TextStyle(
          color: Colors.white,
          fontSize: 10,
        ), // Unselected label color
        type: BottomNavigationBarType.fixed,
        items: [
          // BottomNavigationBarItem(icon: Icon(Icons.star), label: "Featured"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
