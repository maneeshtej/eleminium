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
  final _isarController = Get.find<Isarcontroller>();
  Timer? _progressTimer;
  bool isLiked = false;
  bool isWatcherLater = false;

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

    // Call the async initializer
    _checkLikedAndWatchLaterAndPlaylists();

    // Setup periodic progress saving
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_youtubePlayerController.value.isPlaying) {
        _saveProgress();
      }
    });
  }

  Future<void> _checkLikedAndWatchLaterAndPlaylists() async {
    isLiked = await _isarController.isLiked(widget.videoId);
    isWatcherLater = await _isarController.isWatchLater(widget.videoId);

    setState(() {}); // Trigger UI update after values are set
  }

  Future<void> loadVideoDetails() async {
    final videoId = widget.videoId;
    final isar = await _isarController.isar;

    // Fetch fresh data from API
    final data = await _datacontroller.fetchVideoDetails(videoId);

    // Always create or update video in Isar
    final updatedVideo = await _isarController.createOrUpdateVideo(
      videoId,
      data,
      context,
    );

    setState(() {
      _videoData = {
        ...?data,
        'watchedDuration': updatedVideo.watchedDuration,
        'totalDuration': updatedVideo.totalDuration,
        'isWatched': updatedVideo.isWatched,
      };
    });

    // ✅ Auto-seek to last watched position unconditionally
    _youtubePlayerController.addListener(() {
      if (_youtubePlayerController.value.isReady &&
          updatedVideo.watchedDuration > 0 &&
          _youtubePlayerController.value.position.inSeconds == 0) {
        _youtubePlayerController.seekTo(
          Duration(seconds: updatedVideo.watchedDuration),
        );
        _youtubePlayerController.pause();
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

    // Create a map similar to what createOrUpdateVideo expects
    final data = {
      'watchedDuration': watched,
      'totalDuration': total,
      'isWatched': watched >= total - 5,
      if (title != null) 'title': title,
      if (channelTitle != null) 'channelTitle': channelTitle,
      if (thumbnailUrl != null)
        'thumbnails': {
          'high': {'url': thumbnailUrl},
        },
    };

    await _isarController.createOrUpdateVideo(widget.videoId, data, context);
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

                    FutureBuilder(
                      future: _isarController.isar,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || _videoData == null)
                          return SizedBox.shrink();

                        final total =
                            (_videoData?['totalDuration'] ?? 1).toDouble();
                        final watched =
                            (_videoData?['watchedDuration'] ?? 0).toDouble();
                        final progress = (watched / total).clamp(0.0, 1.0);

                        return LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[800],
                          color: Colors.deepPurple,
                          minHeight:
                              (_youtubePlayerController.value.isPlaying)
                                  ? 0
                                  : 4,
                        );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(),
                            child: Row(
                              spacing: 0,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      "Playlist",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                                IconButton(
                                  onPressed: () async {
                                    await _isarController.toggleLiked(
                                      widget.videoId,
                                      data,
                                      context,
                                    );
                                    final liked = await _isarController.isLiked(
                                      widget.videoId,
                                    );
                                    setState(() {
                                      isLiked = liked;
                                    });
                                  },
                                  icon: Icon(
                                    (isLiked)
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 5),
                                IconButton(
                                  onPressed: () async {
                                    await _isarController.toggleWatchLater(
                                      widget.videoId,
                                      data,
                                      context,
                                    );
                                    final watchlater = await _isarController
                                        .isWatchLater(widget.videoId);

                                    setState(() {
                                      isWatcherLater = watchlater;
                                    });
                                  },
                                  icon: Icon(
                                    !isWatcherLater
                                        ? Icons.watch_later_outlined
                                        : Icons.watch_later,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 20),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            data['title'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'By ${data['channelTitle'] ?? "Unknown"}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Published on ${data['publishedAt'].toString().split("T")[0]}',
                              style: TextStyle(color: Colors.grey),
                            ),
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
                                  if ((data['description'] as String).length >
                                      200)
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
                  ],
                ),
              ),
    );
  }
}
