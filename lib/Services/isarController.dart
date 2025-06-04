// import 'package:get/get.dart';
// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:course_app/Model/video.dart'; // your Isar model

// class IsarController extends GetxController {
//   late final Future<Isar> isar;

//   @override
//   void onInit() {
//     super.onInit();
//     isar = openDB();
//   }

//   Future<Isar> openDB() async {
//     final dir = await getApplicationDocumentsDirectory();
//     return await Isar.open(
//       [VideoSchema], // list all your schemas here
//       directory: dir.path,
//     );
//   }

import 'package:course_app/Model/video.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class Isarcontroller extends GetxController {
  late final Future<Isar> isar;

  @override
  void onInit() {
    super.onInit();
    isar = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([VideoSchema], directory: dir.path);
  }

  Future<void> createAndStoreVideo(
    String videoId,
    Map<String, dynamic>? data,
  ) async {
    final isarInstance = await isar;

    final video =
        Video()
          ..videoId = videoId
          ..watchedDuration = 0
          ..lastWatched = DateTime.now()
          ..totalDuration = 0
          ..isWatched = false
          ..title = data?['title']
          ..channelTitle = data?['channelTitle']
          ..thumbnailBytes = await fetchThumbnailBytes(
            data?['thumbnails']['default']['url'],
          );

    await isarInstance.writeTxn(() async {
      await isarInstance.videos.put(video);
    });

    // print(data);
  }

  Future<List<int>?> fetchThumbnailBytes(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
      print('Failed to fetch thumbnail: ${response.statusCode}');
    } catch (e) {
      print('Error fetching thumbnail: $e');
    }
    return null;
  }

  Future<void> updateVideoProgress(
    String videoId, {
    required int watchedDuration,
    required int totalDuration,
    required bool isWatched,
    String? title,
    String? thumbnailUrl,
    String? channelTitle,
  }) async {
    final isar = await this.isar;
    final video =
        await isar.videos.filter().videoIdEqualTo(videoId).findFirst();

    if (video != null) {
      video.watchedDuration = watchedDuration;
      video.totalDuration = totalDuration;
      video.isWatched = isWatched;
      video.lastWatched = DateTime.now();

      // Update metadata if provided and not empty
      if (title != null && title.isNotEmpty) video.title = title;
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        video.thumbnailBytes = await fetchThumbnailBytes(thumbnailUrl);
      }
      if (channelTitle != null && channelTitle.isNotEmpty) {
        video.channelTitle = channelTitle;
      }
      await isar.writeTxn(() async {
        await isar.videos.put(video);
      });
    }
  }
}
