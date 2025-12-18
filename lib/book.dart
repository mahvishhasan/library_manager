class Book {
  final int? id;
  final String title;
  final String author;
  final String genre;
  final String? barcode;

  Book({this.id, required this.title, required this.author, required this.genre, this.barcode});

  // Convert a Book object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'barcode': barcode,
    };
  }

  // Convert a Map object into a Book object
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['_id'],
      title: map['title'],
      author: map['author'],
      genre: map['genre'],
      barcode: map['barcode'],
    );
  }
}
