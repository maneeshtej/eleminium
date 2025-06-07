import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VideoQuestionsSection extends StatefulWidget {
  final String videoId;

  const VideoQuestionsSection({super.key, required this.videoId});

  @override
  State<VideoQuestionsSection> createState() => _VideoQuestionsSectionState();
}

class _VideoQuestionsSectionState extends State<VideoQuestionsSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _submitQuestion() {
    final text = _controller.text.trim();
    if (text.isEmpty || text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a meaningful question.")),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.videoId)
        .collection('questions')
        .add({
          'question': text,
          'timestamp': Timestamp.now(),
          'username':
              FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous',
        });

    _controller.clear();
    _focusNode.unfocus(); // Dismiss keyboard
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      children: [
        // Only show input box if NOT landscape (remove input box in landscape)
        if (!isLandscape)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitQuestion,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Fixed height questions list to avoid layout breaking
        SizedBox(
          height: 300, // adjust height as needed
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('videos')
                    .doc(widget.videoId)
                    .collection('questions')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No questions yet. Be the first to ask!',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data()! as Map<String, dynamic>;
                  final question = data['question'] ?? '';
                  final username = data['username'] ?? 'Anonymous';
                  final timestamp = data['timestamp'] as Timestamp?;

                  final timeStr =
                      timestamp != null
                          ? TimeOfDay.fromDateTime(
                            timestamp.toDate(),
                          ).format(context)
                          : '';

                  return ListTile(
                    title: Text(
                      question,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'By $username at $timeStr',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
