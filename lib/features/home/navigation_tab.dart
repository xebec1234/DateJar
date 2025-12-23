import 'package:flutter/material.dart';
import './home_screen.dart';
import '../calendar/calendar_screen.dart';
import '../chat/chat_screen.dart';
import '../account/account_screen.dart';
import '../../core/widgets/gradient_tab.dart';

/// Returns the list of pages for HomeScreen
List<Widget> getNavigationPages() {
  return [
    GradientTab(child: const HomeScreen()),  // full home content with top bar
    GradientTab(child: const CalendarScreen()),
    GradientTab(child: const ChatScreen()),
    GradientTab(child: const AccountScreen()),
  ];
}
