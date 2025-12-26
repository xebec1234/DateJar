import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';

import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PartnerDialog extends StatefulWidget {
  final String userId;
  final String name;
  final bool hasPartner;
  final String? partnerName;

  const PartnerDialog({
    super.key,
    required this.userId,
    required this.name,
    this.hasPartner = false,
    this.partnerName,
  });

  @override
  State<PartnerDialog> createState() => _PartnerDialogState();
}

class _PartnerDialogState extends State<PartnerDialog> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, String>? _searchedUser;
  bool _isPartnered = false;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _isPartnered = widget.hasPartner;
  }

  void _searchUser() async {
    print('button clicked');
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      final token = await storage.read(key: 'token');
      final endpoint = "${ApiConstants.partners}?user_id=$query";
      print("Calling API: $endpoint");

      final data = await ApiService.get(endpoint, token: token);
      print("API response: $data");

      setState(() {
        _searchedUser = {
          'id': data['id'].toString(),
          'name': data['name'],
          'hasPartner': data['hasPartner'].toString(),
        };
      });
    } catch (e) {
      print("Error: $e"); // <-- add this
      setState(() {
        _searchedUser = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not found or error: $e")));
    }
  }

  void _addPartner() {
    setState(() {
      _isPartnered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Partner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _isPartnered
                ? _partnerInfoRow(widget.name, widget.partnerName ?? 'Partner')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${widget.userId}'),
                      const SizedBox(height: 8),
                      Text('Name: ${widget.name}'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          labelText: 'Search User ID',
                          labelStyle: TextStyle(color: AppColors.primary),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity, // full width
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.mainBackgroundGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: OutlinedButton(
                            onPressed: _searchUser,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              side: const BorderSide(color: Colors.transparent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      if (_searchedUser != null)
                        _buildSearchedUserRow(_searchedUser!),
                    ],
                  ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchedUserRow(Map<String, String> user) {
    final hasPartner = user['hasPartner'] == 'true';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(user['name']!),
        hasPartner
            ? const Text(
                'In a relationship',
                style: TextStyle(color: Colors.grey),
              )
            : TextButton.icon(
                onPressed: _addPartner,
                icon: const Icon(Icons.favorite, color: Colors.red),
                label: const Text('Add'),
              ),
      ],
    );
  }

  Widget _partnerInfoRow(String user, String partner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // User box
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Heart icon
          const Icon(Icons.favorite, color: Colors.red, size: 28),
          const SizedBox(width: 8),

          // Partner box
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  partner,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
