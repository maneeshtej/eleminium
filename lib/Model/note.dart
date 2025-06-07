import 'package:isar/isar.dart';

part 'note.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;

  @Index()
  late String videoId;

  late String note;

  @Index()
  late int timestamp; // e.g., milliseconds since epoch

  @Index()
  DateTime createdAt = DateTime.now();

  List<String> imagePaths = [];

  @Index() // optional, might not improve much
  bool isSynced = false;
}
