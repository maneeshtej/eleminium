import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Datacontroller extends GetxController {
  final String apiKey =
      'AIzaSyDAP2BqUnyoobIRCUbwVqVUyiULVdAYa5I'; // Replace with your key

  // Title prefix to exclude// <-- You can change this

  Future<Map<String, dynamic>> searchYoutube(
    String query, {
    String? pageToken,
  }) async {
    final searchUrl =
        "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=50&q=${Uri.encodeQueryComponent(query)}&key=$apiKey${pageToken != null ? '&pageToken=$pageToken' : ''}";

    final searchResponse = await http.get(Uri.parse(searchUrl));

    if (searchResponse.statusCode != 200) {
      print('Failed to search videos');
      return {'results': [], 'nextPageToken': null};
    }

    final searchData = json.decode(searchResponse.body);
    final items = searchData['items'];
    final nextPage = searchData['nextPageToken'];

    List<String> videoIds = [];
    Map<String, dynamic> videoSnippets = {};

    for (var item in items) {
      final videoId = item['id']['videoId'];
      if (videoId != null) {
        videoIds.add(videoId);
        videoSnippets[videoId] = item['snippet'];
      }
    }

    if (videoIds.isEmpty) return {'results': [], 'nextPageToken': nextPage};

    final detailsUrl =
        'https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=${videoIds.join(",")}&key=$apiKey';

    final detailsResponse = await http.get(Uri.parse(detailsUrl));

    if (detailsResponse.statusCode != 200) {
      print('Failed to fetch video details');
      return {'results': [], 'nextPageToken': nextPage};
    }

    final detailsData = json.decode(detailsResponse.body);
    final List<Map<String, String>> filteredResults = [];

    for (var item in detailsData['items']) {
      final id = item['id'];
      final durationStr = item['contentDetails']['duration'];
      final durationSeconds = _parseDuration(durationStr ?? '0');

      if (durationSeconds >= 60) {
        final snippet = videoSnippets[id];
        filteredResults.add({
          'id': id,
          'title': snippet['title'],
          'thumbnail':
              snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['medium']?['url'] ??
              snippet['thumbnails']?['default']?['url'] ??
              '',

          'creator': snippet['channelTitle'],
          // 'description': snippet['description'],
          'publishedAt': snippet['publishedAt'],
          'duration': durationSeconds.toString(),
          'url': 'https://www.youtube.com/watch?v=$id',
        });
      }
    }

    return {'results': filteredResults, 'nextPageToken': nextPage};
  }

  int _parseDuration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return 0;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  Future<Map<String, dynamic>?> fetchVideoDetails(String videoId) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/videos?part=snippet&id=$videoId&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'];

      if (items != null && items.isNotEmpty) {
        // print(items[0]['snippet']['thumbnails']);
        return items[0]['snippet'];
      } else {
        print("No video data found.");
        return null;
      }
    } else {
      print('Failed to fetch video details: ${response.statusCode}');
      return null;
    }
  }
}
