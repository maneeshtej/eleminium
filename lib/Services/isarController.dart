import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:course_app/Model/video.dart'; // your Isar model

class IsarController extends GetxController {
  late final Future<Isar> isar;

  @override
  void onInit() {
    super.onInit();
    isar = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [VideoSchema], // list all your schemas here
      directory: dir.path,
    );
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
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
        video.thumbnailUrl = thumbnailUrl;
      if (channelTitle != null && channelTitle.isNotEmpty)
        video.channelTitle = channelTitle;

      await isar.writeTxn(() async {
        await isar.videos.put(video);
      });
    }
  }
}
