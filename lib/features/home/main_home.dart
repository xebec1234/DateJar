import 'package:flutter/material.dart';
import '../../core/utils/navigation.dart';
import 'navigation_tab.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

    // Secure storage instance
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

    // Check if token exists, otherwise redirect to login
  void _checkToken() async {
    final token = await storage.read(key: 'token');
    print("Token found: $token");
    if (token == null) {
      // No token found, navigate to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = getNavigationPages();

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
