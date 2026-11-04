import 'package:bricks_application/models/stock_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _stockCollection(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('stock');
  }

  CollectionReference<Map<String, dynamic>> _adjustmentHistoryCollection(
    String factoryId,
  ) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('stockAdjustments');
  }

  // ============================================================
  // GET ALL STOCK
  // ============================================================

  Stream<List<StockModel>> getStock(String factoryId) {
    return _stockCollection(factoryId)
        .orderBy('productName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StockModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ============================================================
  // GET STOCK FOR ONE PRODUCT
  // ============================================================

  Stream<StockModel?> getProductStock({
    required String factoryId,
    required String productId,
  }) {
    return _stockCollection(factoryId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          return StockModel.fromFirestore(snapshot.docs.first);
        });
  }

  // ============================================================
  // CREATE INITIAL STOCK
  // ============================================================

  Future<void> createStock({
    required String factoryId,
    required String productId,
    required String productName,
    required double openingStock,
    String unit = 'pcs',
  }) async {
    if (openingStock < 0) {
      throw Exception('Opening stock cannot be negative');
    }

    final query = await _stockCollection(
      factoryId,
    ).where('productId', isEqualTo: productId).limit(1).get();

    if (query.docs.isNotEmpty) {
      throw Exception('Stock already exists for this product');
    }

    final docRef = _stockCollection(factoryId).doc();

    final now = Timestamp.now();

    final stock = StockModel(
      id: docRef.id,
      factoryId: factoryId,
      productId: productId,
      productName: productName,
      quantity: openingStock,
      openingStock: openingStock,
      producedQuantity: 0,
      soldQuantity: 0,
      adjustmentQuantity: 0,
      unit: unit,
      updatedAt: now,
      createdAt: now,
    );

    await docRef.set(stock.toMap());
  }

  // ============================================================
  // ADD PRODUCTION STOCK
  // ============================================================

  Future<void> addProductionStock({
    required String factoryId,
    required String productId,
    required String productName,
    required double quantity,
    String productSize = '',
    String unit = 'pcs',
  }) async {
    if (quantity <= 0) {
      throw Exception('Production quantity must be greater than 0');
    }

    final query = await _stockCollection(
      factoryId,
    ).where('productId', isEqualTo: productId).limit(1).get();

    DocumentReference<Map<String, dynamic>> stockRef;

    // ----------------------------------------------------------
    // CREATE STOCK IF IT DOES NOT EXIST
    // ----------------------------------------------------------

    if (query.docs.isEmpty) {
      stockRef = _stockCollection(factoryId).doc();

      final now = Timestamp.now();

      await stockRef.set({
        'factoryId': factoryId,
        'productId': productId,
        'productName': productName,
        'productSize': productSize,
        'quantity': quantity,
        'openingStock': 0,
        'producedQuantity': quantity,
        'soldQuantity': 0,
        'adjustmentQuantity': 0,
        'unit': unit,
        'updatedAt': now,
        'createdAt': now,
      });

      return;
    }

    stockRef = query.docs.first.reference;

    // ----------------------------------------------------------
    // UPDATE EXISTING STOCK
    // ----------------------------------------------------------

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(stockRef);

      if (!snapshot.exists) {
        throw Exception('Stock not found');
      }

      final data = snapshot.data()!;

      final currentQuantity = (data['quantity'] as num?)?.toDouble() ?? 0;

      final currentProduced =
          (data['producedQuantity'] as num?)?.toDouble() ?? 0;

      transaction.update(stockRef, {
        'quantity': currentQuantity + quantity,
        'producedQuantity': currentProduced + quantity,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  // ============================================================
  // REMOVE STOCK AFTER SALE
  // ============================================================

  Future<void> removeSaleStock({
    required String factoryId,
    required String productId,
    required double quantity,
  }) async {
    if (quantity <= 0) {
      throw Exception('Sale quantity must be greater than 0');
    }

    final query = await _stockCollection(
      factoryId,
    ).where('productId', isEqualTo: productId).limit(1).get();

    if (query.docs.isEmpty) {
      throw Exception('Stock record not found');
    }

    final stockRef = query.docs.first.reference;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(stockRef);

      if (!snapshot.exists) {
        throw Exception('Stock not found');
      }

      final data = snapshot.data()!;

      final currentQuantity = (data['quantity'] as num?)?.toDouble() ?? 0;

      final currentSold = (data['soldQuantity'] as num?)?.toDouble() ?? 0;

      if (quantity > currentQuantity) {
        throw Exception(
          'Insufficient stock. '
          'Available: $currentQuantity',
        );
      }

      transaction.update(stockRef, {
        'quantity': currentQuantity - quantity,
        'soldQuantity': currentSold + quantity,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  // ============================================================
  // ADJUST STOCK + SAVE HISTORY
  // ============================================================

  Future<void> adjustStock({
    required String factoryId,
    required String productId,
    required double adjustment,
    required String reason,
  }) async {
    if (adjustment == 0) {
      throw Exception('Adjustment cannot be zero');
    }

    if (reason.trim().isEmpty) {
      throw Exception('Adjustment reason is required');
    }

    // ----------------------------------------------------------
    // FIND STOCK DOCUMENT
    // ----------------------------------------------------------

    final query = await _stockCollection(
      factoryId,
    ).where('productId', isEqualTo: productId).limit(1).get();

    if (query.docs.isEmpty) {
      throw Exception('Stock record not found');
    }

    final stockRef = query.docs.first.reference;

    // ----------------------------------------------------------
    // HISTORY DOCUMENT
    // ----------------------------------------------------------

    final historyRef = _adjustmentHistoryCollection(factoryId).doc();

    // ----------------------------------------------------------
    // TRANSACTION
    // ----------------------------------------------------------

    await _firestore.runTransaction((transaction) async {
      final stockSnapshot = await transaction.get(stockRef);

      if (!stockSnapshot.exists) {
        throw Exception('Stock not found');
      }

      final data = stockSnapshot.data()!;

      final currentQuantity = (data['quantity'] as num?)?.toDouble() ?? 0;

      final currentAdjustment =
          (data['adjustmentQuantity'] as num?)?.toDouble() ?? 0;

      final newQuantity = currentQuantity + adjustment;

      // ------------------------------------------------------
      // PREVENT NEGATIVE STOCK
      // ------------------------------------------------------

      if (newQuantity < 0) {
        throw Exception(
          'Stock cannot become negative. '
          'Available: '
          '${currentQuantity.toStringAsFixed(0)}',
        );
      }

      final now = Timestamp.now();

      // ------------------------------------------------------
      // UPDATE STOCK
      // ------------------------------------------------------

      transaction.update(stockRef, {
        'quantity': newQuantity,
        'adjustmentQuantity': currentAdjustment + adjustment,
        'updatedAt': now,
      });

      // ------------------------------------------------------
      // SAVE ADJUSTMENT HISTORY
      // ------------------------------------------------------

      transaction.set(historyRef, {
        'id': historyRef.id,
        'factoryId': factoryId,
        'productId': productId,
        'productName': data['productName'] ?? '',
        'unit': data['unit'] ?? 'pcs',

        'adjustment': adjustment,

        'previousStock': currentQuantity,

        'newStock': newQuantity,

        'reason': reason.trim(),

        'createdAt': now,
      });
    });
  }

  // ============================================================
  // DELETE STOCK
  // ============================================================

  Future<void> deleteStock({
    required String factoryId,
    required String stockId,
  }) async {
    await _stockCollection(factoryId).doc(stockId).delete();
  }

  // ============================================================
  // TOTAL FINISHED STOCK
  // ============================================================

  Stream<double> totalStock(String factoryId) {
    return _stockCollection(factoryId).snapshots().map((snapshot) {
      double total = 0;

      for (final doc in snapshot.docs) {
        total += (doc.data()['quantity'] as num?)?.toDouble() ?? 0;
      }

      return total;
    });
  }
}
