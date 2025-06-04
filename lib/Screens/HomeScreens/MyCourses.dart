import 'dart:typed_data';

import 'package:course_app/Enums/playListType.dart';
import 'package:course_app/Model/playlist.dart';
import 'package:course_app/Screens/InfoScreens/videoDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:course_app/Model/video.dart';
import 'package:isar/isar.dart';

class Mycourses extends StatefulWidget {
  const Mycourses({super.key});

  @override
  State<Mycourses> createState() => _MycoursesState();
}

class _MycoursesState extends State<Mycourses> {
  final _isarController = Get.find<Isarcontroller>();

  List<Map<String, dynamic>> _historyVideos = [];
  List<Map<String, dynamic>> _likedVideos = [];

  @override
  void initState() {
    super.initState();
    // Run after the first frame to avoid blocking
    _loadHistoryVideos();
    _loadLikedVideos();
  }

  Future<void> _loadHistoryVideos() async {
    try {
      final isar = await _isarController.isar;

      final watchedVideos =
          await isar.videos
              .filter()
              .watchedDurationGreaterThan(0)
              .sortByLastWatchedDesc()
              .findAll();

      final List<Map<String, dynamic>> history =
          watchedVideos.map((video) {
            return {
              'videoId': video.videoId,
              'title': video.title ?? '',
              'thumbnailBytes': video.thumbnailBytes ?? '',
              'channelTitle': video.channelTitle ?? '',
            };
          }).toList();

      setState(() {
        _historyVideos = history;
        // print("history is  : ${history}");
      });
    } catch (e, st) {
      print('Error loading history videos: $e\n$st');
    }
  }

  Future<void> _loadLikedVideos() async {
    final isar = await _isarController.isar;

    final liked =
        await isar.playlists
            .filter()
            .typeEqualTo(PlaylistType.liked)
            .findFirst();

    if (liked != null) {
      await liked.videos.load();

      final List<Map<String, dynamic>> finalLikedVideos =
          liked.videos.map((video) {
            return {
              'videoId': video.videoId,
              'title': video.title ?? '',
              'thumbnailBytes': video.thumbnailBytes ?? '',
              'channelTitle': video.channelTitle ?? '',
            };
          }).toList();

      setState(() {
        _likedVideos = finalLikedVideos;
      });

      print(_likedVideos);
    }
  }

  Future<void> clearAllVideos() async {
    final isar = await _isarController.isar;

    await isar.writeTxn(() async {
      await isar.videos.clear(); // deletes all Video objects
    });

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
                            await _loadLikedVideos();
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

            if (_likedVideos.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Liked videos",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (_likedVideos.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _likedVideos.length,
                      itemBuilder: (context, index) {
                        final video = _likedVideos[index];
                        return GestureDetector(
                          onTap: () async {
                            await Get.to(
                              VideoDetails(videoId: video['videoId']),
                            );
                            await _loadHistoryVideos();
                            await _loadLikedVideos();
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
              children: const [
                Text(
                  "Playlists",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(child: SizedBox()),
                Icon(Icons.add, color: Colors.white, size: 25),
                SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
