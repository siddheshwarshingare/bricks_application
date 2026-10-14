import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SaleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // COLLECTION REFERENCES
  // ============================================================

  CollectionReference<Map<String, dynamic>> _sales(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales');
  }

  CollectionReference<Map<String, dynamic>> _customers(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers');
  }

  CollectionReference<Map<String, dynamic>> _payments(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('payments');
  }

  CollectionReference<Map<String, dynamic>> _stocks(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('stock');
  }

  // ============================================================
  // TODAY BRICKS SOLD
  // ============================================================

  Stream<double> todayBricksSold(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);

    final end = start.add(const Duration(days: 1));

    return _sales(factoryId)
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('saleDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['quantity'] ?? 0).toDouble();
          }

          return total;
        });
  }

  // ============================================================
  // TODAY PENDING
  // ============================================================

  Stream<double> todayPending(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);

    final end = start.add(const Duration(days: 1));

    return _sales(factoryId)
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('saleDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['pendingAmount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  // ============================================================
  // WEEK PENDING
  // ============================================================

  Stream<double> weekPending(String factoryId) {
    final now = DateTime.now();

    final start = now.subtract(Duration(days: now.weekday - 1));

    final weekStart = DateTime(start.year, start.month, start.day);

    final weekEnd = weekStart.add(const Duration(days: 7));

    return _sales(factoryId)
        .where(
          'saleDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
        )
        .where('saleDate', isLessThan: Timestamp.fromDate(weekEnd))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['pendingAmount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  // ============================================================
  // MONTH PENDING
  // ============================================================

  Stream<double> monthPending(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, 1);

    final end = DateTime(now.year, now.month + 1, 1);

    return _sales(factoryId)
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('saleDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['pendingAmount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  // ============================================================
  // FIND STOCK FOR PRODUCT
  // ============================================================

  Future<DocumentReference<Map<String, dynamic>>> _findStockRef(
    String factoryId,
    String productId,
  ) async {
    final query = await _stocks(
      factoryId,
    ).where('productId', isEqualTo: productId).limit(1).get();

    if (query.docs.isEmpty) {
      throw Exception('Stock record not found for product $productId');
    }

    return query.docs.first.reference;
  }

  // ============================================================
  // ADD SALE
  //
  // Sale
  // + Stock
  // + Customer
  // + Initial Payment
  // ============================================================

  Future<void> addSale(SaleModel sale, CustomerModel customer) async {
    final saleRef = _sales(sale.factoryId).doc();

    final customerRef = _customers(sale.factoryId).doc(customer.id);

    final stockRef = await _findStockRef(sale.factoryId, sale.productId);

    final paymentRef = sale.paidAmount > 0
        ? _payments(sale.factoryId).doc()
        : null;

    await _firestore.runTransaction((transaction) async {
      final customerSnapshot = await transaction.get(customerRef);

      if (!customerSnapshot.exists) {
        throw Exception('Customer not found');
      }

      final stockSnapshot = await transaction.get(stockRef);

      if (!stockSnapshot.exists) {
        throw Exception('Stock not found');
      }

      final customerData = customerSnapshot.data()!;
      final stockData = stockSnapshot.data()!;

      final currentStock = (stockData['quantity'] ?? 0).toDouble();

      final currentSold = (stockData['soldQuantity'] ?? 0).toDouble();

      if (sale.quantity <= 0) {
        throw Exception('Sale quantity must be greater than 0');
      }

      if (sale.totalAmount < 0) {
        throw Exception('Sale amount cannot be negative');
      }

      if (sale.paidAmount < 0) {
        throw Exception('Paid amount cannot be negative');
      }

      if (sale.paidAmount > sale.totalAmount) {
        throw Exception('Paid amount cannot exceed sale amount');
      }

      if (sale.quantity > currentStock) {
        throw Exception(
          'Insufficient stock for ${sale.productName}. '
          'Available stock: ${currentStock.toStringAsFixed(0)}',
        );
      }

      final currentPurchase = (customerData['totalPurchase'] ?? 0).toDouble();

      final currentPaid = (customerData['totalPaid'] ?? 0).toDouble();

      final currentQuantity = (customerData['totalQuantity'] ?? 0).toDouble();

      final openingBalance = (customerData['openingBalance'] ?? 0).toDouble();

      final newStock = currentStock - sale.quantity;

      final newSold = currentSold + sale.quantity;

      final newPurchase = currentPurchase + sale.totalAmount;

      final newPaid = currentPaid + sale.paidAmount;

      final newPending = openingBalance + newPurchase - newPaid;

      final newSale = sale.copyWith(id: saleRef.id);

      // --------------------------------------------------------
      // SALE
      // --------------------------------------------------------

      transaction.set(saleRef, newSale.toMap());

      // --------------------------------------------------------
      // STOCK
      // --------------------------------------------------------

      transaction.update(stockRef, {
        'quantity': newStock,
        'soldQuantity': newSold,
        'updatedAt': Timestamp.now(),
      });

      // --------------------------------------------------------
      // INITIAL PAYMENT
      // --------------------------------------------------------

      if (paymentRef != null) {
        transaction.set(paymentRef, {
          'customerId': customer.id,
          'customerName': customer.name,
          'factoryId': sale.factoryId,
          'saleId': saleRef.id,
          'amount': sale.paidAmount,
          'paymentMethod': 'Cash',
          'referenceNumber': '',
          'remarks': 'Initial payment with sale',
          'paymentDate': sale.saleDate,
          'createdAt': Timestamp.now(),
        });
      }

      // --------------------------------------------------------
      // CUSTOMER
      // --------------------------------------------------------

      transaction.update(customerRef, {
        'totalQuantity': currentQuantity + sale.quantity,
        'totalPurchase': newPurchase,
        'totalPaid': newPaid,
        'pendingBalance': newPending < 0 ? 0 : newPending,
      });
    });
  }

  // ============================================================
  // ADD PAYMENT TO EXISTING SALE
  //
  // Payment
  // + Sale
  // + Customer
  // ============================================================

  Future<void> addPaymentToSale({
    required SaleModel sale,
    required CustomerModel customer,
    required double amount,
    required DateTime paymentDate,
    String paymentMethod = 'Cash',
    String referenceNumber = '',
    String remarks = '',
  }) async {
    if (amount <= 0) {
      throw Exception('Payment amount must be greater than 0');
    }

    final saleRef = _sales(sale.factoryId).doc(sale.id);

    final customerRef = _customers(sale.factoryId).doc(customer.id);

    final paymentRef = _payments(sale.factoryId).doc();

    await _firestore.runTransaction((transaction) async {
      final saleSnapshot = await transaction.get(saleRef);

      final customerSnapshot = await transaction.get(customerRef);

      if (!saleSnapshot.exists) {
        throw Exception('Sale not found');
      }

      if (!customerSnapshot.exists) {
        throw Exception('Customer not found');
      }

      final saleData = saleSnapshot.data()!;
      final customerData = customerSnapshot.data()!;

      final currentPaid = (saleData['paidAmount'] ?? 0).toDouble();

      final totalAmount = (saleData['totalAmount'] ?? 0).toDouble();

      final currentPending = (saleData['pendingAmount'] ?? 0).toDouble();

      if (amount > currentPending) {
        throw Exception(
          'Payment cannot exceed sale pending amount of ₹'
          '${currentPending.toStringAsFixed(2)}',
        );
      }

      final newPaid = currentPaid + amount;

      final newPending = totalAmount - newPaid;

      final currentCustomerPaid = (customerData['totalPaid'] ?? 0).toDouble();

      final openingBalance = (customerData['openingBalance'] ?? 0).toDouble();

      final totalPurchase = (customerData['totalPurchase'] ?? 0).toDouble();

      final newCustomerPaid = currentCustomerPaid + amount;

      final newCustomerPending =
          openingBalance + totalPurchase - newCustomerPaid;

      // --------------------------------------------------------
      // SALE
      // --------------------------------------------------------

      transaction.update(saleRef, {
        'paidAmount': newPaid,
        'pendingAmount': newPending < 0 ? 0 : newPending,
      });

      // --------------------------------------------------------
      // PAYMENT
      // --------------------------------------------------------

      transaction.set(paymentRef, {
        'customerId': customer.id,
        'customerName': customer.name,
        'factoryId': sale.factoryId,
        'saleId': sale.id,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'referenceNumber': referenceNumber,
        'remarks': remarks,
        'paymentDate': Timestamp.fromDate(paymentDate),
        'createdAt': Timestamp.now(),
      });

      // --------------------------------------------------------
      // CUSTOMER
      // --------------------------------------------------------

      transaction.update(customerRef, {
        'totalPaid': newCustomerPaid,
        'pendingBalance': newCustomerPending < 0 ? 0 : newCustomerPending,
      });
    });
  }

  // ============================================================
  // UPDATE SALE
  //
  // Handles:
  // - quantity change
  // - amount change
  // - product change
  // - customer change
  // - stock
  // - customer
  // - existing payments
  // ============================================================

  Future<void> updateSale(SaleModel sale) async {
    final saleRef = _sales(sale.factoryId).doc(sale.id);

    /*
     * First read the old sale.
     */
    final oldSaleSnapshot = await saleRef.get();

    if (!oldSaleSnapshot.exists) {
      throw Exception('Sale not found');
    }

    final oldSaleData = oldSaleSnapshot.data()!;

    final oldProductId = oldSaleData['productId'] ?? '';

    final oldCustomerId = oldSaleData['customerId'] ?? '';

    final oldQuantity = (oldSaleData['quantity'] ?? 0).toDouble();

    final oldTotalAmount = (oldSaleData['totalAmount'] ?? 0).toDouble();

    if (oldProductId.isEmpty) {
      throw Exception('Old sale has no product information');
    }

    if (oldCustomerId.isEmpty) {
      throw Exception('Old sale has no customer information');
    }

    /*
     * Get all payments belonging to this sale.
     *
     * These payment documents are the source of truth
     * for how much has actually been paid.
     */
    final paymentQuery = await _payments(
      sale.factoryId,
    ).where('saleId', isEqualTo: sale.id).get();

    double actualPaid = 0;

    for (final paymentDoc in paymentQuery.docs) {
      actualPaid += (paymentDoc.data()['amount'] ?? 0).toDouble();
    }

    /*
     * If the old sale has a paidAmount but no payment
     * records, preserve the old amount.
     *
     * This protects old data created before payment records
     * were consistently stored.
     */
    if (paymentQuery.docs.isEmpty) {
      actualPaid = (oldSaleData['paidAmount'] ?? 0).toDouble();
    }

    if (sale.totalAmount < actualPaid) {
      throw Exception(
        'Sale amount cannot be less than already received '
        'payment of ₹${actualPaid.toStringAsFixed(2)}',
      );
    }

    if (sale.quantity <= 0) {
      throw Exception('Sale quantity must be greater than 0');
    }

    /*
     * Find old and new stock documents.
     */
    final oldStockRef = await _findStockRef(sale.factoryId, oldProductId);

    final newStockRef = await _findStockRef(sale.factoryId, sale.productId);

    /*
     * Customer references.
     */
    final oldCustomerRef = _customers(sale.factoryId).doc(oldCustomerId);

    final newCustomerRef = _customers(sale.factoryId).doc(sale.customerId);

    await _firestore.runTransaction((transaction) async {
      // --------------------------------------------------------
      // READ SALE
      // --------------------------------------------------------

      final transactionSaleSnapshot = await transaction.get(saleRef);

      if (!transactionSaleSnapshot.exists) {
        throw Exception('Sale not found');
      }

      // --------------------------------------------------------
      // READ OLD STOCK
      // --------------------------------------------------------

      final oldStockSnapshot = await transaction.get(oldStockRef);

      if (!oldStockSnapshot.exists) {
        throw Exception('Old product stock not found');
      }

      // --------------------------------------------------------
      // READ NEW STOCK
      // --------------------------------------------------------

      final newStockSnapshot = await transaction.get(newStockRef);

      if (!newStockSnapshot.exists) {
        throw Exception('New product stock not found');
      }

      // --------------------------------------------------------
      // READ CUSTOMERS
      // --------------------------------------------------------

      final oldCustomerSnapshot = await transaction.get(oldCustomerRef);

      if (!oldCustomerSnapshot.exists) {
        throw Exception('Old customer not found');
      }

      final newCustomerSnapshot = oldCustomerId == sale.customerId
          ? oldCustomerSnapshot
          : await transaction.get(newCustomerRef);

      if (!newCustomerSnapshot.exists) {
        throw Exception('New customer not found');
      }

      final oldStockData = oldStockSnapshot.data()!;

      final newStockData = newStockSnapshot.data()!;

      final oldCustomerData = oldCustomerSnapshot.data()!;

      final newCustomerData = newCustomerSnapshot.data()!;

      // --------------------------------------------------------
      // STOCK VALUES
      // --------------------------------------------------------

      final oldCurrentStock = (oldStockData['quantity'] ?? 0).toDouble();

      final oldSoldQuantity = (oldStockData['soldQuantity'] ?? 0).toDouble();

      final newCurrentStock = (newStockData['quantity'] ?? 0).toDouble();

      final newSoldQuantity = (newStockData['soldQuantity'] ?? 0).toDouble();

      // --------------------------------------------------------
      // SAME PRODUCT
      // --------------------------------------------------------

      if (oldProductId == sale.productId) {
        /*
           * Restore old sale quantity first.
           */
        final availableStock = oldCurrentStock + oldQuantity;

        if (sale.quantity > availableStock) {
          throw Exception(
            'Insufficient stock for ${sale.productName}. '
            'Available stock: '
            '${availableStock.toStringAsFixed(0)}',
          );
        }

        final finalStock = availableStock - sale.quantity;

        final finalSold = oldSoldQuantity - oldQuantity + sale.quantity;

        if (finalSold < 0) {
          throw Exception('Invalid sold quantity.');
        }

        transaction.update(oldStockRef, {
          'quantity': finalStock,
          'soldQuantity': finalSold,
          'updatedAt': Timestamp.now(),
        });
      }
      // --------------------------------------------------------
      // PRODUCT CHANGED
      // --------------------------------------------------------
      else {
        /*
           * Return old sale quantity to old product.
           */
        final restoredOldStock = oldCurrentStock + oldQuantity;

        final restoredOldSold = oldSoldQuantity - oldQuantity;

        if (restoredOldSold < 0) {
          throw Exception('Invalid old sold quantity.');
        }

        transaction.update(oldStockRef, {
          'quantity': restoredOldStock,
          'soldQuantity': restoredOldSold,
          'updatedAt': Timestamp.now(),
        });

        /*
           * Deduct new sale quantity from new product.
           */
        if (sale.quantity > newCurrentStock) {
          throw Exception(
            'Insufficient stock for ${sale.productName}. '
            'Available stock: '
            '${newCurrentStock.toStringAsFixed(0)}',
          );
        }

        final finalNewStock = newCurrentStock - sale.quantity;

        final finalNewSold = newSoldQuantity + sale.quantity;

        transaction.update(newStockRef, {
          'quantity': finalNewStock,
          'soldQuantity': finalNewSold,
          'updatedAt': Timestamp.now(),
        });
      }

      // --------------------------------------------------------
      // CUSTOMER VALUES
      // --------------------------------------------------------

      if (oldCustomerId == sale.customerId) {
        /*
           * Same customer:
           *
           * Remove old sale values and add new values.
           */

        final currentPurchase = (oldCustomerData['totalPurchase'] ?? 0)
            .toDouble();

        final currentQuantity = (oldCustomerData['totalQuantity'] ?? 0)
            .toDouble();

        final currentPaid = (oldCustomerData['totalPaid'] ?? 0).toDouble();

        final openingBalance = (oldCustomerData['openingBalance'] ?? 0)
            .toDouble();

        final updatedPurchase =
            currentPurchase - oldTotalAmount + sale.totalAmount;

        final updatedQuantity = currentQuantity - oldQuantity + sale.quantity;

        /*
           * Payments are preserved.
           *
           * Therefore customer totalPaid is NOT replaced
           * by sale.paidAmount.
           */
        final updatedPending = openingBalance + updatedPurchase - currentPaid;

        transaction.update(oldCustomerRef, {
          'totalPurchase': updatedPurchase < 0 ? 0 : updatedPurchase,
          'totalQuantity': updatedQuantity < 0 ? 0 : updatedQuantity,
          'pendingBalance': updatedPending < 0 ? 0 : updatedPending,
        });
      }
      // --------------------------------------------------------
      // CUSTOMER CHANGED
      // --------------------------------------------------------
      else {
        /*
           * Remove old sale from old customer.
           */
        final oldCurrentPurchase = (oldCustomerData['totalPurchase'] ?? 0)
            .toDouble();

        final oldCurrentQuantity = (oldCustomerData['totalQuantity'] ?? 0)
            .toDouble();

        final oldCurrentPaid = (oldCustomerData['totalPaid'] ?? 0).toDouble();

        final oldOpeningBalance = (oldCustomerData['openingBalance'] ?? 0)
            .toDouble();

        final updatedOldPurchase = oldCurrentPurchase - oldTotalAmount;

        final updatedOldQuantity = oldCurrentQuantity - oldQuantity;

        /*
           * Payments belonging to the sale are moved
           * to the new customer below.
           *
           * So remove their paid amount from old customer.
           */
        final updatedOldPaid = oldCurrentPaid - actualPaid;

        final updatedOldPending =
            oldOpeningBalance + updatedOldPurchase - updatedOldPaid;

        transaction.update(oldCustomerRef, {
          'totalPurchase': updatedOldPurchase < 0 ? 0 : updatedOldPurchase,
          'totalQuantity': updatedOldQuantity < 0 ? 0 : updatedOldQuantity,
          'totalPaid': updatedOldPaid < 0 ? 0 : updatedOldPaid,
          'pendingBalance': updatedOldPending < 0 ? 0 : updatedOldPending,
        });

        /*
           * Add sale to new customer.
           */
        final newCurrentPurchase = (newCustomerData['totalPurchase'] ?? 0)
            .toDouble();

        final newCurrentQuantity = (newCustomerData['totalQuantity'] ?? 0)
            .toDouble();

        final newCurrentPaid = (newCustomerData['totalPaid'] ?? 0).toDouble();

        final newOpeningBalance = (newCustomerData['openingBalance'] ?? 0)
            .toDouble();

        final updatedNewPurchase = newCurrentPurchase + sale.totalAmount;

        final updatedNewQuantity = newCurrentQuantity + sale.quantity;

        final updatedNewPaid = newCurrentPaid + actualPaid;

        final updatedNewPending =
            newOpeningBalance + updatedNewPurchase - updatedNewPaid;

        transaction.update(newCustomerRef, {
          'totalPurchase': updatedNewPurchase,
          'totalQuantity': updatedNewQuantity,
          'totalPaid': updatedNewPaid,
          'pendingBalance': updatedNewPending < 0 ? 0 : updatedNewPending,
        });

        /*
           * Update all payment documents so they now
           * belong to the new customer.
           */
        for (final paymentDoc in paymentQuery.docs) {
          transaction.update(paymentDoc.reference, {
            'customerId': sale.customerId,
            'customerName': sale.customerName,
          });
        }
      }

      // --------------------------------------------------------
      // UPDATE SALE
      // --------------------------------------------------------

      final updatedPending = sale.totalAmount - actualPaid;

      final updatedSale = sale.copyWith(
        paidAmount: actualPaid,
        pendingAmount: updatedPending < 0 ? 0 : updatedPending,
      );

      transaction.update(saleRef, updatedSale.toMap());
    });
  }

  // ============================================================
  // DELETE SALE
  //
  // Sale
  // + Stock
  // + Customer
  // + Payments
  // ============================================================

  Future<void> deleteSale(String factoryId, String saleId) async {
    final saleRef = _sales(factoryId).doc(saleId);

    /*
     * Get payment documents before transaction.
     */
    final paymentQuery = await _payments(
      factoryId,
    ).where('saleId', isEqualTo: saleId).get();

    double totalPaid = 0;

    for (final paymentDoc in paymentQuery.docs) {
      totalPaid += (paymentDoc.data()['amount'] ?? 0).toDouble();
    }

    await _firestore.runTransaction((transaction) async {
      // --------------------------------------------------------
      // SALE
      // --------------------------------------------------------

      final saleSnapshot = await transaction.get(saleRef);

      if (!saleSnapshot.exists) {
        throw Exception('Sale not found');
      }

      final saleData = saleSnapshot.data()!;

      final productId = saleData['productId'] ?? '';

      final customerId = saleData['customerId'] ?? '';

      final quantity = (saleData['quantity'] ?? 0).toDouble();

      final totalAmount = (saleData['totalAmount'] ?? 0).toDouble();

      /*
         * Fallback for old sales where payment records
         * may not exist.
         */
      if (paymentQuery.docs.isEmpty) {
        totalPaid = (saleData['paidAmount'] ?? 0).toDouble();
      }

      if (productId.isEmpty) {
        throw Exception('Sale has no product information');
      }

      if (customerId.isEmpty) {
        throw Exception('Sale has no customer information');
      }

      // --------------------------------------------------------
      // STOCK
      // --------------------------------------------------------

      final stockQuery = await _stocks(
        factoryId,
      ).where('productId', isEqualTo: productId).limit(1).get();

      if (stockQuery.docs.isEmpty) {
        throw Exception('Stock record not found for product $productId');
      }

      final stockRef = stockQuery.docs.first.reference;

      final stockSnapshot = await transaction.get(stockRef);

      if (!stockSnapshot.exists) {
        throw Exception('Stock not found');
      }

      final stockData = stockSnapshot.data()!;

      final currentStock = (stockData['quantity'] ?? 0).toDouble();

      final currentSold = (stockData['soldQuantity'] ?? 0).toDouble();

      final restoredStock = currentStock + quantity;

      final restoredSold = currentSold - quantity;

      if (restoredSold < 0) {
        throw Exception(
          'Cannot delete sale because stock sold quantity '
          'would become negative.',
        );
      }

      transaction.update(stockRef, {
        'quantity': restoredStock,
        'soldQuantity': restoredSold,
        'updatedAt': Timestamp.now(),
      });

      // --------------------------------------------------------
      // CUSTOMER
      // --------------------------------------------------------

      final customerRef = _customers(factoryId).doc(customerId);

      final customerSnapshot = await transaction.get(customerRef);

      if (!customerSnapshot.exists) {
        throw Exception('Customer not found');
      }

      final customerData = customerSnapshot.data()!;

      final currentPurchase = (customerData['totalPurchase'] ?? 0).toDouble();

      final currentQuantity = (customerData['totalQuantity'] ?? 0).toDouble();

      final currentPaid = (customerData['totalPaid'] ?? 0).toDouble();

      final openingBalance = (customerData['openingBalance'] ?? 0).toDouble();

      final updatedPurchase = currentPurchase - totalAmount;

      final updatedQuantity = currentQuantity - quantity;

      final updatedPaid = currentPaid - totalPaid;

      final updatedPending = openingBalance + updatedPurchase - updatedPaid;

      transaction.update(customerRef, {
        'totalPurchase': updatedPurchase < 0 ? 0 : updatedPurchase,
        'totalQuantity': updatedQuantity < 0 ? 0 : updatedQuantity,
        'totalPaid': updatedPaid < 0 ? 0 : updatedPaid,
        'pendingBalance': updatedPending < 0 ? 0 : updatedPending,
      });

      // --------------------------------------------------------
      // DELETE PAYMENTS
      // --------------------------------------------------------

      for (final paymentDoc in paymentQuery.docs) {
        transaction.delete(paymentDoc.reference);
      }

      // --------------------------------------------------------
      // DELETE SALE
      // --------------------------------------------------------

      transaction.delete(saleRef);
    });
  }

  // ============================================================
  // ALL SALES
  // ============================================================

  Stream<List<SaleModel>> getSales(String factoryId) {
    return _sales(factoryId)
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => SaleModel.fromFirestore(e)).toList(),
        );
  }

  // ============================================================
  // CUSTOMER SALES
  // ============================================================

  Stream<List<SaleModel>> getCustomerSales(
    String factoryId,
    String customerId,
  ) {
    return _sales(factoryId)
        .where('customerId', isEqualTo: customerId)
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => SaleModel.fromFirestore(e)).toList(),
        );
  }

  // ============================================================
  // WEEK BRICKS SOLD
  // ============================================================

  Stream<double> weekBricksSold(String factoryId) {
    final now = DateTime.now();

    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return _sales(factoryId)
        .where(
          'saleDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek),
        )
        .where('saleDate', isLessThan: Timestamp.fromDate(endOfWeek))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['quantity'] ?? 0).toDouble();
          }

          return total;
        });
  }

  // ============================================================
  // MONTH BRICKS SOLD
  // ============================================================

  Stream<double> monthBricksSold(String factoryId) {
    final now = DateTime.now();

    final firstDay = DateTime(now.year, now.month, 1);

    final lastDay = DateTime(now.year, now.month + 1, 1);

    return _sales(factoryId)
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('saleDate', isLessThan: Timestamp.fromDate(lastDay))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['quantity'] ?? 0).toDouble();
          }

          return total;
        });
  }

  // ============================================================
  // TOTAL SALES AMOUNT
  // ============================================================

  Stream<double> totalSales(String factoryId) {
    return _sales(factoryId).snapshots().map((snapshot) {
      double total = 0;

      for (final doc in snapshot.docs) {
        total += (doc.data()['totalAmount'] ?? 0).toDouble();
      }

      return total;
    });
  }

  // ============================================================
  // TODAY SALES
  // ============================================================

  Stream<double> todaySales(String factoryId) {
    final today = DateTime.now();

    final start = DateTime(today.year, today.month, today.day);

    final end = start.add(const Duration(days: 1));

    return _sales(factoryId)
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('saleDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['totalAmount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  // ============================================================
  // WEEK SALES
  // ============================================================

  Stream<double> weekSales(String factoryId) {
    final now = DateTime.now();

    final start = now.subtract(Duration(days: now.weekday - 1));

    final weekStart = DateTime(start.year, start.month, start.day);

    final weekEnd = weekStart.add(const Duration(days: 7));

    return _sales(factoryId)
        .where(
          'saleDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
        )
        .where('saleDate', isLessThan: Timestamp.fromDate(weekEnd))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['totalAmount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  // ============================================================
  // MONTH SALES
  // ============================================================

  Stream<double> monthSales(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month);

    final end = DateTime(now.year, now.month + 1);

    return _sales(factoryId)
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('saleDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['totalAmount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  Future<List<SaleModel>> getCustomerSalesOnce(
    String factoryId,
    String customerId,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .where('customerId', isEqualTo: customerId)
        .get(const GetOptions(source: Source.server));

    return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
  } // ============================================================
  // TOTAL BRICKS SOLD
  // ============================================================

  Stream<double> totalBricksSold(String factoryId) {
    return _sales(factoryId).snapshots().map((snapshot) {
      double total = 0;

      for (final doc in snapshot.docs) {
        total += (doc.data()['quantity'] ?? 0).toDouble();
      }

      return total;
    });
  }
}
