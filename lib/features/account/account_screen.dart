import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final storage = const FlutterSecureStorage();
  bool isLoading = false;

  void logout() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await storage.read(key: 'token');

      if (token != null) {
        // Call backend logout
        await ApiService.post(
          ApiConstants.logout,
          {},
          token: token, // include token in headers
        );
        print("Backend logout successful");
      }

      // Delete token locally regardless
      await storage.delete(key: 'token');
      print("Token deleted, user logged out");

      // Navigate back to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print("Error logging out: $e");

      // Still delete token locally if backend fails
      await storage.delete(key: 'token');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 160,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
