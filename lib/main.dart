import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'models/book.dart';
import 'models/library.dart';
import 'providers/app_state.dart';
// import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(LibraryAdapter());

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..loadLibraries(),
      child: const LibraryApp(),
    ),
  );
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Manager',
      theme: ThemeData.dark(),
      home: const SplashScreen(),

    );
  }
}
