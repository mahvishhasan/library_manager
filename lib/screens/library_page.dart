import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/book.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';


class LibraryPage extends StatefulWidget {
  final int libraryIndex;

  const LibraryPage({super.key, required this.libraryIndex});

  @override
  LibraryPageState createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  String query = '';                   
  @override
  // build
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final library = appState.libraries[widget.libraryIndex];

    // ---------- search filter ----------
    final visibleBooks = query.isEmpty
      ? library.books
      : library.books.where((b) =>
          b.title.toLowerCase().contains(query.toLowerCase()) ||
          b.author.toLowerCase().contains(query.toLowerCase())
        ).toList();
        backgroundColor: const Color(0xFF3B2314);
    return Scaffold(
      backgroundColor: const Color(0xFF8B6E4E).withOpacity(0.9),
      
  appBar: AppBar(
    backgroundColor: const Color.fromARGB(255, 28, 15, 7),
    
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          decoration: InputDecoration(
            fillColor: const Color.fromARGB(255, 28, 15, 7),
            filled: true,
            prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD7A0)),
            hintText: 'Search by title or author',
            hintStyle: const TextStyle(color: Color(0xFFFFD7A0)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: const TextStyle(color: Color(0xFFFFD7A0)),
          onChanged: (value) => setState(() => query = value),
        ),
      ),
    ),
  ),
  // ---------- book list ----------
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemCount: visibleBooks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final book = visibleBooks[index];
          return Card(
            color: const Color(0xFF3B2314),
            child: ListTile(
              title: Text(book.title,
                  style: const TextStyle(color: Color(0xFFEAE0D5))),
              subtitle: Text('${book.author} • ${book.genre}',
                  style: const TextStyle(color: Color(0xFFEAE0D5))),
              trailing: PopupMenuButton<String>(
                color: const Color(0xFF3B2314),
                iconColor: const Color(0xFFFFD7A0),
                onSelected: (value) {
                  if (value == 'Edit') {
                    _showAddOrEditBookDialog(context, widget.libraryIndex,
                        isEdit: true, bookIndex: index, book: book);
                  } else if (value == 'Delete') {
                    appState.deleteBook(widget.libraryIndex, index);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'Edit', child: Text('Edit')),
                  PopupMenuItem(value: 'Delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    ),

    // ---------- add-book / scan FAB ----------
    floatingActionButton: FloatingActionButton(
      onPressed: () =>
          _showAddOrEditBookDialog(context, widget.libraryIndex),
      backgroundColor: const Color(0xFF3B2314),
      child: const Icon(Icons.add, color: Color(0xFFFFD7A0)),
    ),
  );
}

  }

  void _showAddOrEditBookDialog(BuildContext context, int libIndex, {bool isEdit = false, int? bookIndex, Book? book}) {
    final TextEditingController titleController = TextEditingController(text: book?.title ?? '');
    final TextEditingController authorController = TextEditingController(text: book?.author ?? '');
    final TextEditingController genreController = TextEditingController(text: book?.genre ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF3B2314),
        title: Text(isEdit ? 'Edit Book' : 'Add Book', style: const TextStyle(color: Color(0xFFFFD7A0))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                style: const TextStyle(color: Color(0xFFFFD7A0)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                style: const TextStyle(color: Color(0xFFFFD7A0)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: genreController,
                decoration: const InputDecoration(labelText: 'Genre'),
                style: const TextStyle(color: Color(0xFFFFD7A0)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Barcode'),
                onPressed: () async {
                  var result = await BarcodeScanner.scan();
                  if (result.rawContent.isNotEmpty) {
                    _fetchBookInfo(result.rawContent, titleController, authorController, genreController, context);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final newBook = Book(
                title: titleController.text,
                author: authorController.text,
                genre: genreController.text,
              );
              final appState = Provider.of<AppState>(context, listen: false);
              if (isEdit && bookIndex != null) {
                appState.editBook(libIndex, bookIndex, newBook);
              } else {
                appState.addBook(libIndex, newBook);
              }
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchBookInfo(String barcode, TextEditingController titleController, TextEditingController authorController, TextEditingController genreController, BuildContext context) async {
    try {
      final url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$barcode';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['totalItems'] > 0) {
          final bookData = data['items'][0]['volumeInfo'];
          titleController.text = bookData['title'] ?? '';
          authorController.text = (bookData['authors'] as List?)?.join(', ') ?? '';
          genreController.text = (bookData['categories'] as List?)?.join(', ') ?? '';
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No book found for this barcode.')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching book info.')));
    }
  }
