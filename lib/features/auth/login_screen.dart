import 'package:datejar_frontend/core/services/user_service.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

//api service
import '../../core/services/api_service.dart';
import '../../core/constant/api_constant.dart';

//storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = FlutterSecureStorage();
  bool isLoading = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Reset error message when user types
    emailController.addListener(() {
      if (errorMessage != null) setState(() => errorMessage = null);
    });

    passwordController.addListener(() {
      if (errorMessage != null) setState(() => errorMessage = null);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    final email = emailController.text;
    final password = passwordController.text;

    print("Login button pressed");
    print("Email: $email");
    print("Password: $password");

    if (email.isEmpty || password.isEmpty) {
      print("Error: Email or password is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email and password cannot be empty")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = {"email": email, "password": password};
      print("Sending API request: $data");

      final response = await ApiService.post(ApiConstants.login, data);
      final status = response['status'];
      final body = response['body'];

      if (status == 200 && body['token'] != null) {
        // Success
        await storage.write(key: 'token', value: body['token']);

        // Fetch user info
        try {
          final userData = await UserService.fetchUser();
          await storage.write(key: 'userId', value: userData['id'].toString());
          await storage.write(key: 'name', value: userData['name']);
        } catch (e) {
          print("Failed to fetch user info: $e");
        }

        Navigator.pushReplacementNamed(context, '/home');
      } else if (status == 401) {
        // Wrong credentials
        setState(() {
          errorMessage = "Wrong email or password";
        });
      } else {
        // Other errors
        setState(() {
          errorMessage = "Login failed. Please try again.";
        });
      }
    } catch (e) {
      print("Login error: $e");
      setState(() {
        errorMessage = "An unexpected error occurred";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              // App Logo
              Image.asset('assets/images/datejar-logo.png', width: 120),
              const SizedBox(height: 15),

              const Text(
                'Login',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // Username field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : login, // disable button while loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.onPrimary),
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
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 20),

              // OR divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),

              const SizedBox(height: 20),

              // Google Sign-in button
              FractionallySizedBox(
                widthFactor: 0.8, // 80% of parent width
                child: SizedBox(
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.mainBackgroundGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Image.asset('assets/images/google.png', width: 24),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        side: const BorderSide(color: AppColors.onPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Register text
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to register screen
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
