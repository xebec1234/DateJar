import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GoalInputDialog extends StatefulWidget {
  final DateTime selectedDate;

  const GoalInputDialog({super.key, required this.selectedDate});

  @override
  State<GoalInputDialog> createState() => _GoalInputDialogState();
}

class _GoalInputDialogState extends State<GoalInputDialog> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Set Goal Amount',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Target Date: ${widget.selectedDate.day}-${widget.selectedDate.month}-${widget.selectedDate.year}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Amount cannot be empty";
                }
                if (int.tryParse(value) == null) {
                  return "Please enter a valid integer";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // close dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              int amount = int.parse(_amountController.text);
              Navigator.pop(context, amount); // return amount to caller
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
