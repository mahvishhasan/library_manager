
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'library_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import '../screens/splash_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
    appBar: PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: AppBar(
    title: Container(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  decoration: BoxDecoration(
    color: const Color(0xFF3B2314).withOpacity(0.55), // brown @ ~55 % opacity
    borderRadius: BorderRadius.circular(24),
  ),
  child: const Text(
    'my libraries',
    style: TextStyle(color: Color(0xFFFFD7A0)),
  ),
),
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
),
extendBodyBehindAppBar: true,


      body: Stack(
  children: [
    Positioned.fill(
      child: Image.asset(
        'assets/splash/frame2.jpg',
        fit: BoxFit.cover,
      ),
    ),
    Positioned.fill(child: Container(color:Colors.black.withOpacity(0.4)),),
    Padding(
      padding: const EdgeInsets.all(16),
      child: appState.libraries.isEmpty
          ? const Center(
              child: Text(
                'No libraries added yet.',
                style: TextStyle(color: Color(0xFF8B6E4E)),
              ),
            )
          : GridView.builder(
    itemCount: appState.libraries.length,
    padding: const EdgeInsets.fromLTRB(20, 100, 20, 20), // space below transparent AppBar
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 24,
      childAspectRatio: 0.85,
    ),
    itemBuilder: (context, index) {
      final library = appState.libraries[index];
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LibraryPage(libraryIndex: index)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: library.backgroundImagePath != null
                ? DecorationImage(
                    image: FileImage(File(library.backgroundImagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
            color: library.backgroundImagePath == null
                ? const Color(0xFF8B6E4E).withOpacity(0.9)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),

  
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  library.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFEAE0D5),
                    fontFamily: 'Merriweather',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<String>(
                  color: const Color(0xFF3B2314),
                  iconColor: const Color(0xFFEAE0D5),
                  onSelected: (value) {
                  if (value == 'Rename') {
                    _showRenameDialog(context, index, library.name);
                  } else if (value == 'Delete') {
                    appState.deleteLibrary(index);
                  } else if (value == 'ChangeBackground') {
                    _pickImageForLibrary(context, index);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'Rename', child: Text('Rename')),
                  PopupMenuItem(value: 'Delete', child: Text('Delete')),
                  PopupMenuItem(value: 'ChangeBackground', child: Text('Change Background')),
                ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),

    ),
  ],
),


      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLibraryDialog(context),
        backgroundColor: const Color(0xFF8B6E4E),
        child: const Icon(Icons.add, color: Color(0xFFEAE0D5)),
      ),
    );
  }

  void _showAddLibraryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF3B2314),
        title: const Text('Create New Library', style: TextStyle(color: Color(0xFFEAE0D5))),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Library Name'),
          style: const TextStyle(color: Color(0xFFEAE0D5)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<AppState>(context, listen: false).addLibrary(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, int index, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF3B2314),
        title: const Text('Rename Library', style: TextStyle(color: Color(0xFFEAE0D5))),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Name'),
          style: const TextStyle(color: Color(0xFFEAE0D5)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<AppState>(context, listen: false).renameLibrary(index, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    
  }

  
  
}


Future<void> _pickImageForLibrary(BuildContext context, int index) async {
  final appState = Provider.of<AppState>(context, listen: false); 
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    appState.updateLibraryBackground(index, image.path);
  }
}

/*

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/book.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _filteredBooks = appState.libraries.expand((lib) => lib.books).toList();
  }

  void _filterBooks(String query) {
    final appState = Provider.of<AppState>(context, listen: false);
    final allBooks = appState.libraries.expand((lib) => lib.books).toList();
    setState(() {
      _filteredBooks = allBooks.where((book) {
        final lowerQuery = query.toLowerCase();
        return book.title.toLowerCase().contains(lowerQuery) ||
            book.author.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: const Text('my libraries',
              style: TextStyle(color: Color(0xFF8B6E4E))),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/splash/frame2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search title or author...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  onChanged: _filterBooks,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = _filteredBooks[index];
                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text(book.author),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/