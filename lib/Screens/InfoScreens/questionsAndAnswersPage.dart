import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class QuestionAndAnswersPage extends StatefulWidget {
  final String videoId;
  final String? questionId;

  const QuestionAndAnswersPage({
    super.key,
    required this.videoId,
    this.questionId,
  });

  @override
  State<QuestionAndAnswersPage> createState() => _QuestionAndAnswersPageState();
}

class _QuestionAndAnswersPageState extends State<QuestionAndAnswersPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    await FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.videoId)
        .collection('questions')
        .doc(widget.questionId)
        .collection('answers')
        .add({
          'answer': text,
          'userId':
              FirebaseAuth
                  .instance
                  .currentUser
                  ?.uid, // Replace with actual user
          'username':
              FirebaseAuth
                  .instance
                  .currentUser
                  ?.displayName, // Replace with actual username
          'timestamp': FieldValue.serverTimestamp(),
        });

    _answerController.clear();
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questionId == null) {
      // Show ALL questions list
      final questionsRef = FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .collection('questions')
          .orderBy('timestamp', descending: true);

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("All Questions"),
        ),
        backgroundColor: Colors.black,
        body: StreamBuilder<QuerySnapshot>(
          stream: questionsRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  "No questions yet.",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView(
              children:
                  docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        data['question'] ?? "Untitled",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "by ${data['username'] ?? "Unknown"}",
                        style: const TextStyle(color: Colors.white54),
                      ),
                      onTap: () {
                        Get.to(
                          () => QuestionAndAnswersPage(
                            videoId: widget.videoId,
                            questionId: doc.id,
                          ),
                          preventDuplicates: false,
                        );
                      },
                    );
                  }).toList(),
            );
          },
        ),
      );
    }

    // 👇 Existing question+answers page continues here
    final questionRef = FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.videoId)
        .collection('questions')
        .doc(widget.questionId);

    final answersRef = questionRef.collection('answers').orderBy('timestamp');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Question & Answers"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: questionRef.get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(),
                );
              }

              final questionData =
                  snapshot.data!.data() as Map<String, dynamic>?;

              if (questionData == null) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Question not found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListTile(
                title: Text(
                  questionData['question'] ?? '',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                subtitle: Text(
                  "by ${questionData['username'] ?? 'Unknown'}",
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            },
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: answersRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No answers yet. Be the first!",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        data['answer'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        data['username'] ?? '',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Write your answer...",
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _submitAnswer,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
