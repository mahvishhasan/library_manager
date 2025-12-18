import 'package:hive/hive.dart';
part 'book.g.dart';



@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String author;

  @HiveField(2)
  String genre;

  @HiveField(3)
  String barcode;

  Book({
    required this.title,
    required this.author,
    required this.genre,
    this.barcode = '',
  });
}
