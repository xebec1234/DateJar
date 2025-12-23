import 'package:flutter/material.dart';

class PartnerDialog extends StatelessWidget {
  final String userId;
  final String name;

  const PartnerDialog({
    super.key,
    required this.userId,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User Info'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User ID: $userId'),
          const SizedBox(height: 8),
          Text('Name: $name'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
