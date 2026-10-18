import 'dart:typed_data';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/payment_record.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  BluetoothInfo? _selectedDevice;
  bool _isConnected = false;

  BluetoothInfo? get selectedDevice => _selectedDevice;
  bool get isConnected => _isConnected;

  Future<bool> checkConnection() async {
    _isConnected = await PrintBluetoothThermal.connectionStatus;
    return _isConnected;
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(BluetoothInfo device) async {
    try {
      _selectedDevice = device;
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );
      _isConnected = result;
      return result;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (_) {}
    _isConnected = false;
    _selectedDevice = null;
  }

  // Generate ESC/POS byte commands for thermal slip
  Uint8List _generateReceiptBytes(PaymentRecord record, String name, String phone) {
    List<int> bytes = [];

    // ESC/POS Command Constants
    const List<int> init = [27, 64];
    const List<int> alignCenter = [27, 97, 1];
    const List<int> alignLeft = [27, 97, 0];
    const List<int> textNormal = [27, 33, 0];
    const List<int> textBold = [27, 33, 8];
    const List<int> textLarge = [27, 33, 32];
    const List<int> newLine = [10];

    void addString(String str) {
      bytes.addAll(str.codeUnits);
    }

    bytes.addAll(init);

    // Header
    bytes.addAll(alignCenter);
    bytes.addAll(textBold);
    addString('================================\n');
    bytes.addAll(textLarge);
    addString('$name\n');
    bytes.addAll(textNormal);
    addString('High Speed Fiber Internet\n');
    addString('$phone\n');
    addString('================================\n');

    bytes.addAll(newLine);

    // Metadata
    bytes.addAll(alignLeft);
    bytes.addAll(textNormal);
    addString('Receipt No : ${record.receiptNo ?? 'WAS-REC'}\n');
    addString('Date/Time  : ${record.date}\n');
    addString('Billing Mth: ${record.monthYear}\n');
    addString('--------------------------------\n');

    // Customer
    bytes.addAll(textBold);
    addString('Customer ID: ${record.userId}\n');
    addString('Name       : ${record.userName}\n');
    bytes.addAll(textNormal);
    addString('--------------------------------\n');

    // Amounts
    addString('Package Fee  : Rs ${record.feeAmount.toStringAsFixed(0)}\n');
    bytes.addAll(textBold);
    addString('PAID TODAY   : Rs ${record.amountPaidThisTime.toStringAsFixed(0)}\n');
    bytes.addAll(textNormal);
    addString('Total Paid Mth: Rs ${record.totalPaidForMonth.toStringAsFixed(0)}\n');
    addString('--------------------------------\n');

    bytes.addAll(textBold);
    addString('REMAINING BAL: Rs ${record.remainingBalance.toStringAsFixed(0)}\n');
    bytes.addAll(textNormal);
    addString('--------------------------------\n');

    // Collector & Footer
    addString('Collected By : ${record.collectedBy}\n');
    bytes.addAll(newLine);
    bytes.addAll(alignCenter);
    addString('Thank you for your payment!\n');
    addString('*** WASNET POS SLIP ***\n');
    addString('================================\n');
    bytes.addAll(newLine);
    bytes.addAll(newLine);

    return Uint8List.fromList(bytes);
  }

  // Print POS Receipt Slip
  Future<bool> printReceipt(PaymentRecord record, {String? companyName, String? companyPhone}) async {
    final connected = await checkConnection();
    if (!connected) return false;

    final name = companyName ?? 'WASNET INTERNET SERVICE';
    final phone = companyPhone ?? 'Helpline: 0300-1234567';

    try {
      final bytes = _generateReceiptBytes(record, name, phone);
      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      return false;
    }
  }

  // Test Print
  Future<bool> printTest() async {
    final connected = await checkConnection();
    if (!connected) return false;

    try {
      List<int> bytes = [];
      bytes.addAll([27, 64]); // init
      bytes.addAll([27, 97, 1]); // center
      bytes.addAll([27, 33, 32]); // large
      bytes.addAll('WASNET PRINTER TEST\n'.codeUnits);
      bytes.addAll([27, 33, 0]); // normal
      bytes.addAll('Status: CONNECTED & WORKING OK\n'.codeUnits);
      bytes.addAll('================================\n\n\n'.codeUnits);

      return await PrintBluetoothThermal.writeBytes(Uint8List.fromList(bytes));
    } catch (e) {
      return false;
    }
  }
}
