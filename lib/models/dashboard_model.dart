class DashboardModel {
  final double production;
  final double sales;
  final double salesQuantity;
  final double collection;
  final double pending;

  final int workers;

  final int customers;

  final int materials;
  DashboardModel({
    required this.production,
    required this.sales,
    required this.salesQuantity,
    required this.collection,
    required this.pending,
    required this.workers,
    required this.customers,
    required this.materials,
  });

  DashboardModel copyWith({
    double? production,
    double? sales,
    double? collection,
    double? pending,
    int? workers,
    int? customers,
    int? materials,
    double? salesQuantity,
  }) {
    return DashboardModel(
      production: production ?? this.production,
      sales: sales ?? this.sales,
      salesQuantity: salesQuantity ?? this.salesQuantity,
      collection: collection ?? this.collection,
      pending: pending ?? this.pending,
      workers: workers ?? this.workers,
      customers: customers ?? this.customers,
      materials: materials ?? this.materials,
    );
  }

  factory DashboardModel.empty() {
    return DashboardModel(
      production: 0,
      sales: 0,
      collection: 0,
      pending: 0,
      workers: 0,
      customers: 0,
      salesQuantity: 0,
      materials: 0,
    );
  }
}
