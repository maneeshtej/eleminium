import 'dart:typed_data';
import 'package:course_app/Model/playlist.dart';
import 'package:course_app/Screens/Helpers/addPlaylistPage.dart';
import 'package:course_app/Screens/InfoScreens/playlistDetails.dart';
import 'package:course_app/Screens/InfoScreens/videoDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:course_app/Model/video.dart';
import 'package:isar/isar.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _MycoursesState();
}

class _MycoursesState extends State<Library> {
  final _isarController = Get.find<Isarcontroller>();

  List<Map<String, dynamic>> _historyVideos = [];
  List<Playlist> _playLists = [];

  @override
  void initState() {
    super.initState();
    // Run after the first frame to avoid blocking
    _loadHistoryVideos();
    _loadPlaylists();
  }

  Future<void> _loadHistoryVideos() async {
    final historyVideos = await _isarController.getHistoryVideosMinimal();

    setState(() {
      _historyVideos = historyVideos;
    });
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _isarController.getAllPlaylists();

    setState(() {
      _playLists = playlists;
    });
  }

  Future<void> clearAllVideos() async {
    final isar = await _isarController.isar;

    await isar.writeTxn(() async {
      await isar.videos.clear(); // deletes all Video objects

      final playlists = await isar.playlists.where().findAll();

      for (final playlist in playlists) {
        playlist.videos.clear();
        await isar.playlists.put(playlist);
      }
    });

    await _loadHistoryVideos();
    await _loadPlaylists();

    setState(() {});

    Get.snackbar('History Cleared', 'All videos removed from local history');
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold();
    return Scaffold(
      backgroundColor: Colors.black,

      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Library",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            // SizedBox(height: 5),
            // Text(
            //   "Got any cookies?...",
            //   style: TextStyle(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w400,
            //     color: Colors.grey.shade400,
            //   ),
            // ),
            const SizedBox(height: 30),
            if (_historyVideos.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        "My Videos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _historyVideos.length,
                      itemBuilder: (context, index) {
                        final video = _historyVideos[index];
                        return GestureDetector(
                          onTap: () async {
                            await Get.to(
                              VideoDetails(videoId: video['videoId']),
                            );
                            await _loadHistoryVideos();
                          },
                          child: Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      video['thumbnailBytes'] != null &&
                                              (video['thumbnailBytes'] as List)
                                                  .isNotEmpty
                                          ? Image.memory(
                                            Uint8List.fromList(
                                              video['thumbnailBytes'].toList(),
                                            ),
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            height: 100,
                                            color: Colors.grey.shade500,
                                            child: Center(
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                ),

                                const SizedBox(height: 6),
                                Text(
                                  video['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  video['channelTitle'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Playlists",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () {
                    Get.to(AddPlaylistPage());
                  },
                  icon: Icon(Icons.add, color: Colors.white, size: 25),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 10),
            if (_playLists.isNotEmpty)
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _playLists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playLists[index];
                    final firstVideo =
                        playlist.videos.isNotEmpty
                            ? playlist.videos.first
                            : null;

                    return GestureDetector(
                      onTap: () async {
                        await Get.to(PlaylistDetailsPage(playlist: playlist));
                        await _loadPlaylists();
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  firstVideo?.thumbnailBytes != null
                                      ? Image.memory(
                                        Uint8List.fromList(
                                          firstVideo!.thumbnailBytes!,
                                        ),
                                        height: 100,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        height: 100,
                                        color: Colors.grey.shade700,
                                        child: const Center(
                                          child: Icon(
                                            Icons.video_library,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              playlist.playlistName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              '${playlist.videos.length} video(s)',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // MaterialButton(
            //   onPressed: () async {
            //     await clearAllVideos();
            //   },
            //   child: Text("Delete all"),
            // ),
          ],
        ),
      ),
    );
  }
}
