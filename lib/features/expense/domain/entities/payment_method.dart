enum PaymentMethod {
  cash,
  card,
  upi,
  bankTransfer,
  other;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}
