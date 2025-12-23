import 'package:flutter/material.dart';

class AppTheme {
  // Reusable main gradient
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.27, 1.0],
    colors: [
      Color(0xFFFFFFFF), // top 27%
      Color(0xFFE0EFF4), // bottom
    ],
  );
}
