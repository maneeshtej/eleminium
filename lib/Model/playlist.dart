import 'package:course_app/Enums/playListType.dart';
import 'package:course_app/Model/video.dart';
import 'package:isar/isar.dart';

part 'playlist.g.dart';

@Collection()
class Playlist {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  @enumerated
  late PlaylistType type;

  final videos = IsarLinks<Video>();
}
