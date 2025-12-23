import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientTab extends StatelessWidget {
  final Widget child;
  const GradientTab({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.mainBackgroundGradient,
      ),
      child: SafeArea(
        top: true, // protects from status bar
        bottom: false, // bottom nav already handled elsewhere
        child: child,
      ),
    );
  }
}
