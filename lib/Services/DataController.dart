import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Datacontroller extends GetxController {
  final String apiKey =
      'AIzaSyDAP2BqUnyoobIRCUbwVqVUyiULVdAYa5I'; // Replace with your key

  Future<List<Map<String, String>>> getVideoData(String collection) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(collection).get();

    List<Map<String, String>> videos = [];

    for (var doc in snapshot.docs) {
      final url = doc['url'];
      final videoId = _extractYoutubeVideoId(url);
      if (videoId != null) {
        final metadata = await _fetchVideoMetadata(videoId);
        if (metadata != null) {
          videos.add({
            'id': videoId,
            'url': url,
            'thumbnail': 'https://img.youtube.com/vi/$videoId/0.jpg',
            'title': metadata['title'] ?? 'Unknown',
            'creator': metadata['channelTitle'] ?? 'Unknown',
            'description': metadata['description'] ?? 'None',
            'publishedAt': metadata['publishedAt'] ?? 'Unknown',
          });
        }
      }
    }

    return videos;
  }

  Future<Map<String, String>?> _fetchVideoMetadata(String videoId) async {
    final videoUrl =
        'https://www.googleapis.com/youtube/v3/videos?part=snippet&id=$videoId&key=$apiKey';

    final videoResponse = await http.get(Uri.parse(videoUrl));
    if (videoResponse.statusCode == 200) {
      final videoData = json.decode(videoResponse.body);
      if (videoData['items'] != null && videoData['items'].isNotEmpty) {
        final snippet = videoData['items'][0]['snippet'];
        final title = snippet['title']?.toString() ?? 'No Title';
        final channelId = snippet['channelId'];
        final description = snippet['description'];
        final publishedAt = snippet['publishedAt'];

        // 🔁 Now make a second call to get the channel title
        final channelTitle = await _getChannelTitle(channelId);

        return {
          'title': title,
          'channelTitle': channelTitle ?? 'Unknown Creator',
          'description': description ?? "None",
          'publishedAt': publishedAt ?? "Unknown",
        };
      }
    } else {
      print('Failed to fetch video metadata');
    }
    return null;
  }

  Future<String?> _getChannelTitle(String channelId) async {
    final channelUrl =
        'https://www.googleapis.com/youtube/v3/channels?part=snippet&id=$channelId&key=$apiKey';

    final response = await http.get(Uri.parse(channelUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        return data['items'][0]['snippet']['title']?.toString();
      } else {
        print('No channel data found for channelId: $channelId');
      }
    } else {
      print('Failed to fetch channel metadata');
    }
    return null;
  }

  String? _extractYoutubeVideoId(String url) {
    try {
      Uri uri = Uri.parse(url);
      if (uri.host.contains("youtu.be")) {
        return uri.pathSegments.first;
      } else if (uri.queryParameters.containsKey("v")) {
        return uri.queryParameters["v"];
      }
    } catch (e) {
      print('Invalid URL: $url');
    }
    return null;
  }
}
