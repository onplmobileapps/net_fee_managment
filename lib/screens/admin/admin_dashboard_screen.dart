import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_record.dart';
import '../../models/payment_status.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/exit_confirmation.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/receipt_dialog.dart';
import '../shared/user_list_screen.dart';
import 'monthly_reset_dialog.dart';
import 'package:net_fee_managment_app/screens/admin/package_management_screen.dart';
import 'package:net_fee_managment_app/screens/admin/user_management_screen.dart';
import '../web/web_admin_dashboard.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;

    // Responsive Web View Switcher
    if (mediaWidth >= 800) {
      return const WebAdminDashboard();
    }

    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExitConfirmationWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Waseem Net Service - Admin'),
              Text(
                'Logged in as ${currentUser?.name ?? "Admin"}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: () => appState.logout(),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Month Header & Reset Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BILLING MONTH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const MonthSelector(),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.statusUnpaid,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.published_with_changes_rounded, size: 18),
                  label: const Text('New Month Reset', style: TextStyle(fontSize: 13)),
                  onPressed: () => MonthlyResetDialog.show(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Main Revenue Summary Banner
            Card(
              color: isDark ? AppTheme.cardDark : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Revenue Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${appState.totalUsersCount} Total Users',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Expected Total Revenue
                    Text(
                      'Total Expected Revenue',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs ${appState.totalExpectedRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Collection Progress',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${appState.collectionPercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.statusPaid,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: appState.collectionPercentage / 100,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            color: AppTheme.statusPaid,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Collected vs Pending
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.statusPaid.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppTheme.statusPaid, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Collected',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.statusPaid,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rs ${appState.totalCollectedRevenue.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.statusPaid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.statusUnpaid.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pending_rounded, color: AppTheme.statusUnpaid, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Remaining',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.statusUnpaid,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rs ${appState.totalRemainingRevenue.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.statusUnpaid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status Counter Cards
            Row(
              children: [
                _statusStatCard(
                  context,
                  title: 'Paid Users',
                  count: appState.paidUsersCount,
                  color: AppTheme.statusPaid,
                  icon: Icons.task_alt_rounded,
                  onTap: () {
                    appState.setStatusFilter(PaymentStatus.paid);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
                  },
                ),
                const SizedBox(width: 8),
                _statusStatCard(
                  context,
                  title: 'Partial Users',
                  count: appState.partialUsersCount,
                  color: AppTheme.statusPartial,
                  icon: Icons.pending_rounded,
                  onTap: () {
                    appState.setStatusFilter(PaymentStatus.partial);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
                  },
                ),
                const SizedBox(width: 8),
                _statusStatCard(
                  context,
                  title: 'Unpaid Users',
                  count: appState.unpaidUsersCount,
                  color: AppTheme.statusUnpaid,
                  icon: Icons.error_outline_rounded,
                  onTap: () {
                    appState.setStatusFilter(PaymentStatus.unpaid);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
                  },
                ),
              ],
            ),

            // POS Printer Demo Banner Card for Client Demo
            Card(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.3)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (appState.paymentRecords.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => ReceiptDialog(record: appState.paymentRecords.first),
                    );
                  } else {
                    // Create a sample demo payment record
                    final demoRecord = PaymentRecord(
                      id: 'DEMO-101',
                      userId: 'WAS1',
                      userName: 'Wasim Akram (Demo Client)',
                      monthYear: appState.currentMonth,
                      feeAmount: 1700.0,
                      amountPaidThisTime: 1000.0,
                      totalPaidForMonth: 1000.0,
                      remainingBalance: 700.0,
                      collectedBy: appState.currentUser?.name ?? 'Admin',
                      date: '2023-10-15 14:30',
                      receiptNo: 'WAS-DEMO-001',
                    );
                    showDialog(
                      context: context,
                      builder: (_) => ReceiptDialog(record: demoRecord),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.print_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🖨️ POS Thermal Invoice Demo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to preview client invoice slip & Bluetooth printer test',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryBlue),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Navigation Grid
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _actionGridCard(
                  context,
                  title: 'Net Users List',
                  subtitle: '${appState.allUsers.length} Users',
                  icon: Icons.people_alt_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () {
                    appState.clearFilters();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
                  },
                ),
                _actionGridCard(
                  context,
                  title: 'Add New User',
                  subtitle: 'Register WAS ID',
                  icon: Icons.person_add_rounded,
                  color: AppTheme.accentCyan,
                  onTap: () => UserManagementDialog.show(context),
                ),
                _actionGridCard(
                  context,
                  title: 'Manage Packages',
                  subtitle: '${appState.packages.length} Plans',
                  icon: Icons.wifi_rounded,
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PackageManagementScreen()));
                  },
                ),
                _actionGridCard(
                  context,
                  title: 'Monthly Reset',
                  subtitle: 'Start New Month',
                  icon: Icons.restore_rounded,
                  color: AppTheme.statusUnpaid,
                  onTap: () => MonthlyResetDialog.show(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Transactions Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Collection History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${appState.paymentRecords.length} Receipts',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (appState.paymentRecords.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'No payment records for this billing cycle yet.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.paymentRecords.length > 5 ? 5 : appState.paymentRecords.length,
                itemBuilder: (context, idx) {
                  final rec = appState.paymentRecords[idx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ReceiptDialog(record: rec),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.statusPaid.withOpacity(0.12),
                        child: const Icon(Icons.receipt, color: AppTheme.statusPaid, size: 20),
                      ),
                      title: Text(
                        '${rec.userId} - ${rec.userName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Paid: Rs ${rec.amountPaidThisTime.toStringAsFixed(0)} • ${rec.collectedBy}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Bal: Rs ${rec.remainingBalance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: rec.remainingBalance > 0 ? AppTheme.statusUnpaid : AppTheme.statusPaid,
                            ),
                          ),
                          Text(
                            rec.date.split(' ').first,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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
  }

  Widget _statusStatCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
