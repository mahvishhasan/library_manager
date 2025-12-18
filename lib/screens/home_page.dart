import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'library_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1ED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E4DF),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.auto_stories, size: 18, color: Color(0xFF5A5A5A)),
                        SizedBox(width: 8),
                        Text(
                          'Your cozy book companion',
                          style: TextStyle(
                            color: Color(0xFF5A5A5A),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                const Center(
                  child: Text(
                    'ezLib',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                      fontFamily: 'Merriweather',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                const Center(
                  child: Text(
                    'Manage your home library with ease. Scan,\norganize, and discover your book collection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B6B6B),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Features
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeature(Icons.qr_code_scanner, 'QR Scanning'),
                    const SizedBox(width: 40),
                    _buildFeature(Icons.menu_book, 'Smart Categories'),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Your Libraries header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Libraries',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                        fontFamily: 'Merriweather',
                      ),
                    ),
                    Text(
                      '${appState.libraries.length} libraries',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Libraries grid
                appState.libraries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Column(
                            children: const [
                              Icon(Icons.library_books, size: 64, color: Color(0xFFCCC4BA)),
                              SizedBox(height: 16),
                              Text(
                                'No libraries added yet.',
                                style: TextStyle(
                                  color: Color(0xFF8B8B8B),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appState.libraries.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final library = appState.libraries[index];
                          return _buildLibraryCard(context, library, index, appState);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLibraryDialog(context),
        backgroundColor: const Color(0xFFB8845E),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB8845E), size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B6B6B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryCard(BuildContext context, library, int index, AppState appState) {
    final colors = [
      const Color(0xFFE8D5C4),
      const Color(0xFFC8DDD4),
      const Color(0xFFE5D4DB),
      const Color(0xFFD4D9C8),
    ];
    
    final emojis = ['🛋️', '🛏️', '📚', '🏠'];
    
    final color = colors[index % colors.length];
    final emoji = emojis[index % emojis.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LibraryPage(libraryIndex: index)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: library.backgroundImagePath != null ? Colors.white : color,
          borderRadius: BorderRadius.circular(20),
          image: library.backgroundImagePath != null
              ? DecorationImage(
                  image: FileImage(File(library.backgroundImagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            // Emoji in center
            if (library.backgroundImagePath == null)
              Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            // Library info at bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    library.name,
                    style: const TextStyle(
                      fontSize: 20,
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
                      const Icon(Icons.menu_book, size: 14, color: Color(0xFF6B6B6B)),
                      const SizedBox(width: 4),
                      Text(
                        '${library.books.length} books',
                        style: const TextStyle(
                          color: Color(0xFF6B6B6B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu button
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: Color(0xFF6B6B6B)),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  PopupMenuItem(value: 'ChangeBackground', child: Text('Change Background')),
                  PopupMenuItem(value: 'Delete', child: Text('Delete')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLibraryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Create New Library',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Library Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB8845E), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B8B8B))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<AppState>(context, listen: false).addLibrary(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8845E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Rename Library',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB8845E), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B8B8B))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<AppState>(context, listen: false).renameLibrary(index, controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8845E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
    await appState.updateLibraryBackground(index, image.path);
  }
}