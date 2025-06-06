import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FullscreenVideoPage extends StatefulWidget {
  final YoutubePlayerController controller;

  const FullscreenVideoPage({super.key, required this.controller});

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  double _dragStartY = 0;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _handleDragEnd() {
    if (_dragDistance > 100) {
      Navigator.pop(context);
    } else {
      setState(() {
        _dragStartY = 0;
        _dragDistance = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        _dragStartY = details.globalPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragDistance = details.globalPosition.dy - _dragStartY;
        });
      },
      onVerticalDragEnd: (_) => _handleDragEnd(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: YoutubePlayer(
                controller: widget.controller,
                showVideoProgressIndicator: true,
                topActions: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
                bottomActions: [
                  IconButton(
                    icon: const Icon(
                      Icons.replay_10,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      final pos = widget.controller.value.position;
                      widget.controller.seekTo(
                        pos - const Duration(seconds: 10),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      final pos = widget.controller.value.position;
                      widget.controller.seekTo(
                        pos + const Duration(seconds: 10),
                      );
                    },
                  ),
                  const CurrentPosition(),
                  const ProgressBar(isExpanded: true),
                  const RemainingDuration(),
                ],
              ),
            ),

            // Top back button
          ],
        ),
      ),
    );
  }
}
