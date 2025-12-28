import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';

import '../../core/services/api_service.dart';
import '../../core/constant/api_constant.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PartnerSettingsDialog extends StatefulWidget {
  final String userId;
  final String partnerId;
  final String currentName;

  const PartnerSettingsDialog({
    super.key,
    required this.userId,
    required this.partnerId,
    required this.currentName,
  });

  @override
  State<PartnerSettingsDialog> createState() => _PartnerSettingsDialogState();
}

class _PartnerSettingsDialogState extends State<PartnerSettingsDialog> {
  final _controller = TextEditingController();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadCallsign();
  }

  Future<void> _loadCallsign() async {
    final saved = await storage.read(
      key: 'callsign_${widget.userId}_${widget.partnerId}',
    );
    _controller.text = saved ?? widget.currentName;
  }

  Future<void> _saveCallsign() async {
    await storage.write(
      key: 'callsign_${widget.userId}_${widget.partnerId}',
      value: _controller.text.trim(),
    );

    Navigator.of(context).pop(true);
  }

  Future<void> _removePartner() async {
    try {
      final token = await storage.read(key: 'token');

      final response = await ApiService.delete(
        ApiConstants.removePartner(widget.partnerId),
        token: token,
      );

      if (response['status'] == 200) {
        // Optional: clean up local callsign
        await storage.delete(
          key: 'callsign_${widget.userId}_${widget.partnerId}',
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Partner removed 💔")));

        // return false → means no partner anymore
        Navigator.of(context).pop(false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['body']['message'] ?? "Failed to remove partner",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error removing partner: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Partner Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _controller,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                labelText: "Callsign / Nickname",
                labelStyle: const TextStyle(color: AppColors.primary),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCallsign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Save Callsign"),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _removePartner,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Remove Partner"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
