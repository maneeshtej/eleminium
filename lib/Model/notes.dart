import 'package:isar/isar.dart';

part 'notes.g.dart';

@Collection()
class Notes {
  Id id = Isar.autoIncrement;

  late String videoId;
  late String note;
  late int timestamp;
  DateTime createdAt = DateTime.now();

  List<String> imagePaths = [];
  bool isSynced = false;
}
