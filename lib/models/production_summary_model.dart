import 'package:bricks_application/models/production_model.dart';

class ProductionSummary {
  final double totalProduction;
  final double totalEarned;
  final double totalPaid;
  final double totalReturned;

  ProductionSummary({
    required this.totalProduction,
    required this.totalEarned,
    required this.totalPaid,
    required this.totalReturned,
  });
}

ProductionSummary calculateSummary(List<ProductionModel> productions) {
  double totalProduction = 0;
  double totalEarned = 0;
  double totalPaid = 0;
  double totalReturned = 0;

  for (final production in productions) {
    totalProduction += production.bricksProduced.toDouble();
    totalEarned += production.salaryEarned;
    totalPaid += production.salaryPaid;
    totalReturned += production.cashReturned;
  }

  return ProductionSummary(
    totalProduction: totalProduction,
    totalEarned: totalEarned,
    totalPaid: totalPaid,
    totalReturned: totalReturned,
  );
}
