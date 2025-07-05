import 'package:hive/hive.dart';
import '../models/library.dart';

class DatabaseService {
  static const String libraryBoxName = 'librariesBox';

  Future<void> saveLibraries(List<Library> libraries) async {
    final box = await Hive.openBox<Library>(libraryBoxName);
    await box.clear(); // overwrite for now
    await box.addAll(libraries);
    await box.close();
  }

  Future<List<Library>> loadLibraries() async {
    final box = await Hive.openBox<Library>(libraryBoxName);
    final libraries = box.values.toList();
    await box.close();
    return libraries;
  }
}
