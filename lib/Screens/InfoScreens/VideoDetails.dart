import 'package:course_app/Services/DataController.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDetails extends StatefulWidget {
  final String videoId; // Now pass just the video ID
  const VideoDetails({super.key, required this.videoId});

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails> {
  bool _descriptionExpanded = false;
  bool _isPlaying = false;
  late YoutubePlayerController _youtubePlayerController;

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
  }

  Future<void> loadVideoDetails() async {
    final data = await _datacontroller.fetchVideoDetails(widget.videoId);
    if (data != null) {
      setState(() {
        _videoData = data;
      });
    }
  }

  @override
  void dispose() {
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
                      _isPlaying
                          ? SizedBox(
                            height: 200,
                            child: YoutubePlayer(
                              controller: _youtubePlayerController,
                              showVideoProgressIndicator: true,
                            ),
                          )
                          : Image.network(
                            data['thumbnails']['maxres']?['url'] ??
                                data['thumbnails']['high']?['url'] ??
                                data['thumbnails']['default']?['url'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                      SizedBox(height: 20),
                      Row(
                        spacing: 0,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPlaying = !_isPlaying;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 17,
                                top: 5,
                                bottom: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Row(
                                children:
                                    (!_isPlaying)
                                        ? [
                                          Icon(Icons.play_arrow),
                                          Text(
                                            "Play",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ]
                                        : [
                                          Icon(Icons.pause),
                                          Text(
                                            "Pause",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                              ),
                            ),
                          ),

                          Expanded(child: SizedBox()),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.thumb_up, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.watch_later, color: Colors.white),
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
