import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import './goal_dialog.dart';

import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final storage = const FlutterSecureStorage();

  Map<String, dynamic>? _user;
  Map<String, dynamic>? _partner;

  DateTime _focusedDate = DateTime.now();
  final DateTime _today = DateTime.now();

  // Store goals as list
  List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _fetchUserAndPartner();
  }

  Future<void> _fetchUserAndPartner() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) throw "Token not found";

      final userData = await ApiService.get(ApiConstants.users, token: token);
      final partnerData = await ApiService.get(
        ApiConstants.addPartner,
        token: token,
      );

      setState(() {
        _user = userData;
        _partner = partnerData;
      });

      if (_partner != null && _partner!['id'] != null) {
        await _fetchGoals(token);
      }

      print("Fetched user calendar: $_user");
      print("Fetched partner calendar: $_partner");
    } catch (e) {
      debugPrint("Error fetching user/partner: $e");
    }
  }

  Future<void> _fetchGoals(String token) async {
    try {
      final List<dynamic> goalsList = await ApiService.getList(
        ApiConstants.goals,
        token: token,
      );

      setState(() {
        _goals = goalsList.map<Map<String, dynamic>>((goal) {
          return {
            'id': goal['id'] as int,
            'partner_id': goal['partner_id'] as int,
            'amount': double.parse(goal['total_goal'].toString()).toInt(),
            'target_date': DateTime.parse(goal['target_date']),
          };
        }).toList();
      });

      debugPrint("Fetched goals: $_goals");
    } catch (e) {
      debugPrint("Error fetching goals: $e");
    }
  }

  void _onDaySelected(DateTime selectedDay) async {
    if (_partner == null) return;

    final int? amount = await showDialog<int>(
      context: context,
      builder: (_) => GoalInputDialog(selectedDate: selectedDay),
    );

    if (amount == null) return;

    final token = await storage.read(key: 'token');
    if (token == null) return;

    final response = await ApiService.post(ApiConstants.goals, {
      "partner_id": _partner!['id'],
      "total_goal": amount,
      "target_date": DateFormat('yyyy-MM-dd').format(selectedDay),
    }, token: token);

    if (response['status'] == 201 || response['status'] == 200) {
      final goal = response['body']['goal'];

      setState(() {
        _goals.add({
          'id': goal['id'],
          'partner_id': goal['partner_id'],
          'amount': goal['total_goal'],
          'target_date': DateTime.parse(goal['target_date']),
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['body']['message'] ?? 'Failed to create goal'),
        ),
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _openGoalViewDialog(Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Today's Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Target Date: ${DateFormat.yMMMd().format(goal['target_date'])}",
            ),
            const SizedBox(height: 8),
            Text("Goal Amount: ₱${goal['amount']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDate,
              selectedDayPredicate: (day) {
                return _goals.any((g) => _isSameDay(g['target_date'], day));
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() => _focusedDate = focusedDay);
                _onDaySelected(selectedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.onPrimary,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: AppColors.primary, // 👈 THIS is what you want
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: const TextStyle(color: AppColors.onPrimary),
                weekendTextStyle: const TextStyle(color: AppColors.onPrimary),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final date = goal['target_date'] as DateTime;
                final isTodayGoal = _isToday(date);

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.onPrimary.withOpacity(0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isTodayGoal
                      ? Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat.yMMMd().format(date),
                                    style: const TextStyle(
                                      color: AppColors.onPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "₱${goal['amount']}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 36,
                                child: OutlinedButton(
                                  onPressed: () => _openGoalViewDialog(goal),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.onPrimary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "View",
                                    style: TextStyle(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.yMMMd().format(date),
                                  style: const TextStyle(
                                    color: AppColors.onPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Target Date",
                                  style: TextStyle(
                                    color: AppColors.onPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "₱${goal['amount']}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
