import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_status.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/user_card.dart';
import '../admin/user_management_screen.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final users = appState.filteredUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Net Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(115),
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search WAS ID (was1, was2...), name, phone...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: appState.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => appState.setSearchQuery(''),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                      label: 'All (${appState.allUsers.length})',
                      isSelected: appState.statusFilter == null,
                      onTap: () => appState.setStatusFilter(null),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      context,
                      label: 'Unpaid (${appState.unpaidUsersCount})',
                      isSelected: appState.statusFilter == PaymentStatus.unpaid,
                      color: AppTheme.statusUnpaid,
                      onTap: () => appState.setStatusFilter(PaymentStatus.unpaid),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      context,
                      label: 'Partial (${appState.partialUsersCount})',
                      isSelected: appState.statusFilter == PaymentStatus.partial,
                      color: AppTheme.statusPartial,
                      onTap: () => appState.setStatusFilter(PaymentStatus.partial),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No net users found',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try changing search query or filter criteria',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
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
      floatingActionButton: appState.isAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add User'),
              onPressed: () => UserManagementDialog.show(context),
            )
          : null,
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final activeColor = color ?? AppTheme.primaryBlue;

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
