import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:library_manager/book.dart'; // Assuming Book class is defined in book.dart

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static late Database _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    // Remove the null check as it's not needed with 'late'
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'library_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE books(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, author TEXT, genre TEXT, libraryName TEXT)',
        );
      },
      version: 1,
    );
  }

  // Insert a new book into the database
  Future<void> insertBook(Map<String, dynamic> bookMap) async {
    final db = await database;
    await db.insert(
      'books',
      bookMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch books by library name
  Future<List<Map<String, dynamic>>> fetchBooksByLibrary(String libraryName) async {
    final db = await database;
    return await db.query(
      'books',
      where: 'libraryName = ?',
      whereArgs: [libraryName],
    );
  }

  // Delete a book by its id
  Future<void> deleteBook(int bookId) async {
    final db = await database;
    await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }
}
