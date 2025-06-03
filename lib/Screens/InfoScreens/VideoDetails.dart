import 'dart:async';

import 'package:course_app/Model/video.dart';
import 'package:course_app/Services/DataController.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:isar/isar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDetails extends StatefulWidget {
  final String videoId; // Now pass just the video ID
  const VideoDetails({super.key, required this.videoId});

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails> {
  bool _descriptionExpanded = false;
  late YoutubePlayerController _youtubePlayerController;
  final _isarController = Get.find<IsarController>();
  Timer? _progressTimer;

  Map<String, dynamic>? _videoData;

  final String apiKey = 'YOUR_YOUTUBE_API_KEY_HERE';
  final Datacontroller _datacontroller = Datacontroller();

  @override
  void initState() {
    super.initState();

    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    loadVideoDetails();

    _progressTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (_youtubePlayerController.value.isPlaying) {
        _saveProgress();
      }
    });
  }

  Future<void> loadVideoDetails() async {
    final videoId = widget.videoId;
    final isar = await _isarController.isar;

    final localVideo =
        await isar.videos.filter().videoIdEqualTo(videoId).findFirst();

    final data = await _datacontroller.fetchVideoDetails(videoId);
    if (data == null) return;

    int watched = 0;

    if (localVideo == null) {
      final data = await _datacontroller.fetchVideoDetails(videoId);

      final video =
          Video()
            ..videoId = videoId
            ..watchedDuration = 0
            ..lastWatched = DateTime.now()
            ..totalDuration = 0
            ..isWatched = false
            ..title = data?['title']
            ..thumbnailUrl = data?['thumbnailUrl']
            ..channelTitle = data?['channelTitle'];

      await isar.writeTxn(() async => await isar.videos.put(video));
    } else {
      watched = localVideo.watchedDuration;
    }

    setState(() {
      _videoData = {
        ...data,
        'watchedDuration': watched,
        'totalDuration': localVideo?.totalDuration ?? 0,
        'isWatched': localVideo?.isWatched ?? false,
      };
    });

    // ✅ Auto-seek after metadata is ready
    _youtubePlayerController.addListener(() {
      if (_youtubePlayerController.value.isReady &&
          watched > 0 &&
          _youtubePlayerController.value.position.inSeconds == 0) {
        _youtubePlayerController.seekTo(Duration(seconds: watched));
      }
    });
  }

  Future<void> _saveProgress({
    String? title,
    String? thumbnailUrl,
    String? channelTitle,
  }) async {
    final watched = _youtubePlayerController.value.position.inSeconds;
    final total = _youtubePlayerController.metadata.duration.inSeconds;

    await _isarController.updateVideoProgress(
      widget.videoId,
      watchedDuration: watched,
      totalDuration: total,
      isWatched: watched >= total - 5,
      title: title,
      thumbnailUrl: thumbnailUrl,
      channelTitle: channelTitle,
    );
  }

  @override
  void dispose() {
    _saveProgress(); // Final save
    _progressTimer?.cancel();
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _videoData;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          data?['title'] ?? 'Loading...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body:
          data == null
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: YoutubePlayer(
                          controller: _youtubePlayerController,
                          showVideoProgressIndicator: true,
                        ),
                      ),

                      SizedBox(height: 20),
                      Row(
                        spacing: 0,
                        children: [
                          Expanded(child: SizedBox()),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.thumb_up, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.watch_later, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.menu_open_rounded),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        data['title'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'By ${data['channelTitle'] ?? "Unknown"}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Published on ${data['publishedAt'].toString().split("T")[0]}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _descriptionExpanded = !_descriptionExpanded;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    _descriptionExpanded
                                        ? data['description']
                                        : (data['description'] as String)
                                                .length >
                                            200
                                        ? data['description'].substring(
                                              0,
                                              200,
                                            ) +
                                            '... '
                                        : data['description'],
                                style: TextStyle(color: Colors.white),
                              ),
                              if ((data['description'] as String).length > 200)
                                TextSpan(
                                  text:
                                      _descriptionExpanded
                                          ? 'Show less'
                                          : 'Read more',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
    );
  }
}
