import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_record.dart';
import '../screens/shared/printer_screen.dart';
import '../services/printer_service.dart';
import '../theme/app_theme.dart';

class ReceiptDialog extends StatefulWidget {
  final PaymentRecord record;

  const ReceiptDialog({super.key, required this.record});

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Receipt Header Actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.statusPaid.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppTheme.statusPaid,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'POS Payment Receipt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          record.receiptNo ?? 'WAS-RECEIPT',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Visual POS Receipt Paper Slip Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // LOGO & Service Name
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_tethering_rounded,
                        color: AppTheme.primaryBlue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'WASNET INTERNET',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'High Speed Fiber Internet • Helpline: 0300-1234567',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 12),
                    _dottedLine(),
                    const SizedBox(height: 12),

                    // User Info
                    _infoRow('Receipt No:', record.receiptNo ?? 'WAS-REC', isBold: true),
                    const SizedBox(height: 6),
                    _infoRow('Customer WAS ID:', record.userId, isBold: true),
                    const SizedBox(height: 6),
                    _infoRow('Customer Name:', record.userName),
                    const SizedBox(height: 6),
                    _infoRow('Billing Month:', record.monthYear),
                    const SizedBox(height: 6),
                    _infoRow('Date & Time:', record.date),

                    const SizedBox(height: 12),
                    _dottedLine(),
                    const SizedBox(height: 12),

                    // Payment Breakdown
                    _amountRow('Package Monthly Fee', 'Rs ${record.feeAmount.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _amountRow(
                      'PAID TODAY',
                      'Rs ${record.amountPaidThisTime.toStringAsFixed(0)}',
                      color: AppTheme.statusPaid,
                      isLarge: true,
                    ),
                    const SizedBox(height: 8),
                    _amountRow(
                      'Total Paid This Month',
                      'Rs ${record.totalPaidForMonth.toStringAsFixed(0)}',
                    ),

                    const SizedBox(height: 12),
                    _dottedLine(),
                    const SizedBox(height: 12),

                    _amountRow(
                      'REMAINING BALANCE',
                      'Rs ${record.remainingBalance.toStringAsFixed(0)}',
                      color: record.remainingBalance > 0 ? AppTheme.statusUnpaid : AppTheme.statusPaid,
                      isLarge: true,
                    ),

                    const SizedBox(height: 12),
                    _dottedLine(),
                    const SizedBox(height: 12),

                    Text(
                      'Collected By: ${record.collectedBy}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Thank you for your prompt payment!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bluetooth Printer Button (POS Slip)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _isPrinting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.print_rounded),
                label: Text(_isPrinting ? 'Printing Slip...' : '🖨️ Print POS Slip (Bluetooth)'),
                onPressed: _isPrinting ? null : () => _printPOSSlip(context),
              ),

              const SizedBox(height: 10),

              // Secondary Actions (Copy & Bluetooth Settings)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Text'),
                      onPressed: () {
                        final text = '''
WASNET INTERNET SERVICE
-----------------------
Receipt No: ${record.receiptNo}
User ID: ${record.userId}
Customer: ${record.userName}
Month: ${record.monthYear}
Paid Today: Rs ${record.amountPaidThisTime.toStringAsFixed(0)}
Total Paid: Rs ${record.totalPaidForMonth.toStringAsFixed(0)}
Remaining Balance: Rs ${record.remainingBalance.toStringAsFixed(0)}
Collector: ${record.collectedBy}
Date: ${record.date}
Thank you for your payment!
''';
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt text copied! Ready to paste in WhatsApp')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.bluetooth_rounded, size: 16),
                    label: const Text('Printer Setup'),
                    onPressed: () => PrinterScreen.show(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dottedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade400),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _amountRow(String label, String amount, {Color? color, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 14 : 12,
            fontWeight: isLarge ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isLarge ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Future<void> _printPOSSlip(BuildContext context) async {
    setState(() {
      _isPrinting = true;
    });

    final printerService = PrinterService();
    final isConnected = await printerService.checkConnection();

    if (!isConnected) {
      setState(() {
        _isPrinting = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select & connect your Bluetooth Thermal Printer first')),
        );
        PrinterScreen.show(context);
      }
      return;
    }

    final success = await printerService.printReceipt(widget.record);

    setState(() {
      _isPrinting = false;
    });

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.statusPaid,
            content: Text('POS Slip printed for ${widget.record.userId}!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printing failed. Check printer bluetooth connection or paper')),
        );
      }
    }
  }
}
