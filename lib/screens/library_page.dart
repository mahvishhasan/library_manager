import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/book.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/barcode_service.dart';

class LibraryPage extends StatefulWidget {
  final int libraryIndex;

  const LibraryPage({super.key, required this.libraryIndex});

  @override
  LibraryPageState createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  String query = '';
  bool showByGenre = true;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final library = appState.libraries[widget.libraryIndex];

    final visibleBooks = query.isEmpty
        ? library.books
        : library.books
            .where((b) =>
                b.title.toLowerCase().contains(query.toLowerCase()) ||
                b.author.toLowerCase().contains(query.toLowerCase()))
            .toList();

    // Group by genre
    Map<String, List<Book>> booksByGenre = {};
    for (var book in visibleBooks) {
      final genre = book.genre.isEmpty ? 'Uncategorized' : book.genre;
      booksByGenre.putIfAbsent(genre, () => []);
      booksByGenre[genre]!.add(book);
    }

    // Group by author
    Map<String, List<Book>> booksByAuthor = {};
    for (var book in visibleBooks) {
      final author = book.author.isEmpty ? 'Unknown Author' : book.author;
      booksByAuthor.putIfAbsent(author, () => []);
      booksByAuthor[author]!.add(book);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B6B6B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              _getEmojiForLibrary(widget.libraryIndex),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                library.name,
                style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Browse your collection by category',
                style: TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              
              // Toggle buttons
              Row(
                children: [
                  _buildToggleButton('By Genre', Icons.menu_book, showByGenre, () {
                    setState(() => showByGenre = true);
                  }),
                  const SizedBox(width: 12),
                  _buildToggleButton('By Author', Icons.person, !showByGenre, () {
                    setState(() => showByGenre = false);
                  }),
                ],
              ),
              const SizedBox(height: 32),
              
              // Category cards
              if (showByGenre)
                _buildGenreView(booksByGenre, visibleBooks.length)
              else
                _buildAuthorView(booksByAuthor, visibleBooks.length),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditBookDialog(context, widget.libraryIndex),
        backgroundColor: const Color(0xFFB8845E),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildToggleButton(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFB8845E) : const Color(0xFFE8E4DF),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF6B6B6B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreView(Map<String, List<Book>> booksByGenre, int totalBooks) {
    final genreIcons = {
      'Fiction': '✨',
      'Mystery': '🔍',
      'Romance': '💕',
      'Sci-Fi': '🚀',
      'Non-Fiction': '📖',
      'Fantasy': '🐉',
      'Thriller': '🔪',
      'History': '🏛️',
    };

    return Column(
      children: [
        _buildCategoryCard(
          '📚',
          'All Books',
          totalBooks,
          const Color(0xFFE8D5C4),
          () => _showBookList(context, 'All Books', booksByGenre.values.expand((e) => e).toList()),
        ),
        const SizedBox(height: 16),
        ...booksByGenre.entries.map((entry) {
          final genre = entry.key;
          final books = entry.value;
          final emoji = genreIcons[genre] ?? '📕';
          final color = _getColorForCategory(genre);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCategoryCard(
              emoji,
              genre,
              books.length,
              color,
              () => _showBookList(context, genre, books),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAuthorView(Map<String, List<Book>> booksByAuthor, int totalBooks) {
    return Column(
      children: booksByAuthor.entries.map((entry) {
        final author = entry.key;
        final books = entry.value;
        final color = _getColorForCategory(author);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCategoryCard(
            '👤',
            author,
            books.length,
            color,
            () => _showBookList(context, author, books),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, int count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                      fontFamily: 'Merriweather',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count book${count == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB8845E)),
          ],
        ),
      ),
    );
  }

  void _showBookList(BuildContext context, String category, List<Book> books) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookListPage(
          category: category,
          books: books,
          libraryIndex: widget.libraryIndex,
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    final colors = [
      const Color(0xFFE8D5C4),
      const Color(0xFFC8DDD4),
      const Color(0xFFE5D4DB),
      const Color(0xFFD4D9C8),
      const Color(0xFFDFD5E8),
    ];
    return colors[category.hashCode % colors.length];
  }

  String _getEmojiForLibrary(int index) {
    final emojis = ['🛋️', '🛏️', '📚', '🏠'];
    return emojis[index % emojis.length];
  }

  void _showAddOrEditBookDialog(
    BuildContext context,
    int libIndex, {
    bool isEdit = false,
    int? bookIndex,
    Book? book,
  }) {
    final TextEditingController titleController =
        TextEditingController(text: book?.title ?? '');
    final TextEditingController authorController =
        TextEditingController(text: book?.author ?? '');
    final TextEditingController genreController =
        TextEditingController(text: book?.genre ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? 'Edit Book' : 'Add Book',
          style: const TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFB8845E), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFB8845E), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: genreController,
                decoration: InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFB8845E), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Barcode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8845E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  final BookScan? res = await scanWithCamera(context);
                  if (res == null) return;

                  final String digits = res.normalized.replaceAll(RegExp(r'\D'), '');
                  final bool isIsbn13 = RegExp(r'^(978|979)\d{10}$').hasMatch(digits);

                  if (isIsbn13) {
                    if (!context.mounted) return;
                    await _fetchBookInfo(digits, titleController, authorController, genreController, context);
                  } else {
                    if (!context.mounted) return;
                    final fmt = res.format.toString().split('.').last;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scanned library ID ($fmt): ${res.raw}')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B8B8B))),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a title')),
                );
                return;
              }

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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8845E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchBookInfo(
    String barcode,
    TextEditingController titleController,
    TextEditingController authorController,
    TextEditingController genreController,
    BuildContext context,
  ) async {
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

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book info loaded successfully!')),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No book found for this barcode.')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching book info.')),
        );
      }
    }
  }
}

// Book List Page (shown when clicking a category)
class BookListPage extends StatefulWidget {
  final String category;
  final List<Book> books;
  final int libraryIndex;

  const BookListPage({
    super.key,
    required this.category,
    required this.books,
    required this.libraryIndex,
  });

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    final filteredBooks = query.isEmpty
        ? widget.books
        : widget.books
            .where((b) =>
                b.title.toLowerCase().contains(query.toLowerCase()) ||
                b.author.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B6B6B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Merriweather',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${filteredBooks.length} book${filteredBooks.length == 1 ? '' : 's'} in this category',
              style: const TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8B8B8B)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 24),
            
            // Book list
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  final globalIndex = appState.libraries[widget.libraryIndex].books.indexOf(book);
                  
                  return _buildBookCard(context, book, globalIndex, appState);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFFB8845E),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, int bookIndex, AppState appState) {
    final colors = [
      const Color(0xFFE5D4DB),
      const Color(0xFFD4B496),
      const Color(0xFF8FA6BC),
    ];
    final color = colors[book.title.hashCode % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                    fontFamily: 'Merriweather',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Color(0xFF8B8B8B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        book.author,
                        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E4DF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.genre.isEmpty ? 'No genre' : book.genre,
                        style: const TextStyle(
                          color: Color(0xFF6B6B6B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF8B8B8B)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'Delete') {
                appState.deleteBook(widget.libraryIndex, bookIndex);
                Navigator.pop(context); // Go back if list is now empty
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    // Navigate back to library page to add book
    Navigator.pop(context);
  }
}