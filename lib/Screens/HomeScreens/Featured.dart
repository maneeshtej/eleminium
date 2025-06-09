import 'package:course_app/Model/playlist.dart';
import 'package:course_app/Model/video.dart';
import 'package:course_app/Screens/InfoScreens/videoDetails.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:isar/isar.dart';

class Featured extends StatefulWidget {
  const Featured({super.key});

  @override
  State<Featured> createState() => _FeaturedState();
}

class _FeaturedState extends State<Featured> {
  final user = FirebaseAuth.instance.currentUser;
  final Isarcontroller _isarController = Get.find<Isarcontroller>();

  List<Playlist> _playlists = [];
  Playlist? _currentPlaylist;

  Future<void> getAllPlaylists() async {
    final playlists = await _isarController.getAllPlaylists();

    if (!mounted) return;

    setState(() {
      _playlists = playlists;
    });
  }

  Future<void> setCurrentPlaylist(Playlist playlist) async {
    if (_currentPlaylist?.id == playlist.id) {
      setState(() {
        _currentPlaylist = null;
      });
    } else {
      setState(() {
        _currentPlaylist = playlist;
      });
    }
  }

  Map<String, dynamic> getDurationParameters(Playlist playlist) {
    final videos = playlist.videos.toList();

    int totalDuration = 0;
    int watchedDuration = 0;
    int remainingDuration = 0;
    double durationRatio = 0;

    List<Video> completedVideos = [];
    List<Video> nextVideos = [];

    for (var video in videos) {
      totalDuration += video.totalDuration;
      watchedDuration += video.watchedDuration;

      if (video.watchedDuration >= video.totalDuration * 0.95) {
        completedVideos.add(video);
      } else {
        nextVideos.add(video);
      }
    }

    remainingDuration = totalDuration - watchedDuration;
    durationRatio = totalDuration == 0 ? 0 : watchedDuration / totalDuration;

    return {
      'totalDuration': totalDuration,
      'watchedDuration': watchedDuration,
      'remainingDuration': remainingDuration,
      'durationRatio': durationRatio,
      'completedVideos': completedVideos,
      'nextVideos': nextVideos,
    };
  }

  @override
  void initState() {
    super.initState();
    getAllPlaylists();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello ${user?.displayName?.split(' ')[0] ?? 'user'}",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Got any cookies?...",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (_playlists.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = _playlists[index];
                      final videoList = playlist.videos.toList();
                      final firstVideo =
                          videoList.isNotEmpty ? videoList.first : null;
                      final isSelected = playlist.id == _currentPlaylist?.id;
                      final data = getDurationParameters(playlist);
                      double progress = data['durationRatio'] ?? 0;

                      return GestureDetector(
                        onTap: () {
                          setCurrentPlaylist(playlist);
                        },
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 12, top: 10),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.grey.shade900
                                    : Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                              LinearProgressIndicator(
                                value: progress,

                                backgroundColor: Colors.grey.shade800,
                              ),
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

              if (_currentPlaylist != null) ...[
                const SizedBox(height: 30),
                buildContinueAndCompletedSection(_currentPlaylist!),
              ],

              SizedBox(height: 100),

              // You can add more widgets here (e.g., horizontally scrolling videos)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContinueAndCompletedSection(Playlist playlist) {
    final videos = playlist.videos.toList();

    final nextVideos =
        videos
            .where(
              (video) =>
                  video.totalDuration > 0 &&
                  video.watchedDuration < video.totalDuration,
            )
            .toList();

    final completedVideos =
        videos
            .where(
              (video) =>
                  video.totalDuration > 0 &&
                  video.watchedDuration >= video.totalDuration,
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (nextVideos.isNotEmpty) ...[
          const Text(
            "Continue Learning",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nextVideos.length,
              itemBuilder: (_, index) {
                final video = nextVideos[index];
                double ratio =
                    video.totalDuration == 0
                        ? 0
                        : video.watchedDuration / video.totalDuration;
                return buildVideoCard(video, ratio);
              },
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (completedVideos.isNotEmpty) ...[
          const Text(
            "Completed Videos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: completedVideos.length,
              itemBuilder: (_, index) {
                final video = completedVideos[index];
                return buildVideoCard(video, 1.0); // 100% completed
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget buildVideoCard(Video video, double progress) {
    return GestureDetector(
      onTap: () {
        Get.to(() => VideoDetails(videoId: video.videoId));
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            video.thumbnailBytes != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    Uint8List.fromList(video.thumbnailBytes!),
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                : Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.video_library, color: Colors.white),
                  ),
                ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Text(
              video.title ?? "No Title",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              video.channelTitle ?? "Channel",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
