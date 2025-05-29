import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDetails extends StatefulWidget {
  final Map<String, String> video;
  const VideoDetails({super.key, required this.video});

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails> {
  bool _descriptionExpanded = false;
  bool _isPlaying = false;
  late YoutubePlayerController _youtubePlayerController;
  late String _videoID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _videoID = YoutubePlayer.convertUrlToId(widget.video['url'] ?? '')!;
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: _videoID,
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.video['title'] ?? '',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (_isPlaying == true)
                  ? YoutubePlayer(
                    controller: _youtubePlayerController,
                    showVideoProgressIndicator: true,
                  )
                  : Hero(
                    tag: widget.video['id']!,
                    child: Image.network(
                      widget.video['thumbnail']!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
              SizedBox(height: 20),
              MaterialButton(
                color: Colors.grey.shade900,
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                child: Text(
                  "Play Video",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),

              SizedBox(height: 20),
              Text(
                widget.video['title'] ?? "None",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "By ${widget.video['creator'] ?? "Unknown"}",
                style: TextStyle(color: Colors.grey.shade400),
              ),
              SizedBox(height: 2),
              Text(
                (widget.video['publishedAt'] != null)
                    ? "Published on ${widget.video['publishedAt']?.split('T')[0]}"
                    : "Unknown",
                style: TextStyle(color: Colors.grey.shade400),
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
                            !_descriptionExpanded
                                ? (widget.video['description']?.substring(
                                          0,
                                          200,
                                        ) ??
                                        '') +
                                    '... '
                                : widget.video['description'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      if ((widget.video['description']?.length ?? 0) > 200)
                        TextSpan(
                          text:
                              _descriptionExpanded ? 'Show less' : 'Read more',
                          style: const TextStyle(
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
