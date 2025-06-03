import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Datacontroller extends GetxController {
  final String apiKey =
      'AIzaSyDAP2BqUnyoobIRCUbwVqVUyiULVdAYa5I'; // Replace with your key

  Future<List<Map<String, String>>> searchYoutube(
    String query, {
    String? pageT,
  }) async {
    final searchUrl =
        "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=20&q=${Uri.encodeQueryComponent(query)}&key=$apiKey";

    final searchResponse = await http.get(Uri.parse(searchUrl));

    if (searchResponse.statusCode != 200) {
      print('Failed to search videos');
      return [];
    }

    final searchData = json.decode(searchResponse.body);
    print(searchData);
    final items = searchData['items'];

    List<String> videoIds = [];
    Map<String, dynamic> videoSnippets = {};

    for (var item in items) {
      final videoId = item['id']['videoId'];
      if (videoId != null) {
        videoIds.add(videoId);
        videoSnippets[videoId] = item['snippet'];
      }
    }

    // Step 2: Get video durations
    final detailsUrl =
        'https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=${videoIds.join(",")}&key=$apiKey';

    final detailsResponse = await http.get(Uri.parse(detailsUrl));

    if (detailsResponse.statusCode != 200) {
      print('Failed to fetch video details');
      return [];
    }

    final detailsData = json.decode(detailsResponse.body);
    final List<Map<String, String>> filteredResults = [];

    for (var item in detailsData['items']) {
      final id = item['id'];
      final duration =
          item['contentDetails']['duration']; // ISO 8601 format (e.g., PT58S, PT3M10S)

      final seconds = _parseDuration(duration);
      if (seconds >= 60) {
        final snippet = videoSnippets[id];
        filteredResults.add({
          'id': id,
          'title': snippet['title'],
          'thumbnail': snippet['thumbnails']['high']['url'],
          'creator': snippet['channelTitle'],
          'description': snippet['description'],
          'publishedAt': snippet['publishedAt'],
          'url': 'https://www.youtube.com/watch?v=$id',
        });
      }
    }

    return filteredResults;
  }

  // Utility to parse ISO 8601 durations
  int _parseDuration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return 0;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }
}
