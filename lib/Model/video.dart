import 'package:isar/isar.dart';

part 'video.g.dart';

@Collection()
class Video {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String videoId;

  late int watchedDuration;
  late int totalDuration;
  late DateTime lastWatched;

  bool isWatched = false;

  // ✅ Metadata
  String? title;
  String? channelTitle;

  // ✅ Store thumbnail as List<int>
  List<int>? thumbnailBytes;
}
