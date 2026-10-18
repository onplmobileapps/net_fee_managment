class PaymentRecord {
  final String id;
  final String userId; // WAS ID e.g., WAS1
  final String userName;
  final String monthYear; // e.g. "October 2023" or "2023-10"
  final double feeAmount;
  final double amountPaidThisTime;
  final double totalPaidForMonth;
  final double remainingBalance;
  final String collectedBy; // Agent name or Admin
  final String date; // ISO timestamp string or formatted date
  final String? receiptNo;

  PaymentRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.monthYear,
    required this.feeAmount,
    required this.amountPaidThisTime,
    required this.totalPaidForMonth,
    required this.remainingBalance,
    required this.collectedBy,
    required this.date,
    this.receiptNo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'monthYear': monthYear,
        'feeAmount': feeAmount,
        'amountPaidThisTime': amountPaidThisTime,
        'totalPaidForMonth': totalPaidForMonth,
        'remainingBalance': remainingBalance,
        'collectedBy': collectedBy,
        'date': date,
        'receiptNo': receiptNo,
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      monthYear: json['monthYear'] as String,
      feeAmount: (json['feeAmount'] as num).toDouble(),
      amountPaidThisTime: (json['amountPaidThisTime'] as num).toDouble(),
      totalPaidForMonth: (json['totalPaidForMonth'] as num).toDouble(),
      remainingBalance: (json['remainingBalance'] as num).toDouble(),
      collectedBy: json['collectedBy'] as String,
      date: json['date'] as String,
      receiptNo: json['receiptNo'] as String?,
    );
  }
}
