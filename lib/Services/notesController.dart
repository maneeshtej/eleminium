import 'package:course_app/Model/notes.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class NotesController extends GetxController {
  late final Future<Isar> isar;

  @override
  void onInit() {
    super.onInit();
    isar = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([NotesSchema], directory: dir.path);
  }

  // --------------------------------------
  // ---------  ADDING NOTES --------------
  // --------------------------------------

  Future<void> addNotes(
    String videoId,
    String note,
    int timestamp,
    List<String>? imagePaths,
  ) async {
    final isar = await this.isar;

    final alreadyExists =
        await isar.notes
            .filter()
            .videoIdEqualTo(videoId)
            .timestampEqualTo(timestamp)
            .findFirst();

    if (alreadyExists != null) return;

    final notes =
        Notes()
          ..videoId = videoId
          ..note = note
          ..timestamp = timestamp
          ..imagePaths = imagePaths ?? [''];

    await isar.writeTxn(() async {
      isar.notes.put(notes);
    });
  }
}
