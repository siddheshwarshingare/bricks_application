class LedgerModel {
  final String id;

  /// Sale or Payment
  final String type;

  /// Transaction Date
  final DateTime date;

  /// Sale Amount
  final double debit;

  /// Payment Amount
  final double credit;

  /// Running Balance
  double balance;

  /// Description
  final String description;

  LedgerModel({
    required this.id,
    required this.type,
    required this.date,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.description,
  });

  LedgerModel copyWith({
    String? id,
    String? type,
    DateTime? date,
    double? debit,
    double? credit,
    double? balance,
    String? description,
  }) {
    return LedgerModel(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      balance: balance ?? this.balance,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LedgerModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
