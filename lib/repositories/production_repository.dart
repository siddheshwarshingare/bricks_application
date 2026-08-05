import 'package:bricks_application/enums/dashboard_filter.dart';
import 'package:bricks_application/models/production_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduction(ProductionModel production) async {
    await _firestore
        .collection("factories")
        .doc(production.factoryId)
        .collection("productions")
        .add(production.toMap());
  }

  Future<void> updateProduction(ProductionModel production) async {
    await _firestore
        .collection("factories")
        .doc(production.factoryId)
        .collection("productions")
        .doc(production.id)
        .update(production.toMap());
  }

  Stream<List<ProductionModel>> getWorkerProductions(
    String factoryId,
    String workerId,
  ) {
    return FirebaseFirestore.instance
        .collection('factories')
        .doc(factoryId)
        .collection('productions')
        .where('workerId', isEqualTo: workerId)
        .orderBy('productionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => ProductionModel.fromFirestore(e))
              .toList(),
        );
  }

  Future<void> deleteProduction(String factoryId, String productionId) async {
    await _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("productions")
        .doc(productionId)
        .delete();
  }

  Stream<List<ProductionModel>> getProductions(String factoryId) {
    return _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("productions")
        .orderBy("productionDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductionModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<ProductionModel>> getProductionsByFilter(
    String factoryId,
    DashboardFilter filter,
  ) {
    DateTime now = DateTime.now();

    DateTime startDate;
    DateTime endDate;

    switch (filter) {
      case DashboardFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;

      case DashboardFilter.thisWeek:
        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
        break;

      case DashboardFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;

      case DashboardFilter.last6Months:
        startDate = DateTime(now.year, now.month - 5, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;

      case DashboardFilter.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
        break;

      default:
        return getProductions(factoryId);
    }

    return _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("productions")
        .where(
          "productionDate",
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where("productionDate", isLessThan: Timestamp.fromDate(endDate))
        .orderBy("productionDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductionModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Today's Total Production
  Stream<double> todayProduction(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);

    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("productions")
        .where(
          "productionDate",
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where("productionDate", isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (var doc in snapshot.docs) {
            total += (doc["bricksProduced"] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// This Week's Production
  Stream<double> weekProduction(String factoryId) {
    final now = DateTime.now();

    final start = now.subtract(Duration(days: now.weekday - 1));

    final weekStart = DateTime(start.year, start.month, start.day);

    final weekEnd = weekStart.add(const Duration(days: 7));

    return _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("productions")
        .where(
          "productionDate",
          isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
        )
        .where("productionDate", isLessThan: Timestamp.fromDate(weekEnd))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (var doc in snapshot.docs) {
            total += (doc["bricksProduced"] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// This Month's Production
  Stream<double> monthProduction(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month);

    final end = DateTime(now.year, now.month + 1);

    return _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("productions")
        .where(
          "productionDate",
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where("productionDate", isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (var doc in snapshot.docs) {
            total += (doc["bricksProduced"] ?? 0).toDouble();
          }

          return total;
        });
  }
}
