import 'package:flutter/material.dart';

class Mycourses extends StatefulWidget {
  const Mycourses({super.key});

  @override
  State<Mycourses> createState() => _MycoursesState();
}

class _MycoursesState extends State<Mycourses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade900,
        title: Text(
          "My Courses",
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
      body: Container(color: Colors.black),
    );
    ;
  }
}
