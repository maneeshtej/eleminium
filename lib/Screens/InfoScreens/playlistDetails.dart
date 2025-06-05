import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:course_app/Model/playlist.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:course_app/Screens/InfoScreens/videoDetails.dart';

class PlaylistDetailsPage extends StatefulWidget {
  final Playlist playlist;
  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  final _isarController = Get.find<Isarcontroller>();

  bool get isDefault =>
      widget.playlist.playlistName == "Liked" ||
      widget.playlist.playlistName == "Watch Later";

  @override
  void initState() {
    super.initState();
    widget.playlist.videos.load(); // Load linked videos
  }

  Future<void> deletePlaylist() async {
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Delete Playlist?"),
        content: const Text("Are you sure you want to delete this playlist?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final isar = await _isarController.isar;
      await isar.writeTxn(() async {
        await isar.playlists.delete(widget.playlist.id);
      });
      Get.back(); // Go back to previous page
    }
  }

  Future<String?> _showRenameDialog() async {
    final controller = TextEditingController(
      text: widget.playlist.playlistName,
    );

    return await Get.dialog<String>(
      AlertDialog(
        title: const Text("Rename Playlist"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "New playlist name"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Get.back(result: controller.text),
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videos = widget.playlist.videos.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.playlist.playlistName),
        actions: [
          if (!isDefault) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final newName = await _showRenameDialog();
                if (newName != null && newName.trim().isNotEmpty) {
                  final isar = await _isarController.isar;
                  await isar.writeTxn(() async {
                    widget.playlist.playlistName = newName.trim();
                    await isar.playlists.put(widget.playlist);
                  });
                  setState(() {});
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deletePlaylist,
            ),
          ],
        ],
      ),
      backgroundColor: Colors.black,
      body:
          videos.isEmpty
              ? const Center(
                child: Text(
                  "No videos in this playlist.",
                  style: TextStyle(color: Colors.white54),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];

                  return GestureDetector(
                    onTap: () async {
                      await Get.to(() => VideoDetails(videoId: video.videoId));
                      await widget.playlist.videos.load();
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                video.thumbnailBytes != null
                                    ? Image.memory(
                                      Uint8List.fromList(video.thumbnailBytes!),
                                      width: 120,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      width: 120,
                                      height: 70,
                                      color: Colors.grey.shade700,
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title ?? "Untitled Video",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  video.channelTitle ?? "Unknown Channel",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
