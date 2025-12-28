import 'package:flutter/material.dart';
import '../../core/utils/navigation.dart';

import './home_screen.dart';
import '../calendar/calendar_screen.dart';
import '../chat/chat_screen.dart';
import '../account/account_screen.dart';
import '../../core/widgets/gradient_tab.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final storage = const FlutterSecureStorage();

  // Store pages here so they are not rebuilt
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _checkToken();

    // Initialize pages only once
    _pages = [
    GradientTab(child: const HomeScreen()),
    GradientTab(child: const CalendarScreen()),
    GradientTab(child: const ChatScreen()),
    GradientTab(child: const AccountScreen()),
    ];
  }

  void _checkToken() async {
    final token = await storage.read(key: 'token');
    print("Token found: $token");
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages, // keeps each page alive
      ),
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
