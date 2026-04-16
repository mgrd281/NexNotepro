import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/home_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/memory_spaces_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/add_note_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));
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
        theme: Nex.theme,
        home: const _Shell(),
      ),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _tab = 0;

  final _screens = const [
    HomeScreen(),
    TimelineScreen(),
    MemorySpacesScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Nex.bg,
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: NexBottomNav(
        current: _tab,
        onTap: (i) => setState(() => _tab = i),
        onAdd: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddNoteScreen())),
      ),
    );
  }
}
