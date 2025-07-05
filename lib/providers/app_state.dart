import 'package:flutter/material.dart';
import '../models/library.dart';
import '../models/book.dart';
import '../services/database_service.dart';

class AppState extends ChangeNotifier {
  List<Library> libraries = [];
  final DatabaseService _dbService = DatabaseService();

  Future<void> loadLibraries() async {
    libraries = await _dbService.loadLibraries();
    notifyListeners();
  }

  Future<void> saveLibraries() async {
    await _dbService.saveLibraries(libraries);
  }

  List<Book> get allBooks {
  return libraries.expand((lib) => lib.books).toList();
}


  void addLibrary(String name) {
    libraries.add(Library(name: name, books: []));
    saveLibraries();
    notifyListeners();
  }

  void renameLibrary(int index, String newName) {
    libraries[index].name = newName;
    saveLibraries();
    notifyListeners();
  }

  void deleteLibrary(int index) {
    libraries.removeAt(index);
    saveLibraries();
    notifyListeners();
  }

  void addBook(int libIndex, Book book) {
    libraries[libIndex].books.add(book);
    saveLibraries();
    notifyListeners();
  }

  void editBook(int libIndex, int bookIndex, Book updatedBook) {
    libraries[libIndex].books[bookIndex] = updatedBook;
    saveLibraries();
    notifyListeners();
  }

  void deleteBook(int libIndex, int bookIndex) {
    libraries[libIndex].books.removeAt(bookIndex);
    saveLibraries();
    notifyListeners();
  }
  void updateLibraryBackground(int index, String imagePath) {
  libraries[index].backgroundImagePath = imagePath;
  notifyListeners();
}

}
