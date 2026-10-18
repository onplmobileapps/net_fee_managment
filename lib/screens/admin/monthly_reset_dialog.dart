import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class MonthlyResetDialog extends StatefulWidget {
  const MonthlyResetDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const MonthlyResetDialog(),
    );
  }

  @override
  State<MonthlyResetDialog> createState() => _MonthlyResetDialogState();
}

class _MonthlyResetDialogState extends State<MonthlyResetDialog> {
  late TextEditingController _monthController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to next month or current month
    final now = DateTime.now();
    final nextMonthDate = DateTime(now.year, now.month + 1, 1);
    final monthStr = DateFormat('MMMM yyyy').format(nextMonthDate);
    _monthController = TextEditingController(text: monthStr);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.statusUnpaid.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.published_with_changes_rounded,
              color: AppTheme.statusUnpaid,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Monthly Collection Reset',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Reset Notice',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Current Month: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  appState.currentMonth,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• All users paid amounts will be reset to Rs 0 (Unpaid status).\n'
                  '• All past month receipts will be safely archived in Payment History.\n'
                  '• User profiles & packages remain unchanged.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _monthController,
            decoration: const InputDecoration(
              labelText: 'New Billing Month Name',
              hintText: 'e.g. November 2023',
              prefixIcon: Icon(Icons.calendar_month_rounded),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.statusUnpaid,
          ),
          onPressed: _isLoading ? null : _confirmReset,
          child: _isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Confirm New Month Reset'),
        ),
      ],
    );
  }

  Future<void> _confirmReset() async {
    final newMonth = _monthController.text.trim();
    if (newMonth.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a month name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.resetMonthlyCollection(newMonth);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.statusPaid,
            content: Text('Collection successfully reset for $newMonth!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
