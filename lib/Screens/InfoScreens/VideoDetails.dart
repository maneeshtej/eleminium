import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_app/Screens/InfoScreens/videoDetailsParts/videoMetaSection.dart';
import 'package:course_app/Screens/InfoScreens/videoDetailsParts/videoNotesSection.dart';
import 'package:course_app/Screens/InfoScreens/videoDetailsParts/videoPlayerSection.dart';
import 'package:course_app/Screens/InfoScreens/videoDetailsParts/videoQuestionsSection.dart';
import 'package:course_app/Services/DataController.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDetails extends StatefulWidget {
  final String videoId; // Now pass just the video ID
  const VideoDetails({super.key, required this.videoId});

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails> {
  late YoutubePlayerController _youtubePlayerController;
  final _isarController = Get.find<Isarcontroller>();
  Timer? _progressTimer;
  bool isLiked = false;
  bool isWatcherLater = false;
  int selectedSection = 0;
  bool isFullscreen = false;
  bool showSidePanel = false;

  Map<String, dynamic>? _videoData;
  final Datacontroller _datacontroller = Datacontroller();

  @override
  void initState() {
    super.initState();

    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    loadVideoDetails();

    int? _lastSavedSecond;

    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final currentSecond = _youtubePlayerController.value.position.inSeconds;
      if (_youtubePlayerController.value.isPlaying &&
          (_lastSavedSecond == null ||
              currentSecond - _lastSavedSecond! >= 10)) {
        _lastSavedSecond = currentSecond;
        _saveProgress();
      }
    });
  }

  void didChangeMetrics() {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      // enter fullscreen
    } else {
      _exitFullscreen();
    }
  }

  Future<void> loadVideoDetails() async {
    final videoId = widget.videoId;

    // Fetch fresh data from API
    final data = await _datacontroller.fetchVideoDetails(videoId);

    // Always create or update video in Isar
    final updatedVideo = await _isarController.createOrUpdateVideo(
      videoId,
      data,
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

    await _createQuestionsSubcollection();
  }

  Future<void> _createQuestionsSubcollection() async {
    final questionsRef = FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.videoId)
        .collection('questions');

    final snapshot = await questionsRef.limit(1).get();

    if (snapshot.docs.isEmpty) {
      await questionsRef.add({
        'question': "be the first one to ask the question",
        'username': 'system',
        'userId': 'system',
        'timestamp': FieldValue.serverTimestamp(),
        'isPlaceHolder': true,
      });
    }
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

    await _isarController.createOrUpdateVideo(widget.videoId, data);
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Optional: hide system overlays for immersive fullscreen
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() => isFullscreen = true);
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Restore system UI overlays
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() => isFullscreen = false);
  }

  void _toggleFullscreen() {
    if (isFullscreen) {
      _exitFullscreen();
    } else {
      _enterFullscreen();
    }
  }

  void _toggleSidePanel() {
    setState(() {
      showSidePanel = !showSidePanel;
    });
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
    final _size = MediaQuery.of(context).size;
    final _aspectRatio = _size.height / _size.width;
    final _aspectRatio2 = _size.width / _size.height;

    return WillPopScope(
      onWillPop: () async {
        if (isFullscreen) {
          await _exitFullscreen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar:
            (isFullscreen)
                ? null
                : AppBar(
                  backgroundColor: Colors.black,
                  title: Text(data?['title'] ?? "Unknown"),
                ),
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Row(
            children: [
              if (isFullscreen)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: showSidePanel ? 350 : 0,
                  color: Colors.black,
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: showSidePanel ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Your toggle buttons inside the panel
                          Container(
                            color: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildToggleButton("Details", 0),
                                _buildToggleButton("Questions", 1),
                                _buildToggleButton("Notes", 2),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24),
                          // Content below toggle buttons
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                if (selectedSection == 0) {
                                  return _videoData != null
                                      ? CustomScrollView(
                                        slivers: [
                                          SliverPadding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                              top: 10,
                                            ),
                                            sliver: SliverToBoxAdapter(
                                              child: VideoMetaSection(
                                                data: _videoData!,
                                                videoId: widget.videoId,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      : const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                } else if (selectedSection == 1) {
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(10),
                                    child: VideoQuestionsSection(
                                      videoId: widget.videoId,
                                      exitFullscreen: _exitFullscreen,
                                    ),
                                  );
                                } else {
                                  return VideoNotesSection(
                                    videoId: widget.videoId,
                                    youtubePlayerController:
                                        _youtubePlayerController,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AspectRatio(
                      aspectRatio:
                          (isFullscreen) ? _aspectRatio2 : _aspectRatio,
                      child: VideoPlayerSection(
                        controller: _youtubePlayerController,
                        toggleFullscreen: _toggleFullscreen,
                        isFullscreen: isFullscreen,
                        toggleSidePanel: _toggleSidePanel,
                      ),
                    ),

                    if (isFullscreen)
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child:
                              showSidePanel
                                  ? Container(
                                    key: ValueKey('panel'),
                                    color: Colors.black,
                                    child: Text('Chapters'),
                                  )
                                  : SizedBox(key: ValueKey('empty')),
                        ),
                      ),

                    // Toggle buttons
                    if (!isFullscreen)
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildToggleButton("Details", 0),
                            _buildToggleButton("Questions", 1),
                            _buildToggleButton("Notes", 2),
                          ],
                        ),
                      ),

                    if (!isFullscreen)
                      Divider(height: 1, color: Colors.white10),

                    if (!isFullscreen)
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (selectedSection == 0) {
                              return data != null
                                  ? CustomScrollView(
                                    slivers: [
                                      SliverPadding(
                                        padding: const EdgeInsets.only(
                                          left: 15,
                                          top: 10,
                                        ),
                                        sliver: SliverToBoxAdapter(
                                          child: VideoMetaSection(
                                            data: data,
                                            videoId: widget.videoId,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : const Center(
                                    child: CircularProgressIndicator(),
                                  );
                            } else if (selectedSection == 1) {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(10),
                                child: VideoQuestionsSection(
                                  videoId: widget.videoId,
                                  exitFullscreen: _exitFullscreen,
                                ),
                              );
                            } else {
                              return VideoNotesSection(
                                videoId: widget.videoId,
                                youtubePlayerController:
                                    _youtubePlayerController,
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, int index) {
    final isSelected = selectedSection == index;
    return TextButton(
      onPressed: () {
        setState(() {
          selectedSection = index;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
