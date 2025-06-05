import 'package:course_app/Model/video.dart';
import 'package:isar/isar.dart';

part 'playlist.g.dart';

@Collection()
class Playlist {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String playlistName;

  final videos = IsarLinks<Video>();
}
