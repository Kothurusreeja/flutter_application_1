import 'package:flutter/material.dart';

import 'screens/discover_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const VibeTuneApp());
}

class VibeTuneApp extends StatefulWidget {
  const VibeTuneApp({super.key});

  @override
  State<VibeTuneApp> createState() => _VibeTuneAppState();
}

class _VibeTuneAppState extends State<VibeTuneApp> {
  bool isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VibeTune',
      theme: isDarkMode ? AppTheme.dark() : AppTheme.light(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainNavigationScreen(
        onThemeToggle: _toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const MainNavigationScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const DiscoverScreen(),
      const FavoritesScreen(),
      ProfileScreen(
        onThemeToggle: widget.onThemeToggle,
        isDarkMode: widget.isDarkMode,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF15151E),
        indicatorColor: const Color(0xFF2C2145),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
