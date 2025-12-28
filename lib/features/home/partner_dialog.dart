import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import './partner_settings_dialog.dart';

import '../../core/constant/api_constant.dart';
import '../../core/services/api_service.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PartnerDialog extends StatefulWidget {
  final String userId;
  final String name;
  final bool hasPartner;
  final Map<String, dynamic>? partner;
  final String? partnerName;

  const PartnerDialog({
    super.key,
    required this.userId,
    required this.name,
    this.hasPartner = false,
    this.partner,
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

  bool _isSearching = false;

  void _searchUser() async {
    print('button clicked');
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchedUser = null;
    });

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
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _addPartner(String partnerId, String partnerName) async {
    try {
      final token = await storage.read(key: 'token');

      final response = await ApiService.post(ApiConstants.addPartner, {
        "partner_id": partnerId,
      }, token: token);

      if (response['status'] == 201) {
        setState(() {
          _isPartnered = true;
          _searchedUser = null;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Partner connected ❤️")));

        // Optional: close dialog after success
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['body']['message'] ?? "Error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add partner: $e")));
    }
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
                ? _partnerInfoRow(
                    widget.name,
                    widget.partnerName ?? 'Partner',
                    onPartnerTap: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (_) => PartnerSettingsDialog(
                          userId: widget.userId,
                          partnerId: widget.partner!['id'].toString(),
                          currentName: widget.partnerName ?? 'Partner',
                        ),
                      );

                      if (result != null) {
                        Navigator.of(context).pop(result);
                      }
                    },
                  )
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
                            onPressed: _isSearching ? null : _searchUser,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              side: const BorderSide(color: Colors.transparent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSearching
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const Text(
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
    final isSelf = user['id'] == widget.userId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(user['name']!),

        if (isSelf)
          const Text("This is you", style: TextStyle(color: Colors.grey))
        else if (hasPartner)
          const Text('In a relationship', style: TextStyle(color: Colors.grey))
        else
          TextButton.icon(
            onPressed: () => _addPartner(user['id']!, user['name']!),
            icon: const Icon(Icons.favorite, color: Colors.red),
            label: const Text('Add'),
          ),
      ],
    );
  }

  Widget _partnerInfoRow(
    String user,
    String partner, {
    required VoidCallback onPartnerTap,
  }) {
    const double boxHeight = 80;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // User box (not clickable)
          Flexible(
            child: SizedBox(
              height: boxHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  user,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
          const Icon(Icons.favorite, color: Colors.red, size: 26),
          const SizedBox(width: 10),

          // ✅ Partner box (clickable)
          Flexible(
            child: SizedBox(
              height: boxHeight,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onPartnerTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      // Edit icon (top-right)
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(
                          Icons.edit_note_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),

                      // Partner name (center)
                      Center(
                        child: Text(
                          partner,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
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
