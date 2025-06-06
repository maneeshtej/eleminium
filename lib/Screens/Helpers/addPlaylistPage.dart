import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:course_app/Model/playlist.dart';
import 'package:course_app/Services/isarController.dart';

class AddPlaylistPage extends StatefulWidget {
  final String? videoId;
  final Map<String, dynamic>? data;

  const AddPlaylistPage({super.key, this.videoId, this.data});

  @override
  State<AddPlaylistPage> createState() => _AddPlaylistPageState();
}

class _AddPlaylistPageState extends State<AddPlaylistPage> {
  final _isarController = Get.find<Isarcontroller>();
  final TextEditingController _controller = TextEditingController();

  List<Playlist> _playlistList = [];

  @override
  void initState() {
    super.initState();
    _getAllPlaylists();
  }

  Future<void> _getAllPlaylists() async {
    final playlists = await _isarController.getAllPlaylists();
    setState(() {
      _playlistList = playlists;
    });
  }

  Future<void> _createPlaylist(String name) async {
    await _isarController.createPlaylist(name);
    _controller.clear();
    _getAllPlaylists();
  }

  Future<void> _handleTap(String playlistName) async {
    if (widget.videoId != null && widget.data != null) {
      await _isarController.addToPlaylist(
        playlistName,
        widget.videoId!,
        widget.data,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Add to Playlist"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add playlist input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Create new playlist",
                      hintStyle: TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _createPlaylist(_controller.text.trim());
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (widget.videoId != null && widget.data != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  widget.data?["title"] ?? "Video Title",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white30),
            ],

            // Playlist list
            Expanded(
              child:
                  _playlistList.isEmpty
                      ? const Center(
                        child: Text(
                          "No playlists found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _playlistList.length,
                        itemBuilder: (context, index) {
                          final playlist = _playlistList[index];
                          return ListTile(
                            title: Text(
                              playlist.playlistName ?? "Unnamed",
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () => _handleTap(playlist.playlistName!),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
