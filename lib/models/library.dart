import 'package:hive/hive.dart';
import 'book.dart';

part 'library.g.dart';

@HiveType(typeId: 1)
class Library extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Book> books;

  @HiveField(2)
  String? backgroundImagePath;

  Library({
    required this.name,
    this.books = const [],
    this.backgroundImagePath,
  });
}
