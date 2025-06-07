import 'dart:io';

import 'package:course_app/Screens/InfoScreens/noteEditor.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // Adjust path

class VideoNotesSection extends StatefulWidget {
  final String videoId;
  final YoutubePlayerController youtubePlayerController;

  const VideoNotesSection({
    super.key,
    required this.videoId,
    required this.youtubePlayerController,
  });

  @override
  State<VideoNotesSection> createState() => _VideoNotesSectionState();
}

class _VideoNotesSectionState extends State<VideoNotesSection> {
  final Isarcontroller isarController = Get.find<Isarcontroller>();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await isarController.getAllNotes(widget.videoId);
    setState(() => _notes = data);
  }

  Future<void> _addNote() async {
    widget.youtubePlayerController.pause();
    final currentTime =
        widget.youtubePlayerController.value.position.inMilliseconds;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    );

    if (result != null && result['note'].toString().isNotEmpty) {
      await isarController.createOrUpdateNote(
        videoId: widget.videoId,
        note: result['note'],
        timestamp: currentTime,
        imagePaths: List<String>.from(result['images'] ?? []),
      );
      _loadNotes();
    }
  }

  Future<void> deleteOrEditNote(Map<String, dynamic> note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => NoteEditorPage(
              initialNote: note['note'],
              initialImages: List<String>.from(note['imagePaths'] ?? []),
            ),
      ),
    );

    if (result != null && result['note'].toString().isNotEmpty) {
      await isarController.createOrUpdateNote(
        noteId: note['id'],
        videoId: note['videoId'] ?? '',
        note: result['note'],
        timestamp: note['timestamp'],
        imagePaths: List<String>.from(result['images'] ?? []),
        isSynced: note['isSynced'] ?? false,
      );
      await _loadNotes();
    }
  }

  void seekToTimestamp(int timestamp) {
    widget.youtubePlayerController.pause();
    widget.youtubePlayerController.seekTo(Duration(milliseconds: timestamp));
    widget.youtubePlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isLandscape) // Show only in portrait
            ElevatedButton(
              onPressed: _addNote,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Add Note"), Icon(Icons.add)],
              ),
            ),
          const SizedBox(height: 16),
          (_notes.isEmpty)
              ? const Center(child: Text("No notes yet"))
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _notes.map((note) {
                      final readableTime = Duration(
                        milliseconds: note['timestamp'],
                      );
                      final timestampFormatted =
                          "${readableTime.inMinutes}:${(readableTime.inSeconds % 60).toString().padLeft(2, '0')}";

                      final List<String> images = List<String>.from(
                        note['imagePaths'] ?? [],
                      );

                      return GestureDetector(
                        onTap: () => seekToTimestamp(note['timestamp']),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(note['note'] ?? ''),
                                  subtitle: Text(
                                    "Timestamp: $timestampFormatted",
                                  ),
                                  trailing:
                                      (isLandscape)
                                          ? null
                                          : IconButton(
                                            onPressed: () async {
                                              await deleteOrEditNote(note);
                                            },
                                            icon: const Icon(Icons.edit),
                                          ),
                                ),
                                if (images.isNotEmpty)
                                  SizedBox(
                                    height: 100,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: images.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final imagePath = images[index];
                                        return GestureDetector(
                                          onTap: () {
                                            _showImageViewer(
                                              context,
                                              imagePath,
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              File(imagePath),
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
        ],
      ),
    );
  }

  void _showImageViewer(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(File(imagePath)),
            ),
          ),
    );
  }
}
