import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_record.dart';
import '../../models/payment_status.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/receipt_dialog.dart';
import '../admin/monthly_reset_dialog.dart';
import '../admin/package_management_screen.dart';
import '../admin/user_management_screen.dart';
import '../shared/printer_screen.dart';
import '../shared/user_list_screen.dart';
import 'reports_screen.dart';

class WebAdminDashboard extends StatefulWidget {
  const WebAdminDashboard({super.key});

  @override
  State<WebAdminDashboard> createState() => _WebAdminDashboardState();
}

class _WebAdminDashboardState extends State<WebAdminDashboard> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'WASNET Web Management Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Month: ${appState.currentMonth}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Bluetooth Printer Setup',
            onPressed: () => PrinterScreen.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_rounded),
            tooltip: 'Reports',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => appState.logout(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Side Rail for Web
          if (isWide)
            NavigationRail(
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.primaryBlue.withOpacity(0.12),
              selectedIconTheme: const IconThemeData(color: AppTheme.primaryBlue),
              selectedLabelTextStyle: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
              unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
              selectedIndex: _selectedNavIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedNavIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_rounded),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryBlue),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_alt_rounded),
                  selectedIcon: Icon(Icons.people_alt_rounded, color: AppTheme.primaryBlue),
                  label: Text('Users Directory'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  selectedIcon: Icon(Icons.bar_chart_rounded, color: AppTheme.primaryBlue),
                  label: Text('Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.wifi_rounded),
                  selectedIcon: Icon(Icons.wifi_rounded, color: AppTheme.primaryBlue),
                  label: Text('Packages'),
                ),
              ],
            ),

          if (isWide) const VerticalDivider(thickness: 1, width: 1),

          // Main View Content
          Expanded(
            child: IndexedStack(
              index: _selectedNavIndex,
              children: [
                _buildOverviewDashboard(context, appState, isDark, isWide),
                const UserListScreen(),
                const ReportsScreen(),
                const PackageManagementScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewDashboard(
    BuildContext context,
    AppState appState,
    bool isDark,
    bool isWide,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top KPI Summary Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 1100 ? 4 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossCount,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _kpiCard(
                    title: 'Total Expected Revenue',
                    value: 'Rs ${appState.totalExpectedRevenue.toStringAsFixed(0)}',
                    sub: '${appState.totalUsersCount} Active Users',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.primaryBlue,
                  ),
                  _kpiCard(
                    title: 'Collected Revenue',
                    value: 'Rs ${appState.totalCollectedRevenue.toStringAsFixed(0)}',
                    sub: '${appState.collectionPercentage.toStringAsFixed(1)}% Progress',
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.statusPaid,
                  ),
                  _kpiCard(
                    title: 'Pending Remaining Balance',
                    value: 'Rs ${appState.totalRemainingRevenue.toStringAsFixed(0)}',
                    sub: '${appState.unpaidUsersCount + appState.partialUsersCount} Users Pending',
                    icon: Icons.pending_rounded,
                    color: AppTheme.statusUnpaid,
                  ),
                  _kpiCard(
                    title: 'Paid Users Ratio',
                    value: '${appState.paidUsersCount} / ${appState.totalUsersCount}',
                    sub: '${appState.partialUsersCount} Partial • ${appState.unpaidUsersCount} Unpaid',
                    icon: Icons.pie_chart_rounded,
                    color: AppTheme.statusPartial,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Charts Section: Donut Chart & Packages Bar Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Collection Donut Chart
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revenue Distribution',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 50,
                              sections: [
                                PieChartSectionData(
                                  color: AppTheme.statusPaid,
                                  value: appState.totalCollectedRevenue,
                                  title: '${appState.collectionPercentage.toStringAsFixed(0)}%',
                                  radius: 40,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: AppTheme.statusUnpaid,
                                  value: appState.totalRemainingRevenue > 0
                                      ? appState.totalRemainingRevenue
                                      : 0.1,
                                  title: 'Pending',
                                  radius: 35,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _legendItem('Collected', AppTheme.statusPaid),
                            _legendItem('Pending Balance', AppTheme.statusUnpaid),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Quick Actions & Controls Panel
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Admin Controls',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.person_add_rounded, color: AppTheme.primaryBlue),
                          ),
                          title: const Text('Add New Net User', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Register WAS ID and package'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => UserManagementDialog.show(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.statusUnpaid.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.published_with_changes_rounded, color: AppTheme.statusUnpaid),
                          ),
                          title: const Text('Monthly Wasooli Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Archive records and start new billing month'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => MonthlyResetDialog.show(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.print_rounded, color: AppTheme.accentCyan),
                          ),
                          title: const Text('🖨️ POS Thermal Invoice Slip Demo', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Preview receipt slip and test print'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            if (appState.paymentRecords.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (_) => ReceiptDialog(record: appState.paymentRecords.first),
                              );
                            } else {
                              final demo = PaymentRecord(
                                id: 'DEMO-101',
                                userId: 'WAS1',
                                userName: 'Wasim Akram (Demo)',
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
                                builder: (_) => ReceiptDialog(record: demo),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Users Table View Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Users Directory',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('View All Users'),
                        onPressed: () {
                          setState(() {
                            _selectedNavIndex = 1;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('WAS ID')),
                        DataColumn(label: Text('Customer Name')),
                        DataColumn(label: Text('Package')),
                        DataColumn(label: Text('Monthly Fee')),
                        DataColumn(label: Text('Paid Amount')),
                        DataColumn(label: Text('Balance')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: appState.allUsers.take(6).map((u) {
                        return DataRow(
                          cells: [
                            DataCell(Text(u.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(u.name)),
                            DataCell(Text(u.packageName)),
                            DataCell(Text('Rs ${u.feeAmount.toStringAsFixed(0)}')),
                            DataCell(Text(
                              'Rs ${u.paidAmount.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppTheme.statusPaid, fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              'Rs ${u.remainingBalance.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: u.remainingBalance > 0 ? AppTheme.statusUnpaid : AppTheme.statusPaid,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            DataCell(Text(
                              u.status.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: u.status == PaymentStatus.paid
                                    ? AppTheme.statusPaid
                                    : u.status == PaymentStatus.partial
                                        ? AppTheme.statusPartial
                                        : AppTheme.statusUnpaid,
                              ),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
