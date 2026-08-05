class MonthlyReportModel {
  final double production;
  final double bricksSold;
  final double sales;
  final double collection;
  final double salaryExpense;
  final double materialExpense;
  final double pending;

  const MonthlyReportModel({
    required this.production,
    required this.bricksSold,
    required this.sales,
    required this.collection,
    required this.salaryExpense,
    required this.materialExpense,
    required this.pending,
  });

  MonthlyReportModel copyWith({
    double? production,
    double? bricksSold,
    double? sales,
    double? collection,
    double? salaryExpense,
    double? materialExpense,
    double? pending,
  }) {
    return MonthlyReportModel(
      production: production ?? this.production,
      bricksSold: bricksSold ?? this.bricksSold,
      sales: sales ?? this.sales,
      collection: collection ?? this.collection,
      salaryExpense: salaryExpense ?? this.salaryExpense,
      materialExpense: materialExpense ?? this.materialExpense,
      pending: pending ?? this.pending,
    );
  }

  factory MonthlyReportModel.empty() {
    return const MonthlyReportModel(
      production: 0,
      bricksSold: 0,
      sales: 0,
      collection: 0,
      salaryExpense: 0,
      materialExpense: 0,
      pending: 0,
    );
  }
}
