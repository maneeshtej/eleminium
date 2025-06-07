import 'package:isar/isar.dart';

part 'notes.g.dart';

@Collection()
class Notes {
  Id id = Isar.autoIncrement;

  @Index()
  late String videoId;

  late String note;

  @Index()
  late int timestamp;

  @Index()
  DateTime createdAt = DateTime.now();

  List<String> imagePaths = [];

  @Index()
  bool isSynced = false;
}
