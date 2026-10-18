import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/internet_user.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'receipt_dialog.dart';

class CollectFeeDialog extends StatefulWidget {
  final InternetUser user;

  const CollectFeeDialog({super.key, required this.user});

  static void show(BuildContext context, InternetUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CollectFeeDialog(user: user),
    );
  }

  @override
  State<CollectFeeDialog> createState() => _CollectFeeDialogState();
}

class _CollectFeeDialogState extends State<CollectFeeDialog> {
  late TextEditingController _amountController;
  final TextEditingController _notesController = TextEditingController();
  double _calculatedNewBalance = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to full remaining balance if unpaid or partial
    final defaultAmount = widget.user.remainingBalance > 0
        ? widget.user.remainingBalance
        : widget.user.feeAmount;
    _amountController = TextEditingController(text: defaultAmount.toStringAsFixed(0));
    _recalculateBalance(defaultAmount);
  }

  void _recalculateBalance(double enteredAmount) {
    final double currentPaid = widget.user.paidAmount;
    final double totalNewPaid = currentPaid + enteredAmount;
    final double fee = widget.user.feeAmount;
    final newBal = fee - totalNewPaid;
    setState(() {
      _calculatedNewBalance = newBal > 0 ? newBal : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: mediaQuery.viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wasooli / Collect Fee',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.user.id} - ${widget.user.name}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Financial Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Total Fee', 'Rs ${widget.user.feeAmount.toStringAsFixed(0)}'),
                  Container(height: 30, width: 1, color: Colors.grey.shade300),
                  _statItem('Already Paid', 'Rs ${widget.user.paidAmount.toStringAsFixed(0)}', color: AppTheme.statusPaid),
                  Container(height: 30, width: 1, color: Colors.grey.shade300),
                  _statItem('Balance', 'Rs ${widget.user.remainingBalance.toStringAsFixed(0)}', color: AppTheme.statusUnpaid),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Input Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Amount Received Today (Rs)',
                prefixIcon: Icon(Icons.money_rounded),
                hintText: 'e.g. 1000 or 1700',
              ),
              onChanged: (val) {
                final amt = double.tryParse(val) ?? 0.0;
                _recalculateBalance(amt);
              },
            ),

            const SizedBox(height: 10),

            // Quick Amount Chips
            Wrap(
              spacing: 8,
              children: [
                if (widget.user.remainingBalance > 0)
                  ActionChip(
                    label: Text('Full Bal (Rs ${widget.user.remainingBalance.toStringAsFixed(0)})'),
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    onPressed: () {
                      _amountController.text = widget.user.remainingBalance.toStringAsFixed(0);
                      _recalculateBalance(widget.user.remainingBalance);
                    },
                  ),
                ActionChip(
                  label: const Text('Rs 500'),
                  onPressed: () {
                    _amountController.text = '500';
                    _recalculateBalance(500);
                  },
                ),
                ActionChip(
                  label: const Text('Rs 1000'),
                  onPressed: () {
                    _amountController.text = '1000';
                    _recalculateBalance(1000);
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Realtime New Balance calculation view
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Remaining Balance After This Payment:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  Text(
                    'Rs ${_calculatedNewBalance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _calculatedNewBalance > 0 ? AppTheme.statusUnpaid : AppTheme.statusPaid,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Notes field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Remarks / Notes (Optional)',
                prefixIcon: Icon(Icons.note_alt_outlined),
                hintText: 'e.g. Cash received, will pay rest on 20th',
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPayment,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Confirm Payment & Generate Receipt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String title, String val, {Color? color}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Future<void> _submitPayment() async {
    final enteredText = _amountController.text.trim();
    final amt = double.tryParse(enteredText);

    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final record = await appState.recordPayment(
        userId: widget.user.id,
        amountPaidThisTime: amt,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        showDialog(
          context: context,
          builder: (_) => ReceiptDialog(record: record),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording payment: $e')),
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
