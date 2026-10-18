import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../services/printer_service.dart';
import '../../theme/app_theme.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PrinterScreen(),
    );
  }

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final PrinterService _printerService = PrinterService();
  List<BluetoothInfo> _devices = [];
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });
    final isConn = await _printerService.checkConnection();
    final list = await _printerService.getBondedDevices();
    setState(() {
      _devices = list;
      _isConnected = isConn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: mediaQuery.viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.print_rounded, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bluetooth Thermal Printer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isConnected ? AppTheme.statusPaid : AppTheme.statusUnpaid,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isConnected
                              ? 'Connected: ${_printerService.selectedDevice?.name ?? "Printer"}'
                              : 'Disconnected',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isConnected ? AppTheme.statusPaid : AppTheme.statusUnpaid,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadDevices,
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_isConnected) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.statusPaid.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.statusPaid.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.statusPaid),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Printer Ready: ${_printerService.selectedDevice?.name ?? "Bluetooth Printer"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                    onPressed: _runTestPrint,
                    child: const Text('Test Print', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.bluetooth_disabled_rounded, color: Colors.redAccent),
                    onPressed: _disconnect,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Text(
            'Paired Bluetooth Devices:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_devices.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Paired Bluetooth Devices Found',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. Turn on your Bluetooth Receipt Printer.\n'
                    '2. Go to Phone Settings -> Bluetooth -> Pair new device.\n'
                    '3. Select printer (e.g. PT-210) and enter PIN 0000 or 1234.\n'
                    '4. Return here and tap Refresh!',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _devices.length,
                itemBuilder: (context, idx) {
                  final dev = _devices[idx];
                  final isThisConnected = _printerService.selectedDevice?.macAdress == dev.macAdress && _isConnected;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.print_outlined,
                        color: isThisConnected ? AppTheme.statusPaid : AppTheme.primaryBlue,
                      ),
                      title: Text(
                        dev.name.isNotEmpty ? dev.name : 'Bluetooth Device',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(dev.macAdress, style: const TextStyle(fontSize: 12)),
                      trailing: isThisConnected
                          ? const Chip(
                              label: Text('Connected', style: TextStyle(fontSize: 11, color: Colors.white)),
                              backgroundColor: AppTheme.statusPaid,
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              onPressed: () => _connectDevice(dev),
                              child: const Text('Connect', style: TextStyle(fontSize: 12)),
                            ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Colors.blue.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Recommended: PT-210 or GOOJPRT 58mm Bluetooth Thermal Printer (~Rs 4,500 - 6,500).',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connectDevice(BluetoothInfo dev) async {
    setState(() {
      _isLoading = true;
    });
    final success = await _printerService.connect(dev);
    setState(() {
      _isLoading = false;
      _isConnected = success;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.statusPaid,
            content: Text('Connected to ${dev.name}!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to ${dev.name}')),
        );
      }
    }
  }

  Future<void> _runTestPrint() async {
    final success = await _printerService.printTest();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test receipt printed!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer error or paper out')),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await _printerService.disconnect();
    setState(() {
      _isConnected = false;
    });
  }
}
