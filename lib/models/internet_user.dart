import 'payment_status.dart';

class InternetUser {
  final String id; // e.g., WAS1, WAS2, WAS3
  final String name;
  final String phone;
  final String address;
  final String packageId;
  final String packageName;
  final double feeAmount;
  final double paidAmount;
  final String? lastPaymentDate;
  final String? lastCollectedBy;
  final String? notes;
  final bool isActive;

  InternetUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.packageId,
    required this.packageName,
    required this.feeAmount,
    this.paidAmount = 0.0,
    this.lastPaymentDate,
    this.lastCollectedBy,
    this.notes,
    this.isActive = true,
  });

  double get remainingBalance {
    final balance = feeAmount - paidAmount;
    return balance > 0 ? balance : 0.0;
  }

  PaymentStatus get status => PaymentStatus.fromAmounts(feeAmount, paidAmount);

  InternetUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? packageId,
    String? packageName,
    double? feeAmount,
    double? paidAmount,
    String? lastPaymentDate,
    String? lastCollectedBy,
    String? notes,
    bool? isActive,
  }) {
    return InternetUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      feeAmount: feeAmount ?? this.feeAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastCollectedBy: lastCollectedBy ?? this.lastCollectedBy,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'packageId': packageId,
        'packageName': packageName,
        'feeAmount': feeAmount,
        'paidAmount': paidAmount,
        'lastPaymentDate': lastPaymentDate,
        'lastCollectedBy': lastCollectedBy,
        'notes': notes,
        'isActive': isActive,
      };

  factory InternetUser.fromJson(Map<String, dynamic> json) {
    return InternetUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      packageId: json['packageId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      feeAmount: (json['feeAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num? ?? 0.0).toDouble(),
      lastPaymentDate: json['lastPaymentDate'] as String?,
      lastCollectedBy: json['lastCollectedBy'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
