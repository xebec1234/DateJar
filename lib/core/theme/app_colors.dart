import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4A90E2);
  static const onPrimary = Colors.white;

  static const disabled = Color(0xFFB0BEC5);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.27, 1.0], // top 0% is primary, bottom 100% is lighter shade
    colors: [
      Color(0xFF4A90E2), // primary (top)
      Color.fromARGB(255, 207, 227, 249), // lighter shade (bottom)
    ],
  );
}
