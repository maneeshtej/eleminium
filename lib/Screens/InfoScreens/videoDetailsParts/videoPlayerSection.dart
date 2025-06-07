import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerSection extends StatelessWidget {
  final YoutubePlayerController controller;
  final VoidCallback toggleFullscreen;
  final bool isFullscreen;
  final VoidCallback toggleSidePanel;

  const VideoPlayerSection({
    super.key,
    required this.controller,
    required this.toggleFullscreen,
    required this.isFullscreen,
    required this.toggleSidePanel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        topActions: [
          IconButton(onPressed: toggleSidePanel, icon: Icon(Icons.menu)),
        ],
        bottomActions: [
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white),
            onPressed: () {
              final pos = controller.value.position;
              controller.seekTo(pos - const Duration(seconds: 10));
            },
          ),
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white),
            onPressed: () {
              final pos = controller.value.position;
              controller.seekTo(pos + const Duration(seconds: 10));
            },
          ),
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          IconButton(
            icon: Icon(
              isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: toggleFullscreen,
          ),
        ],
      ),
    );
  }
}
