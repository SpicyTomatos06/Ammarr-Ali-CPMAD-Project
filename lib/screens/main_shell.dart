import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import 'waste_guide_page.dart';
import 'locations_page.dart';
import 'reminders_page.dart';
import 'tips_page.dart';
import 'profile_page.dart';
import 'about_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    WasteGuidePage(),
    LocationsPage(),
    RemindersPage(),
    TipsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('SmartRecycle SG')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text('SmartRecycle SG', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await auth.signOut();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.recycling), label: 'Guide'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Locations'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Reminders'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Tips'),
        ],
      ),
    );
  }
}
