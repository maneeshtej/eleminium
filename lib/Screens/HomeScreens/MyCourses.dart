import 'package:course_app/Screens/InfoScreens/VideoDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:course_app/Services/DataController.dart';
import 'package:course_app/Model/video.dart';
import 'package:isar/isar.dart';

class Mycourses extends StatefulWidget {
  const Mycourses({super.key});

  @override
  State<Mycourses> createState() => _MycoursesState();
}

class _MycoursesState extends State<Mycourses> {
  final _isarController = Get.find<IsarController>();
  final _dataController = Datacontroller();

  List<Map<String, dynamic>> _historyVideos = [];

  @override
  void initState() {
    super.initState();
    // Run after the first frame to avoid blocking
    _loadHistoryVideos();
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
              'thumbnailUrl': video.thumbnailUrl ?? '',
              'channelTitle': video.channelTitle ?? '',
            };
          }).toList();

      setState(() {
        _historyVideos = history;
        print("history is  : ${history}");
      });
    } catch (e, st) {
      print('Error loading history videos: $e\n$st');
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          "My Courses",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_historyVideos.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _historyVideos.length,
                      itemBuilder: (context, index) {
                        final video = _historyVideos[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(VideoDetails(videoId: video['videoId']));
                          },
                          child: Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 100,
                                    color: Colors.grey.shade500,
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
                  ElevatedButton(
                    onPressed: clearAllVideos,
                    child: Text('Clear All History'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
