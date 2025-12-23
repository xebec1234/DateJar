import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  // Secure storage instance
  final storage = const FlutterSecureStorage();

  void logout(BuildContext context) async {
    try {
      final token = await storage.read(key: 'token');

      if (token != null) {
        // Call backend logout
        await ApiService.post(
          ApiConstants.logout,
          {}, // no body needed
        );

        print("Backend logout successful");
      }

      // Delete token locally regardless
      await storage.delete(key: 'token');
      print("Token deleted, user logged out");

      // Navigate back to login screen
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error logging out: $e");

      // Optional: still delete token locally if backend fails
      await storage.delete(key: 'token');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => logout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
