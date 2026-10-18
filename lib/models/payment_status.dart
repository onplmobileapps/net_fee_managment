enum PaymentStatus {
  paid,
  partial,
  unpaid;

  String get displayName {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.unpaid:
        return 'Unpaid';
    }
  }

  static PaymentStatus fromAmounts(double fee, double paid) {
    if (paid >= fee && fee > 0) {
      return PaymentStatus.paid;
    } else if (paid > 0) {
      return PaymentStatus.partial;
    }
    return PaymentStatus.unpaid;
  }
}
