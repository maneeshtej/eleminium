import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:course_app/Services/isarController.dart';
import 'package:course_app/Screens/Helpers/addPlaylistPage.dart';

class VideoMetaSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final String videoId;

  const VideoMetaSection({
    super.key,
    required this.data,
    required this.videoId,
  });

  @override
  State<VideoMetaSection> createState() => _VideoMetaSectionState();
}

class _VideoMetaSectionState extends State<VideoMetaSection> {
  final _isarController = Get.find<Isarcontroller>();
  bool isLiked = false;
  bool isWatchLater = false;
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeStates();
  }

  Future<void> _initializeStates() async {
    isLiked = await _isarController.isLiked(widget.videoId);
    isWatchLater = await _isarController.isWatchLater(widget.videoId);
    setState(() {});
  }

  Future<void> _toggleLiked() async {
    await _isarController.toggleLiked(widget.videoId, widget.data, context);
    final liked = await _isarController.isLiked(widget.videoId);
    setState(() => isLiked = liked);
  }

  Future<void> _toggleWatchLater() async {
    await _isarController.toggleWatchLater(
      widget.videoId,
      widget.data,
      context,
    );
    final watchLater = await _isarController.isWatchLater(widget.videoId);
    setState(() => isWatchLater = watchLater);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final String description = data['description']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(AddPlaylistPage(videoId: widget.videoId, data: data));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Playlist",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _toggleLiked,
              icon: Icon(
                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: isLiked ? Colors.deepPurple.shade300 : Colors.white,
              ),
            ),
            IconButton(
              onPressed: _toggleWatchLater,
              icon: Icon(
                isWatchLater ? Icons.watch_later : Icons.watch_later_outlined,
                color: isWatchLater ? Colors.green.shade500 : Colors.white,
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          data['title'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'By ${data['channelTitle'] ?? "Unknown"}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'Published on ${data['publishedAt']?.toString().split("T").first ?? "Unknown"}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _descriptionExpanded = !_descriptionExpanded;
            });
          },
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text:
                      _descriptionExpanded || description.length <= 200
                          ? description
                          : '${description.substring(0, 200)}... ',
                ),
                if (description.length > 200)
                  TextSpan(
                    text: _descriptionExpanded ? 'Show less' : 'Read more',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
