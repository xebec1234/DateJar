import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 0,
      showSelectedLabels: true, // label shows for active tab
      showUnselectedLabels: false, // hide label for inactive tabs
      selectedItemColor: const Color(0xFF3498db), // active color
      unselectedItemColor: const Color.fromRGBO(128, 128, 128, 0.6),
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'CALENDAR',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: 'CHAT',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'ACCOUNT',
        ),
      ],
    );
  }
}
