import 'package:flutter/material.dart';
import 'package:sendit/screens/FavoritesScreen.dart';
import 'package:sendit/screens/ReorderScreen.dart';
import 'package:sendit/screens/home_screen.dart';
import 'package:sendit/screens/settingscreen.dart';
import 'package:sendit/widgets/FloatingCartButton.dart';
// Import new widget

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoritesScreen(),
    const ReorderScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Page Content
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // The Floating Cart (Only show on Home, Favorites, Reorder)
          // Home=0, Favorites=1, Reorder=2. Settings=3.
          if (_currentIndex < 3)
            const FloatingCartButton(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5)
              )
            ]
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.15),
          elevation: 0,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'
            ),
            NavigationDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: 'Favorites'
            ),
            NavigationDestination(
                icon: Icon(Icons.history),
                selectedIcon: Icon(Icons.history),
                label: 'Reorder'
            ),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings'
            ),
          ],
        ),
      ),
    );
  }
}