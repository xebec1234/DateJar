import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/tulips_widget.dart';
import 'partner_dialog.dart';

import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? _partner; // partner info will be stored here
  String _partnerCallsign = "babe";

  @override
  void initState() {
    super.initState();
    _fetchPartner(); // fetch partner on screen load
    _fetchActiveGoal();
  }

  Future<void> _fetchPartner() async {
    try {
      final token = await storage.read(key: 'token');
      final data = await ApiService.get(
        "${ApiConstants.baseUrl}/partners",
        token: token,
      );

      // Load callsign from local storage
      String? savedCallsign;
      if (data != null && data['id'] != null) {
        savedCallsign = await storage.read(
          key: 'callsign_${data['user_id1']}_${data['id']}',
        );
      }

      setState(() {
        _partner = data;
        _partnerCallsign = savedCallsign ?? "babe";
      });
    } catch (e) {
      setState(() {
        _partner = null;
        _partnerCallsign = "babe";
      });
    }
  }

  Map<String, dynamic>? _activeGoal;

  Future<void> _fetchActiveGoal() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) return;

      final data = await ApiService.get(ApiConstants.active, token: token);
      setState(() {
        _activeGoal = data.isEmpty ? null : data;
      });
    } catch (e) {
      debugPrint("No active goal");
      setState(() => _activeGoal = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('EEEE, MMM d').format(DateTime.now());

    // 🔜 How this becomes dynamic later

    // When your backend is ready, you can:

    // Fetch a value like jarLevel = 0 | 50 | 100

    // Map it to an image:

    // String getJarImage(int level) {
    //   if (level >= 100) return 'assets/images/jar_full.png';
    //   if (level >= 50) return 'assets/images/jar_half.png';
    //   return 'assets/images/jar_empty.png';
    // }
    final String jarImagePath = 'assets/images/jar1.png';

    final String weeklyProgressText = _activeGoal != null ? "WEEKLY PROGRESS" : "NO ACTIVE GOALS";
    final int currentGoal = 100;
    final int totalGoal = 100;
    final int weeklyGoalAmount = _activeGoal != null
        ? double.parse(_activeGoal!['weekly_goal']).toInt()
        : 0;

    // Today's Savings
    final int meSavings = 20; // static for now
    final int loveSavings = 0; // static for now

    final int totalSavings = 2000;
    final int goalAmount = _activeGoal != null
        ? double.parse(_activeGoal!['total_goal']).toInt()
        : 0;

    Widget savingsContainer(
      String label,
      int value,
      Color bgColor,
      Color textColor,
    ) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor, // e.g., Color(0xFFFAFCFB)
            borderRadius: BorderRadius.circular(50), // fully rounded
            boxShadow: [
              // top-left light shadow
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: const Offset(-3, -3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
              // bottom-right dark shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(3, 3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value > 0 ? Colors.green : Colors.transparent,
                  border: value > 0 ? null : Border.all(color: Colors.grey),
                ),
                child: value > 0
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              // Label + Value
              Text(
                "$label: $value",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      // Ensures content doesn't overlap system status bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with date and settings
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  today,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: AppColors.primary,
                  onPressed: () async {
                    final userId = await storage.read(key: 'userId') ?? '';
                    final name = await storage.read(key: 'name') ?? '';

                    // Open PartnerDialog and wait for a result
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => PartnerDialog(
                        userId: userId,
                        name: name,
                        hasPartner: _partner != null,
                        partner: _partner,
                        partnerName: _partner?['partner_name'],
                      ),
                    );

                    //refresh the partner info
                    if (result != null) {
                      await _fetchPartner();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //jar section
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // wrap content only
              children: [
                // Top Text
                const SizedBox(height: 10),

                // Jar Image
                Image.asset(jarImagePath, width: 200, fit: BoxFit.contain),

                Text(
                  weeklyProgressText,
                  style: TextStyle(
                    fontSize: 24, // like H2
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),

                // Bottom Text (goal)
                Text(
                  "$currentGoal / $totalGoal",
                  style: TextStyle(
                    fontSize: 20, // smaller subtext
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Goal: ₱$weeklyGoalAmount",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Optional space below jar
          const SizedBox(height: 24),

          // Today's Savings Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Today's Savings",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    savingsContainer(
                      "Me",
                      meSavings,
                      AppColors.primary,
                      Colors.white,
                    ),
                    savingsContainer(
                      _partnerCallsign,
                      loveSavings,
                      Colors.white,
                      Colors.blueGrey,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 34),

          // Total Savings Container (Neumorphic)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Container(
              width: double.infinity,
              height: 160,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFAFCFB,
                ), // soft background for neumorphism
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // top-left light shadow
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    offset: const Offset(-6, -6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  // bottom-right dark shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(6, 6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 🌷 LEFT: Flower video
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 1),
                        child: TapToPlayFlower(),
                      ),
                    ),
                  ),

                  // 💰 RIGHT: Total Savings text
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Total Savings",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₱$totalSavings",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),

                        // 👇 NEW: Goal amount text
                        const SizedBox(height: 6),
                        Text(
                          "Goal: ₱$goalAmount",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
