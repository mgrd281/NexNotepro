import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/memory_spaces_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/add_note_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ),
  );
  runApp(const NexNoteApp());
}

class NexNoteApp extends StatelessWidget {
  const NexNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotesProvider()..seedSampleData(),
      child: MaterialApp(
        title: 'NexNote',
        debugShowCheckedModeBanner: false,
        theme: NexTheme.light,
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    TimelineScreen(),
    MemorySpacesScreen(),
    InsightsScreen(),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _onAddPressed() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const AddNoteScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NexBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        onAddPressed: _onAddPressed,
      ),
    );
  }
}
