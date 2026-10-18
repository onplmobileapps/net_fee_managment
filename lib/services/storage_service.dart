import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../models/internet_user.dart';
import '../models/package_model.dart';
import '../models/payment_record.dart';
import '../models/user_role.dart';

class StorageService {
  static const String _keyMasterUsers = 'master_net_users_v1';
  static const String _keyPackages = 'net_packages_v1';
  static const String _keyRecords = 'payment_records_v1';
  static const String _keyAppUsers = 'app_users_v1';
  static const String _keyCurrentMonth = 'current_month_v1';
  static const String _keyAvailableMonths = 'available_months_v1';
  static const String _keyLoggedInUser = 'logged_in_user_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    await service._ensureDefaultData();
    return service;
  }

  Future<void> _ensureDefaultData() async {
    // 1. Packages
    if (!_prefs.containsKey(_keyPackages)) {
      final defaultPackages = [
        InternetPackage(id: 'PKG1', name: 'Basic 5 Mbps', speed: '5 Mbps', monthlyFee: 1200.0),
        InternetPackage(id: 'PKG2', name: 'Standard 10 Mbps', speed: '10 Mbps', monthlyFee: 1700.0),
        InternetPackage(id: 'PKG3', name: 'Super 20 Mbps', speed: '20 Mbps', monthlyFee: 2500.0),
        InternetPackage(id: 'PKG4', name: 'Ultra 50 Mbps', speed: '50 Mbps', monthlyFee: 4000.0),
      ];
      await savePackages(defaultPackages);
    }

    // 2. App System Logins (Admin & Collection)
    if (!_prefs.containsKey(_keyAppUsers)) {
      final defaultAppUsers = [
        AppUser(
          id: 'u1',
          name: 'Main Admin',
          username: 'admin',
          password: '123',
          role: UserRole.admin,
        ),
        AppUser(
          id: 'u2',
          name: 'Collection Agent (Tariq)',
          username: 'wasooli',
          password: '123',
          role: UserRole.wasooli,
        ),
      ];
      await saveAppUsers(defaultAppUsers);
    }

    // 3. Current Month & Available Months
    final now = DateTime.now();
    final defaultMonth = _formatMonthYear(now);
    
    List<String> months = getAvailableMonths();
    if (months.isEmpty) {
      months = [defaultMonth];
      await saveAvailableMonths(months);
    }

    if (!_prefs.containsKey(_keyCurrentMonth)) {
      await saveCurrentMonth(defaultMonth);
    }

    // 4. Master Customers & Monthly Ledger
    if (!_prefs.containsKey(_keyMasterUsers)) {
      final defaultUsers = [
        InternetUser(
          id: 'WAS1',
          name: 'Wasim Akram',
          phone: '0300-1234567',
          address: 'House #12, Block A, Gulberg',
          packageId: 'PKG2',
          packageName: 'Standard 10 Mbps',
          feeAmount: 1700.0,
          paidAmount: 1000.0, // Partial payment example
          lastPaymentDate: '2023-10-10 11:30',
          lastCollectedBy: 'Collection Agent (Tariq)',
          notes: 'Promised remaining Rs 700 next week',
        ),
        InternetUser(
          id: 'WAS2',
          name: 'Ali Raza',
          phone: '0312-9876543',
          address: 'Flat 402, Royal Apartments',
          packageId: 'PKG3',
          packageName: 'Super 20 Mbps',
          feeAmount: 2500.0,
          paidAmount: 2500.0, // Fully Paid
          lastPaymentDate: '2023-10-05 14:15',
          lastCollectedBy: 'Main Admin',
        ),
        InternetUser(
          id: 'WAS3',
          name: 'Usman Ghani',
          phone: '0321-4567890',
          address: 'Shop 5, Main Market',
          packageId: 'PKG1',
          packageName: 'Basic 5 Mbps',
          feeAmount: 1200.0,
          paidAmount: 0.0, // Unpaid
        ),
        InternetUser(
          id: 'WAS4',
          name: 'Zubair Khan',
          phone: '0333-1122334',
          address: 'House 88, Lane 3, Model Town',
          packageId: 'PKG2',
          packageName: 'Standard 10 Mbps',
          feeAmount: 1700.0,
          paidAmount: 1700.0,
          lastPaymentDate: '2023-10-02 09:45',
          lastCollectedBy: 'Collection Agent (Tariq)',
        ),
        InternetUser(
          id: 'WAS5',
          name: 'Hamza Sheikh',
          phone: '0305-6677889',
          address: 'Villa 14, Phase 2, DHA',
          packageId: 'PKG4',
          packageName: 'Ultra 50 Mbps',
          feeAmount: 4000.0,
          paidAmount: 2000.0,
          lastPaymentDate: '2023-10-12 16:00',
          lastCollectedBy: 'Collection Agent (Tariq)',
        ),
      ];
      await saveMasterUsers(defaultUsers);
      await saveUsersForMonth(defaultMonth, defaultUsers);
    }
  }

  String _formatMonthYear(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  // --- Master Users Directory ---
  List<InternetUser> getMasterUsers() {
    final rawJson = _prefs.getString(_keyMasterUsers);
    if (rawJson == null) return [];
    final List list = jsonDecode(rawJson);
    return list.map((e) => InternetUser.fromJson(e)).toList();
  }

  Future<void> saveMasterUsers(List<InternetUser> users) async {
    final encoded = jsonEncode(users.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyMasterUsers, encoded);
  }

  // --- Month-Wise Users Ledger ---
  List<InternetUser> getUsersForMonth(String monthYear) {
    final key = 'net_users_$monthYear';
    final rawJson = _prefs.getString(key);
    if (rawJson == null) {
      // Fallback: If month ledger doesn't exist yet, generate from master with paidAmount = 0
      final master = getMasterUsers();
      final freshMonthUsers = master.map((u) => u.copyWith(paidAmount: 0.0, notes: null, lastPaymentDate: null, lastCollectedBy: null)).toList();
      saveUsersForMonth(monthYear, freshMonthUsers);
      return freshMonthUsers;
    }
    final List list = jsonDecode(rawJson);
    return list.map((e) => InternetUser.fromJson(e)).toList();
  }

  Future<void> saveUsersForMonth(String monthYear, List<InternetUser> users) async {
    final key = 'net_users_$monthYear';
    final encoded = jsonEncode(users.map((e) => e.toJson()).toList());
    await _prefs.setString(key, encoded);
  }

  // --- Available Months ---
  List<String> getAvailableMonths() {
    return _prefs.getStringList(_keyAvailableMonths) ?? [];
  }

  Future<void> saveAvailableMonths(List<String> months) async {
    await _prefs.setStringList(_keyAvailableMonths, months);
  }

  Future<void> addMonth(String monthYear) async {
    final months = getAvailableMonths();
    if (!months.contains(monthYear)) {
      months.insert(0, monthYear);
      await saveAvailableMonths(months);
    }
  }

  // --- Packages CRUD ---
  List<InternetPackage> getPackages() {
    final rawJson = _prefs.getString(_keyPackages);
    if (rawJson == null) return [];
    final List list = jsonDecode(rawJson);
    return list.map((e) => InternetPackage.fromJson(e)).toList();
  }

  Future<void> savePackages(List<InternetPackage> packages) async {
    final encoded = jsonEncode(packages.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyPackages, encoded);
  }

  // --- Payment History Records ---
  List<PaymentRecord> getRecords() {
    final rawJson = _prefs.getString(_keyRecords);
    if (rawJson == null) return [];
    final List list = jsonDecode(rawJson);
    return list.map((e) => PaymentRecord.fromJson(e)).toList();
  }

  Future<void> saveRecords(List<PaymentRecord> records) async {
    final encoded = jsonEncode(records.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyRecords, encoded);
  }

  Future<void> addRecord(PaymentRecord record) async {
    final records = getRecords();
    records.insert(0, record);
    await saveRecords(records);
  }

  // --- App System Users ---
  List<AppUser> getAppUsers() {
    final rawJson = _prefs.getString(_keyAppUsers);
    if (rawJson == null) return [];
    final List list = jsonDecode(rawJson);
    return list.map((e) => AppUser.fromJson(e)).toList();
  }

  Future<void> saveAppUsers(List<AppUser> appUsers) async {
    final encoded = jsonEncode(appUsers.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyAppUsers, encoded);
  }

  // --- Current Active Month ---
  String getCurrentMonth() {
    return _prefs.getString(_keyCurrentMonth) ?? 'October 2023';
  }

  Future<void> saveCurrentMonth(String monthStr) async {
    await _prefs.setString(_keyCurrentMonth, monthStr);
  }

  // --- Active Session ---
  AppUser? getLoggedInUser() {
    final rawJson = _prefs.getString(_keyLoggedInUser);
    if (rawJson == null) return null;
    return AppUser.fromJson(jsonDecode(rawJson));
  }

  Future<void> saveLoggedInUser(AppUser? user) async {
    if (user == null) {
      await _prefs.remove(_keyLoggedInUser);
    } else {
      await _prefs.setString(_keyLoggedInUser, jsonEncode(user.toJson()));
    }
  }
}
