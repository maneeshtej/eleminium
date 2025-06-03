import 'package:isar/isar.dart';

part 'video.g.dart';

@Collection()
class Video {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String videoId; // YouTube video ID

  late int watchedDuration; // Seconds watched
  late int totalDuration; // Total video duration (optional)

  late DateTime lastWatched; // Last watched time

  bool isWatched = false;

  // ✅ Cache metadata
  String? title;
  String? thumbnailUrl;
  String? channelTitle;
}
