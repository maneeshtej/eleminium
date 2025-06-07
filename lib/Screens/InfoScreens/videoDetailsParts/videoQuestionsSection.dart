import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_app/Screens/InfoScreens/questionsAndAnswersPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class VideoQuestionsSection extends StatelessWidget {
  final String videoId;
  final VoidCallback exitFullscreen;

  const VideoQuestionsSection({
    super.key,
    required this.videoId,
    required this.exitFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('videos')
              .doc(videoId)
              .collection('questions')
              .orderBy('timestamp', descending: true)
              .limit(5)
              .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final questions = snapshot.data!.docs;

        if (questions.isEmpty) {
          return Text(
            "No questions yet.",
            style: TextStyle(color: Colors.white60),
          );
        }

        return Column(
          children: [
            ...questions.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(
                  data['question'] ?? "Untitled",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  data['username'] ?? "",
                  style: TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  exitFullscreen();
                  // 👇 Navigate to full Q&A page
                  Get.to(
                    () => QuestionAndAnswersPage(
                      questionId: doc.id,
                      videoId: videoId,
                    ),
                  );
                },
              );
            }),
            TextButton(
              onPressed: () {
                exitFullscreen();
                Get.to(() => QuestionAndAnswersPage(videoId: videoId));
              },
              child: const Text("See all questions"),
            ),
          ],
        );
      },
    );
  }
}
