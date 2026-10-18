import 'package:flutter/material.dart';
import '../models/payment_status.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final PaymentStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case PaymentStatus.paid:
        bg = AppTheme.statusPaid.withOpacity(0.15);
        fg = AppTheme.statusPaid;
        icon = Icons.check_circle_rounded;
        break;
      case PaymentStatus.partial:
        bg = AppTheme.statusPartial.withOpacity(0.15);
        fg = AppTheme.statusPartial;
        icon = Icons.pending_rounded;
        break;
      case PaymentStatus.unpaid:
        bg = AppTheme.statusUnpaid.withOpacity(0.15);
        fg = AppTheme.statusUnpaid;
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
