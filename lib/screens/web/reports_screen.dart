import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/payment_status.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  PaymentStatus? _selectedStatus;
  String _selectedPackageId = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final filteredUsers = appState.allUsers.where((u) {
      if (_selectedStatus != null && u.status != _selectedStatus) return false;
      if (_selectedPackageId.isNotEmpty && u.packageId != _selectedPackageId) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WASNET Financial Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export CSV Report',
            onPressed: () => _exportCSVReport(context, appState, filteredUsers),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Report Filters:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    DropdownButton<PaymentStatus?>(
                      value: _selectedStatus,
                      hint: const Text('All Statuses'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Statuses')),
                        ...PaymentStatus.values.map(
                          (st) => DropdownMenuItem(value: st, child: Text(st.displayName)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedStatus = val),
                    ),
                    DropdownButton<String>(
                      value: _selectedPackageId.isEmpty ? null : _selectedPackageId,
                      hint: const Text('All Packages'),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('All Packages')),
                        ...appState.packages.map(
                          (pkg) => DropdownMenuItem(value: pkg.id, child: Text(pkg.name)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedPackageId = val ?? ''),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Copy CSV Data'),
                      onPressed: () => _exportCSVReport(context, appState, filteredUsers),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Summary Totals
            Row(
              children: [
                _summaryBox(
                  'Total Expected',
                  'Rs ${appState.totalExpectedRevenue.toStringAsFixed(0)}',
                  AppTheme.primaryBlue,
                ),
                const SizedBox(width: 12),
                _summaryBox(
                  'Collected Total',
                  'Rs ${appState.totalCollectedRevenue.toStringAsFixed(0)}',
                  AppTheme.statusPaid,
                ),
                const SizedBox(width: 12),
                _summaryBox(
                  'Pending Balance',
                  'Rs ${appState.totalRemainingRevenue.toStringAsFixed(0)}',
                  AppTheme.statusUnpaid,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Data Table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Billing Ledger (${appState.currentMonth})',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${filteredUsers.length} Records',
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('WAS ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Package', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Fee (Rs)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Paid (Rs)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Balance (Rs)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Collector / Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredUsers.map((u) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    u.id,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                              DataCell(Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600))),
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
                              DataCell(Text('${u.lastCollectedBy ?? "—"} (${u.lastPaymentDate ?? "Pending"})')),
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
      ),
    );
  }

  Widget _summaryBox(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _exportCSVReport(BuildContext context, AppState appState, List users) {
    StringBuffer csv = StringBuffer();
    csv.writeln('WAS ID,Customer Name,Phone,Address,Package,Monthly Fee,Paid Amount,Remaining Balance,Status,Last Collected By,Date');

    for (var u in users) {
      csv.writeln(
        '${u.id},"${u.name}","${u.phone}","${u.address}","${u.packageName}",${u.feeAmount},${u.paidAmount},${u.remainingBalance},${u.status.displayName},"${u.lastCollectedBy ?? ''}","${u.lastPaymentDate ?? ''}"',
      );
    }

    Clipboard.setData(ClipboardData(text: csv.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Financial CSV Report copied to Clipboard! Ready to paste into Excel / Sheets.'),
      ),
    );
  }
}
