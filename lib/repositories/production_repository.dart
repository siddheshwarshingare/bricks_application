import 'package:bricks_application/enums/dashboard_filter.dart';
import 'package:bricks_application/models/production_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _productions(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('productions');
  }

  CollectionReference<Map<String, dynamic>> _stocks(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('stock');
  }

  double _number(dynamic value) {
    return value is num ? value.toDouble() : 0.0;
  }

  // ============================================================
  // ADD PRODUCTION
  // ============================================================

  Future<void> addProduction(
    ProductionModel production, {
    String productSize = '',
  }) async {
    if (production.bricksProduced <= 0) {
      throw Exception('Production quantity must be greater than 0');
    }

    final stockQuery = await _stocks(
      production.factoryId,
    ).where('productId', isEqualTo: production.productId).limit(1).get();

    final stockRef = stockQuery.docs.isNotEmpty
        ? stockQuery.docs.first.reference
        : null;

    final productionRef = _productions(production.factoryId).doc();
    final newStockRef = stockRef == null
        ? _stocks(production.factoryId).doc()
        : null;

    await _firestore.runTransaction((transaction) async {
      // All reads must happen before writes.
      DocumentSnapshot<Map<String, dynamic>>? stockSnapshot;

      if (stockRef != null) {
        stockSnapshot = await transaction.get(stockRef);
        if (!stockSnapshot.exists) {
          throw Exception('Stock record not found');
        }
      }

      final quantity = production.bricksProduced.toDouble();
      final now = Timestamp.now();

      transaction.set(productionRef, production.toMap());

      if (stockRef == null) {
        transaction.set(newStockRef!, {
          'factoryId': production.factoryId,
          'productId': production.productId,
          'productName': production.productName,
          'productSize': productSize,
          'quantity': quantity,
          'openingStock': 0,
          'producedQuantity': quantity,
          'soldQuantity': 0,
          'adjustmentQuantity': 0,
          'unit': 'Bricks',
          'updatedAt': now,
          'createdAt': now,
        });
      } else {
        final data = stockSnapshot!.data()!;

        transaction.update(stockRef, {
          'quantity': _number(data['quantity']) + quantity,
          'producedQuantity': _number(data['producedQuantity']) + quantity,
          'productName': production.productName,
          if (productSize.isNotEmpty) 'productSize': productSize,
          'updatedAt': now,
        });
      }
    });
  }

  // ============================================================
  // UPDATE PRODUCTION
  // ============================================================

  Future<void> updateProduction(
    ProductionModel production, {
    String productSize = '',
  }) async {
    if (production.bricksProduced <= 0) {
      throw Exception('Production quantity must be greater than 0');
    }

    final productionRef = _productions(production.factoryId).doc(production.id);

    final oldProductionSnapshot = await productionRef.get();

    if (!oldProductionSnapshot.exists) {
      throw Exception('Production record not found');
    }

    final oldProduction = ProductionModel.fromFirestore(oldProductionSnapshot);

    final oldStockQuery = await _stocks(
      production.factoryId,
    ).where('productId', isEqualTo: oldProduction.productId).limit(1).get();

    final newStockQuery = oldProduction.productId == production.productId
        ? oldStockQuery
        : await _stocks(
            production.factoryId,
          ).where('productId', isEqualTo: production.productId).limit(1).get();

    final oldStockRef = oldStockQuery.docs.isNotEmpty
        ? oldStockQuery.docs.first.reference
        : null;

    final newStockRef = newStockQuery.docs.isNotEmpty
        ? newStockQuery.docs.first.reference
        : null;

    final createdStockRef = newStockRef == null
        ? _stocks(production.factoryId).doc()
        : null;

    await _firestore.runTransaction((transaction) async {
      // --------------------------------------------------------
      // READ ALL DOCUMENTS BEFORE WRITING
      // --------------------------------------------------------

      final currentProductionSnapshot = await transaction.get(productionRef);

      if (!currentProductionSnapshot.exists) {
        throw Exception('Production record not found');
      }

      final currentProduction = ProductionModel.fromFirestore(
        currentProductionSnapshot,
      );

      DocumentSnapshot<Map<String, dynamic>>? oldStockSnapshot;
      DocumentSnapshot<Map<String, dynamic>>? newStockSnapshot;

      if (oldStockRef != null) {
        oldStockSnapshot = await transaction.get(oldStockRef);
        if (!oldStockSnapshot.exists) {
          throw Exception('Old product stock record not found');
        }
      }

      if (newStockRef != null && newStockRef.path != oldStockRef?.path) {
        newStockSnapshot = await transaction.get(newStockRef);
        if (!newStockSnapshot.exists) {
          throw Exception('New product stock record not found');
        }
      } else if (newStockRef != null) {
        newStockSnapshot = oldStockSnapshot;
      }

      final oldQuantity = currentProduction.bricksProduced.toDouble();
      final newQuantity = production.bricksProduced.toDouble();
      final now = Timestamp.now();

      // --------------------------------------------------------
      // SAME PRODUCT
      // --------------------------------------------------------

      if (currentProduction.productId == production.productId) {
        if (oldStockRef == null || oldStockSnapshot == null) {
          throw Exception('Stock record not found');
        }

        final data = oldStockSnapshot.data()!;

        final newStockQuantity =
            _number(data['quantity']) + newQuantity - oldQuantity;

        final newProducedQuantity =
            _number(data['producedQuantity']) + newQuantity - oldQuantity;

        if (newStockQuantity < 0 || newProducedQuantity < 0) {
          throw Exception('Stock cannot become negative.');
        }

        transaction.update(productionRef, production.toMap());

        transaction.update(oldStockRef, {
          'quantity': newStockQuantity,
          'producedQuantity': newProducedQuantity,
          'productName': production.productName,
          if (productSize.isNotEmpty) 'productSize': productSize,
          'updatedAt': now,
        });

        return;
      }

      // --------------------------------------------------------
      // PRODUCT CHANGED: REMOVE OLD PRODUCTION
      // --------------------------------------------------------

      if (oldStockRef == null || oldStockSnapshot == null) {
        throw Exception('Old product stock record not found');
      }

      final oldData = oldStockSnapshot.data()!;

      final updatedOldQuantity = _number(oldData['quantity']) - oldQuantity;

      final updatedOldProduced =
          _number(oldData['producedQuantity']) - oldQuantity;

      if (updatedOldQuantity < 0 || updatedOldProduced < 0) {
        throw Exception(
          'Cannot change product because the old product stock '
          'would become negative.',
        );
      }

      // --------------------------------------------------------
      // UPDATE OR CREATE NEW PRODUCT STOCK
      // --------------------------------------------------------

      if (newStockRef == null) {
        transaction.set(createdStockRef!, {
          'factoryId': production.factoryId,
          'productId': production.productId,
          'productName': production.productName,
          'productSize': productSize,
          'quantity': newQuantity,
          'openingStock': 0,
          'producedQuantity': newQuantity,
          'soldQuantity': 0,
          'adjustmentQuantity': 0,
          'unit': 'Bricks',
          'updatedAt': now,
          'createdAt': now,
        });
      } else {
        final newData = newStockSnapshot!.data()!;

        transaction.update(newStockRef, {
          'quantity': _number(newData['quantity']) + newQuantity,
          'producedQuantity':
              _number(newData['producedQuantity']) + newQuantity,
          'productName': production.productName,
          if (productSize.isNotEmpty) 'productSize': productSize,
          'updatedAt': now,
        });
      }

      // --------------------------------------------------------
      // WRITE AFTER ALL READS
      // --------------------------------------------------------

      transaction.update(oldStockRef, {
        'quantity': updatedOldQuantity,
        'producedQuantity': updatedOldProduced,
        'updatedAt': now,
      });

      transaction.update(productionRef, production.toMap());
    });
  }

  // ============================================================
  // DELETE PRODUCTION
  // ============================================================

  Future<void> deleteProduction(String factoryId, String productionId) async {
    final productionRef = _productions(factoryId).doc(productionId);

    final productionSnapshot = await productionRef.get();

    if (!productionSnapshot.exists) {
      throw Exception('Production record not found');
    }

    final production = ProductionModel.fromFirestore(productionSnapshot);

    final stockQuery = await _stocks(
      factoryId,
    ).where('productId', isEqualTo: production.productId).limit(1).get();

    if (stockQuery.docs.isEmpty) {
      throw Exception('Stock record not found for product');
    }

    final stockRef = stockQuery.docs.first.reference;

    await _firestore.runTransaction((transaction) async {
      // Read both documents before any writes.
      final currentProductionSnapshot = await transaction.get(productionRef);

      if (!currentProductionSnapshot.exists) {
        throw Exception('Production record not found');
      }

      final currentProduction = ProductionModel.fromFirestore(
        currentProductionSnapshot,
      );

      final stockSnapshot = await transaction.get(stockRef);

      if (!stockSnapshot.exists) {
        throw Exception('Stock record not found');
      }

      final stockData = stockSnapshot.data()!;

      final productionQuantity = currentProduction.bricksProduced.toDouble();

      final newQuantity = _number(stockData['quantity']) - productionQuantity;

      final newProducedQuantity =
          _number(stockData['producedQuantity']) - productionQuantity;

      if (newQuantity < 0) {
        throw Exception(
          'Cannot delete production because available stock '
          'would become negative.',
        );
      }

      if (newProducedQuantity < 0) {
        throw Exception('Produced quantity cannot become negative.');
      }

      transaction.update(stockRef, {
        'quantity': newQuantity,
        'producedQuantity': newProducedQuantity,
        'updatedAt': Timestamp.now(),
      });

      transaction.delete(productionRef);
    });
  }

  // ============================================================
  // GET WORKER PRODUCTIONS
  // ============================================================

  Stream<List<ProductionModel>> getWorkerProductions(
    String factoryId,
    String workerId,
  ) {
    return _productions(factoryId)
        .where('workerId', isEqualTo: workerId)
        .orderBy('productionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductionModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ============================================================
  // GET ALL PRODUCTIONS
  // ============================================================

  Stream<List<ProductionModel>> getProductions(String factoryId) {
    return _productions(factoryId)
        .orderBy('productionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductionModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ============================================================
  // FILTERED PRODUCTIONS
  // ============================================================

  Stream<List<ProductionModel>> getProductionsByFilter(
    String factoryId,
    DashboardFilter filter,
  ) {
    final now = DateTime.now();

    late final DateTime startDate;
    late final DateTime endDate;

    switch (filter) {
      case DashboardFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;

      case DashboardFilter.thisWeek:
        final today = DateTime(now.year, now.month, now.day);
        startDate = today.subtract(Duration(days: now.weekday - 1));
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

    return _productions(factoryId)
        .where(
          'productionDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('productionDate', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('productionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductionModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ============================================================
  // TODAY / WEEK / MONTH PRODUCTION
  // ============================================================

  Stream<double> todayProduction(String factoryId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _productionTotalStream(
      factoryId,
      start,
      start.add(const Duration(days: 1)),
    );
  }

  Stream<double> weekProduction(String factoryId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: now.weekday - 1));

    return _productionTotalStream(
      factoryId,
      start,
      start.add(const Duration(days: 7)),
    );
  }

  Stream<double> monthProduction(String factoryId) {
    final now = DateTime.now();

    return _productionTotalStream(
      factoryId,
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 1),
    );
  }

  Stream<List<ProductionModel>> getProductionsByDateRange(
    String factoryId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    // Include the entire selected end date.
    final endExclusive = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));

    return _productions(factoryId)
        .where(
          'productionDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('productionDate', isLessThan: Timestamp.fromDate(endExclusive))
        .orderBy('productionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductionModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<double> _productionTotalStream(
    String factoryId,
    DateTime start,
    DateTime end,
  ) {
    return _productions(factoryId)
        .where(
          'productionDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('productionDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += _number(doc.data()['bricksProduced']);
          }

          return total;
        });
  }
}
