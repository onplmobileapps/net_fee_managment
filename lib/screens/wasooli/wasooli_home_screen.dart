import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_status.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/exit_confirmation.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/user_card.dart';
import '../shared/printer_screen.dart';
import '../shared/user_detail_screen.dart';

class WasooliHomeScreen extends StatelessWidget {
  const WasooliHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final users = appState.filteredUsers;
    final currentUser = appState.currentUser;
    final pendingCount = appState.unpaidUsersCount + appState.partialUsersCount;

    return ExitConfirmationWrapper(
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: AppTheme.accentCyan,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Collection Agent Portal'),
            Text(
              'Agent: ${currentUser?.name ?? "Collection Staff"}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => appState.logout(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(105),
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: TextField(
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search WAS ID (e.g. was1), name, area...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: appState.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => appState.setSearchQuery(''),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) => appState.setSearchQuery(val),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    _filterChip(
                      context,
                      label: 'Pending ($pendingCount)',
                      isSelected: appState.statusFilter == PaymentStatus.unpaid ||
                          appState.statusFilter == PaymentStatus.partial,
                      color: AppTheme.statusUnpaid,
                      onTap: () {
                        if (appState.statusFilter == PaymentStatus.unpaid) {
                          appState.setStatusFilter(null);
                        } else {
                          appState.setStatusFilter(PaymentStatus.unpaid);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      context,
                      label: 'All (${appState.allUsers.length})',
                      isSelected: appState.statusFilter == null,
                      onTap: () => appState.setStatusFilter(null),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      context,
                      label: 'Paid (${appState.paidUsersCount})',
                      isSelected: appState.statusFilter == PaymentStatus.paid,
                      color: AppTheme.statusPaid,
                      onTap: () => appState.setStatusFilter(PaymentStatus.paid),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Banner summary for agent
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.accentCyan.withOpacity(0.12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MonthSelector(),
                Text(
                  'Collected: Rs ${appState.totalCollectedRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.statusUnpaid.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.statusUnpaid.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Bal: Rs ${appState.totalRemainingRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.statusUnpaid,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Users list
          Expanded(
            child: users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No users in this list',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Try clearing search filters',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserCard(
                        user: user,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailScreen(userId: user.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final activeColor = color ?? AppTheme.accentCyan;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : activeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : activeColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : activeColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
