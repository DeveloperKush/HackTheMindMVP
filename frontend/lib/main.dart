import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this to pubspec.yaml
import 'screens/scam_screen.dart';
import 'screens/help_screen.dart';
import 'screens/factcheck_screen.dart';

void main() {
  runApp(const RakshakApp());
}

class RakshakApp extends StatelessWidget {
  const RakshakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rakshak AI',
      // Defining a consistent professional theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          primary: const Color(0xFF1A73E8),
          secondary: const Color(0xFF00C853), // Safety Green
          error: const Color(0xFFD32F2F),     // Emergency Red
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.lexendTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ScamScreen(),
    const HelpScreen(),
    const FactCheckScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.shield_outlined, color: Color(0xFF1A73E8), size: 28),
        ),
        title: const Text("Rakshak AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.grey),
            onPressed: () {}, // Future: About/Settings
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int i) {
            setState(() => _currentIndex = i);
          },
          indicatorColor: const Color(0xFF1A73E8).withOpacity(0.1),
          destinations: const [
            NavigationRequest(
              icon: Icon(Icons.security_outlined),
              selectedIcon: Icon(Icons.security, color: Color(0xFF1A73E8)),
              label: "Detect",
            ),
            NavigationRequest(
              icon: Icon(Icons.emergency_share_outlined),
              selectedIcon: Icon(Icons.emergency_share, color: Color(0xFFD32F2F)),
              label: "Recovery",
            ),
            NavigationRequest(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check, color: Color(0xFF00C853)),
              label: "Fact Check",
            ),
          ],
        ),
      ),
    );
  }
}

// Small helper for cleaner code
class NavigationRequest extends NavigationDestination {
  const NavigationRequest({
    super.key,
    required super.icon,
    required super.label,
    super.selectedIcon,
  });
}