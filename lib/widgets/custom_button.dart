import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool showLogo;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.showLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              onPressed == null ? AppColors.disabled : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showLogo) ...[
              Image.asset(
                'assets/images/datejar-logo.png',
                width: 22,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
