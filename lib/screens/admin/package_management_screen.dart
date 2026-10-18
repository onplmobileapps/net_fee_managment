import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class PackageManagementScreen extends StatelessWidget {
  const PackageManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Packages'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appState.packages.length,
        itemBuilder: (context, index) {
          final pkg = appState.packages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                child: const Icon(Icons.wifi, color: AppTheme.primaryBlue),
              ),
              title: Text(
                pkg.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Speed: ${pkg.speed}'),
              trailing: Text(
                'Rs ${pkg.monthlyFee.toStringAsFixed(0)} / mo',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Package'),
        onPressed: () => _showAddPackageDialog(context),
      ),
    );
  }

  void _showAddPackageDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final speedCtrl = TextEditingController();
    final feeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Internet Package'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Package Name',
                hintText: 'e.g. Fiber 30 Mbps',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: speedCtrl,
              decoration: const InputDecoration(
                labelText: 'Speed',
                hintText: 'e.g. 30 Mbps',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: feeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Fee (Rs)',
                hintText: 'e.g. 3000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final speed = speedCtrl.text.trim();
              final fee = double.tryParse(feeCtrl.text.trim()) ?? 0.0;

              if (name.isNotEmpty && fee > 0) {
                Provider.of<AppState>(context, listen: false)
                    .addPackage(name, speed.isNotEmpty ? speed : name, fee);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Package added successfully')),
                );
              }
            },
            child: const Text('Save Package'),
          ),
        ],
      ),
    );
  }
}
