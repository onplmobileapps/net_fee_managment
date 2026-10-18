import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/internet_user.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/collect_fee_dialog.dart';
import '../../widgets/status_chip.dart';
import '../admin/user_management_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.allUsers.firstWhere(
          (u) => u.id == userId,
          orElse: () => InternetUser(
            id: 'NOT_FOUND',
            name: 'User Not Found',
            phone: '',
            address: '',
            packageId: '',
            packageName: '',
            feeAmount: 0,
          ),
        );

        if (user.id == 'NOT_FOUND') {
          return Scaffold(
            appBar: AppBar(title: const Text('User Details')),
            body: const Center(child: Text('User record does not exist.')),
          );
        }

        final userRecords = appState.paymentRecords
            .where((r) => r.userId == user.id)
            .toList();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            title: Text('${user.id} - ${user.name}'),
            actions: [
              if (appState.isAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Edit User',
                  onPressed: () => UserManagementDialog.show(context, userToEdit: user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'Delete User',
                  onPressed: () => _confirmDelete(context, appState, user),
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                user.id,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            StatusChip(status: user.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              user.phone.isNotEmpty ? user.phone : 'No phone registered',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        if (user.address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user.address,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Financial Overview Card
                Card(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryBlue),
                            const SizedBox(width: 10),
                            Text(
                              'Billing Summary (${appState.currentMonth})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        _detailRow('Internet Package', user.packageName),
                        const SizedBox(height: 10),
                        _detailRow('Monthly Fee', 'Rs ${user.feeAmount.toStringAsFixed(0)}'),
                        const SizedBox(height: 10),
                        _detailRow(
                          'Paid So Far',
                          'Rs ${user.paidAmount.toStringAsFixed(0)}',
                          valueColor: AppTheme.statusPaid,
                        ),
                        const SizedBox(height: 10),
                        _detailRow(
                          'Remaining Balance',
                          'Rs ${user.remainingBalance.toStringAsFixed(0)}',
                          valueColor: user.remainingBalance > 0
                              ? AppTheme.statusUnpaid
                              : AppTheme.statusPaid,
                          isBold: true,
                        ),

                        if (user.notes != null && user.notes!.isNotEmpty) ...[
                          const Divider(height: 24),
                          Text(
                            'Remarks / Notes:',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.notes!,
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ],

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: AppTheme.primaryBlue,
                          ),
                          icon: const Icon(Icons.payments_rounded),
                          label: const Text('Wasooli / Receive Payment'),
                          onPressed: () => CollectFeeDialog.show(context, user),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Payment History Log
                const Text(
                  'Payment Transactions History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                if (userRecords.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'No payment transactions recorded yet for this month.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userRecords.length,
                    itemBuilder: (ctx, idx) {
                      final rec = userRecords[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.statusPaid.withOpacity(0.15),
                            child: const Icon(Icons.check, color: AppTheme.statusPaid, size: 20),
                          ),
                          title: Text(
                            'Paid Rs ${rec.amountPaidThisTime.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${rec.date} • ${rec.collectedBy}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                rec.receiptNo ?? '',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Bal: Rs ${rec.remainingBalance.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: rec.remainingBalance > 0 ? AppTheme.statusUnpaid : AppTheme.statusPaid,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, InternetUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to delete ${user.id} - ${user.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await appState.deleteUser(user.id);
              if (context.mounted) {
                Navigator.pop(ctx); // close dialog
                Navigator.pop(context); // leave detail screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User ${user.id} deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
