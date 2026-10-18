import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_user.dart';
import '../models/internet_user.dart';
import '../models/package_model.dart';
import '../models/payment_record.dart';
import '../models/payment_status.dart';
import '../models/user_role.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;

  AppUser? _currentUser;
  List<InternetUser> _users = [];
  List<InternetPackage> _packages = [];
  List<PaymentRecord> _paymentRecords = [];
  List<String> _availableMonths = [];
  String _selectedMonth = '';

  String _searchQuery = '';
  PaymentStatus? _statusFilter;
  String? _selectedPackageFilter;

  AppState(this._storage) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _currentUser = _storage.getLoggedInUser();
    _packages = _storage.getPackages();
    _paymentRecords = _storage.getRecords();
    _availableMonths = _storage.getAvailableMonths();
    _selectedMonth = _storage.getCurrentMonth();

    if (_availableMonths.isEmpty) {
      _availableMonths = [_selectedMonth];
      _storage.saveAvailableMonths(_availableMonths);
    }

    _users = _storage.getUsersForMonth(_selectedMonth);
    notifyListeners();
  }

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  List<InternetUser> get allUsers => _users;
  List<InternetPackage> get packages => _packages;
  List<PaymentRecord> get paymentRecords => _paymentRecords;
  List<String> get availableMonths => _availableMonths;
  String get currentMonth => _selectedMonth;

  String get searchQuery => _searchQuery;
  PaymentStatus? get statusFilter => _statusFilter;
  String? get selectedPackageFilter => _selectedPackageFilter;

  // Change Active Month
  void changeSelectedMonth(String monthYear) {
    _selectedMonth = monthYear;
    _storage.saveCurrentMonth(monthYear);
    _users = _storage.getUsersForMonth(monthYear);
    notifyListeners();
  }

  // Filtered Users List
  List<InternetUser> get filteredUsers {
    return _users.where((user) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesId = user.id.toLowerCase().contains(q);
        final matchesName = user.name.toLowerCase().contains(q);
        final matchesPhone = user.phone.toLowerCase().contains(q);
        final matchesAddress = user.address.toLowerCase().contains(q);
        if (!matchesId && !matchesName && !matchesPhone && !matchesAddress) {
          return false;
        }
      }

      if (_statusFilter != null && user.status != _statusFilter) {
        return false;
      }

      if (_selectedPackageFilter != null && _selectedPackageFilter!.isNotEmpty) {
        if (user.packageId != _selectedPackageFilter) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Revenue Stats for Selected Month
  int get totalUsersCount => _users.where((u) => u.isActive).length;

  double get totalExpectedRevenue {
    return _users.where((u) => u.isActive).fold(0.0, (sum, u) => sum + u.feeAmount);
  }

  double get totalCollectedRevenue {
    return _users.where((u) => u.isActive).fold(0.0, (sum, u) => sum + u.paidAmount);
  }

  double get totalRemainingRevenue {
    return _users.where((u) => u.isActive).fold(0.0, (sum, u) => sum + u.remainingBalance);
  }

  int get paidUsersCount =>
      _users.where((u) => u.isActive && u.status == PaymentStatus.paid).length;

  int get unpaidUsersCount =>
      _users.where((u) => u.isActive && u.status == PaymentStatus.unpaid).length;

  int get partialUsersCount =>
      _users.where((u) => u.isActive && u.status == PaymentStatus.partial).length;

  double get collectionPercentage {
    if (totalExpectedRevenue == 0) return 0.0;
    final pct = (totalCollectedRevenue / totalExpectedRevenue) * 100;
    return pct > 100 ? 100 : pct;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(PaymentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPackageFilter(String? packageId) {
    _selectedPackageFilter = packageId;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _selectedPackageFilter = null;
    notifyListeners();
  }

  // --- Auth ---
  bool login(String username, String password) {
    final appUsers = _storage.getAppUsers();
    final match = appUsers.firstWhere(
      (u) =>
          u.username.trim().toLowerCase() == username.trim().toLowerCase() &&
          u.password == password,
      orElse: () => AppUser(
        id: '',
        name: '',
        username: '',
        password: '',
        role: UserRole.wasooli,
      ),
    );

    if (match.id.isNotEmpty) {
      _currentUser = match;
      _storage.saveLoggedInUser(match);
      notifyListeners();
      return true;
    }
    return false;
  }

  void switchRoleDemo(UserRole role) {
    final appUsers = _storage.getAppUsers();
    final target = appUsers.firstWhere(
      (u) => u.role == role,
      orElse: () => AppUser(
        id: 'demo',
        name: role == UserRole.admin ? 'Admin User' : 'Collection Agent',
        username: role.name,
        password: '123',
        role: role,
      ),
    );
    _currentUser = target;
    _storage.saveLoggedInUser(target);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _storage.saveLoggedInUser(null);
    notifyListeners();
  }

  // --- Payment Collection ---
  Future<PaymentRecord> recordPayment({
    required String userId,
    required double amountPaidThisTime,
    String? notes,
  }) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('User $userId not found');
    }

    final user = _users[index];
    final double newTotalPaid = user.paidAmount + amountPaidThisTime;
    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final collectorName = _currentUser?.name ?? 'Unknown Collector';

    final updatedUser = user.copyWith(
      paidAmount: newTotalPaid,
      lastPaymentDate: nowStr,
      lastCollectedBy: collectorName,
      notes: notes ?? user.notes,
    );

    _users[index] = updatedUser;
    await _storage.saveUsersForMonth(_selectedMonth, _users);

    final record = PaymentRecord(
      id: 'REC-${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      userName: user.name,
      monthYear: _selectedMonth,
      feeAmount: user.feeAmount,
      amountPaidThisTime: amountPaidThisTime,
      totalPaidForMonth: newTotalPaid,
      remainingBalance: updatedUser.remainingBalance,
      collectedBy: collectorName,
      date: nowStr,
      receiptNo: 'RCP-${(10000 + _paymentRecords.length + 1)}',
    );

    _paymentRecords.insert(0, record);
    await _storage.addRecord(record);

    notifyListeners();
    return record;
  }

  // --- User CRUD ---
  String generateNextWasId() {
    int maxIdNum = 0;
    for (var u in _users) {
      final idUpper = u.id.toUpperCase();
      if (idUpper.startsWith('WAS')) {
        final numPart = idUpper.replaceAll('WAS', '');
        final parsed = int.tryParse(numPart);
        if (parsed != null && parsed > maxIdNum) {
          maxIdNum = parsed;
        }
      }
    }
    return 'WAS${maxIdNum + 1}';
  }

  Future<void> addUser({
    required String name,
    required String phone,
    required String address,
    required String packageId,
    required double feeAmount,
    String? customWasId,
  }) async {
    final wasId = (customWasId != null && customWasId.trim().isNotEmpty)
        ? customWasId.trim().toUpperCase()
        : generateNextWasId();

    final pkg = _packages.firstWhere(
      (p) => p.id == packageId,
      orElse: () => InternetPackage(
        id: 'CUSTOM',
        name: 'Custom Package',
        speed: 'Standard',
        monthlyFee: feeAmount,
      ),
    );

    final newUser = InternetUser(
      id: wasId,
      name: name,
      phone: phone,
      address: address,
      packageId: packageId,
      packageName: pkg.name,
      feeAmount: feeAmount,
      paidAmount: 0.0,
    );

    // Add to current month & master directory
    _users.add(newUser);
    await _storage.saveUsersForMonth(_selectedMonth, _users);

    final master = _storage.getMasterUsers();
    if (!master.any((u) => u.id == wasId)) {
      master.add(newUser);
      await _storage.saveMasterUsers(master);
    }

    notifyListeners();
  }

  Future<void> updateUser(InternetUser updatedUser) async {
    final idx = _users.indexWhere((u) => u.id == updatedUser.id);
    if (idx != -1) {
      _users[idx] = updatedUser;
      await _storage.saveUsersForMonth(_selectedMonth, _users);

      final master = _storage.getMasterUsers();
      final mIdx = master.indexWhere((u) => u.id == updatedUser.id);
      if (mIdx != -1) {
        master[mIdx] = updatedUser;
        await _storage.saveMasterUsers(master);
      }

      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    _users.removeWhere((u) => u.id == userId);
    await _storage.saveUsersForMonth(_selectedMonth, _users);

    final master = _storage.getMasterUsers();
    master.removeWhere((u) => u.id == userId);
    await _storage.saveMasterUsers(master);

    notifyListeners();
  }

  // --- Package Management ---
  Future<void> addPackage(String name, String speed, double monthlyFee) async {
    final id = 'PKG-${DateTime.now().millisecondsSinceEpoch}';
    final newPkg = InternetPackage(
      id: id,
      name: name,
      speed: speed,
      monthlyFee: monthlyFee,
    );
    _packages.add(newPkg);
    await _storage.savePackages(_packages);
    notifyListeners();
  }

  // --- Monthly Reset Action ---
  Future<void> resetMonthlyCollection(String newMonthName) async {
    // 1. Get master customers or current customers
    final master = _storage.getMasterUsers();
    final freshUsers = master.isEmpty
        ? _users.map((u) => u.copyWith(paidAmount: 0.0, notes: null, lastPaymentDate: null, lastCollectedBy: null)).toList()
        : master.map((u) => u.copyWith(paidAmount: 0.0, notes: null, lastPaymentDate: null, lastCollectedBy: null)).toList();

    _users = freshUsers;
    _selectedMonth = newMonthName;

    await _storage.addMonth(newMonthName);
    await _storage.saveCurrentMonth(newMonthName);
    await _storage.saveUsersForMonth(newMonthName, _users);

    _availableMonths = _storage.getAvailableMonths();
    notifyListeners();
  }
}
