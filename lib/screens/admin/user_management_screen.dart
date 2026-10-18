import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/internet_user.dart';
import '../../models/package_model.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class UserManagementDialog extends StatefulWidget {
  final InternetUser? userToEdit;

  const UserManagementDialog({super.key, this.userToEdit});

  static void show(BuildContext context, {InternetUser? userToEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UserManagementDialog(userToEdit: userToEdit),
    );
  }

  @override
  State<UserManagementDialog> createState() => _UserManagementDialogState();
}

class _UserManagementDialogState extends State<UserManagementDialog> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _feeController;

  String? _selectedPackageId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);

    if (widget.userToEdit != null) {
      final u = widget.userToEdit!;
      _idController = TextEditingController(text: u.id);
      _nameController = TextEditingController(text: u.name);
      _phoneController = TextEditingController(text: u.phone);
      _addressController = TextEditingController(text: u.address);
      _feeController = TextEditingController(text: u.feeAmount.toStringAsFixed(0));
      _selectedPackageId = u.packageId;
    } else {
      _idController = TextEditingController(text: appState.generateNextWasId());
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
      _feeController = TextEditingController(
        text: appState.packages.isNotEmpty
            ? appState.packages.first.monthlyFee.toStringAsFixed(0)
            : '1700',
      );
      if (appState.packages.isNotEmpty) {
        _selectedPackageId = appState.packages.first.id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isEditing = widget.userToEdit != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 10),
          Text(
            isEditing ? 'Edit Net User' : 'Add New Net User',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // WAS ID
            TextField(
              controller: _idController,
              enabled: !isEditing, // ID fixed when editing
              decoration: const InputDecoration(
                labelText: 'User WAS ID (e.g. WAS1)',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Customer Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'e.g. Wasim Akram',
              ),
            ),
            const SizedBox(height: 12),

            // Phone
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '0300-1234567',
              ),
            ),
            const SizedBox(height: 12),

            // Address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address / House No / Area',
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'e.g. House 12, Block A',
              ),
            ),
            const SizedBox(height: 12),

            // Package Selector
            DropdownButtonFormField<String>(
              initialValue: _selectedPackageId,
              decoration: const InputDecoration(
                labelText: 'Internet Package',
                prefixIcon: Icon(Icons.wifi_rounded),
              ),
              items: appState.packages.map((pkg) {
                return DropdownMenuItem<String>(
                  value: pkg.id,
                  child: Text('${pkg.name} (Rs ${pkg.monthlyFee.toStringAsFixed(0)})'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedPackageId = val;
                  if (val != null) {
                    final p = appState.packages.firstWhere((element) => element.id == val);
                    _feeController.text = p.monthlyFee.toStringAsFixed(0);
                  }
                });
              },
            ),
            const SizedBox(height: 12),

            // Custom Fee Amount
            TextField(
              controller: _feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Fee Package (Rs)',
                prefixIcon: Icon(Icons.attach_money_rounded),
                hintText: '1700',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUser,
          child: _isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(isEditing ? 'Save Changes' : 'Add User'),
        ),
      ],
    );
  }

  Future<void> _saveUser() async {
    final name = _nameController.text.trim();
    final wasId = _idController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final fee = double.tryParse(_feeController.text.trim()) ?? 0.0;

    if (name.isEmpty || wasId.isEmpty || fee <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill Name, WAS ID and valid fee amount')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);

      if (widget.userToEdit != null) {
        final pkgName = appState.packages
            .firstWhere(
              (p) => p.id == _selectedPackageId,
              orElse: () => InternetPackage(id: '', name: 'Custom Package', speed: '', monthlyFee: fee),
            )
            .name;

        final updated = widget.userToEdit!.copyWith(
          name: name,
          phone: phone,
          address: address,
          packageId: _selectedPackageId ?? '',
          packageName: pkgName,
          feeAmount: fee,
        );
        await appState.updateUser(updated);
      } else {
        await appState.addUser(
          name: name,
          phone: phone,
          address: address,
          packageId: _selectedPackageId ?? 'PKG1',
          feeAmount: fee,
          customWasId: wasId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.statusPaid,
            content: Text(
              widget.userToEdit != null ? 'User updated successfully' : 'New user $wasId added!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving user: $e')),
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
