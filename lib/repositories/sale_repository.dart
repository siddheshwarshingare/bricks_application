import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<double> todayBricksSold(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('saleDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc['quantity'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// ===========================
  /// Add Sale
  /// ===========================
  Future<void> addSale(SaleModel sale, CustomerModel customer) async {
    final saleRef = _firestore
        .collection('factories')
        .doc(sale.factoryId)
        .collection('sales')
        .doc();

    final customerRef = _firestore
        .collection('factories')
        .doc(sale.factoryId)
        .collection('customers')
        .doc(customer.id);

    await _firestore.runTransaction((transaction) async {
      final customerSnapshot = await transaction.get(customerRef);

      if (!customerSnapshot.exists) {
        throw Exception("Customer not found");
      }

      final newSale = sale.copyWith(id: saleRef.id);

      transaction.set(saleRef, newSale.toMap());
      if (sale.paidAmount > 0) {
        final paymentRef = _firestore
            .collection('factories')
            .doc(sale.factoryId)
            .collection('payments')
            .doc();

        transaction.set(paymentRef, {
          "customerId": sale.customerId,
          "customerName": sale.customerName,
          "factoryId": sale.factoryId,
          "amount": sale.paidAmount,
          "paymentMethod": "Cash",
          "referenceNumber": "",
          "remarks": "Initial payment with sale",
          "paymentDate": sale.saleDate,
          "createdAt": Timestamp.now(),
        });
      }

      final currentPurchase = (customerSnapshot['totalPurchase'] ?? 0)
          .toDouble();

      final currentPaid = (customerSnapshot['totalPaid'] ?? 0).toDouble();
      final currentQuantity = (customerSnapshot['totalQuantity'] ?? 0)
          .toDouble();
      final openingBalance = (customerSnapshot['openingBalance'] ?? 0)
          .toDouble();

      final updatedPurchase = currentPurchase + sale.totalAmount;

      final updatedPaid = currentPaid + sale.paidAmount;

      final updatedPending = openingBalance + updatedPurchase - updatedPaid;

      transaction.update(customerRef, {
        'totalQuantity': currentQuantity + sale.quantity,
        'totalPurchase': updatedPurchase,

        'totalPaid': updatedPaid,
        'pendingBalance': updatedPending,
      });
    });
  }

  Future<void> addPaymentToSale({
    required SaleModel sale,
    required CustomerModel customer,
    required double amount,
    String paymentMethod = "Cash",
    String referenceNumber = "",
    String remarks = "",
  }) async {
    if (amount <= 0) {
      throw Exception("Payment amount must be greater than 0");
    }

    if (amount > sale.pendingAmount) {
      throw Exception("Payment cannot be greater than pending amount");
    }

    final saleRef = _firestore
        .collection('factories')
        .doc(sale.factoryId)
        .collection('sales')
        .doc(sale.id);

    final customerRef = _firestore
        .collection('factories')
        .doc(sale.factoryId)
        .collection('customers')
        .doc(customer.id);

    final paymentRef = _firestore
        .collection('factories')
        .doc(sale.factoryId)
        .collection('payments')
        .doc();

    await _firestore.runTransaction((transaction) async {
      // Read current values from Firestore
      final saleSnapshot = await transaction.get(saleRef);
      final customerSnapshot = await transaction.get(customerRef);

      if (!saleSnapshot.exists) {
        throw Exception("Sale not found");
      }

      if (!customerSnapshot.exists) {
        throw Exception("Customer not found");
      }

      final saleData = saleSnapshot.data() as Map<String, dynamic>;
      final customerData = customerSnapshot.data() as Map<String, dynamic>;

      final currentPaid = (saleData['paidAmount'] ?? 0).toDouble();

      final totalAmount = (saleData['totalAmount'] ?? 0).toDouble();

      final newPaid = currentPaid + amount;

      final newPending = totalAmount - newPaid;

      // --------------------------------
      // 1. UPDATE SALE
      // --------------------------------

      transaction.update(saleRef, {
        'paidAmount': newPaid,
        'pendingAmount': newPending < 0 ? 0 : newPending,
      });

      // --------------------------------
      // 2. ADD PAYMENT RECORD
      // --------------------------------

      transaction.set(paymentRef, {
        'customerId': sale.customerId,
        'customerName': sale.customerName,
        'factoryId': sale.factoryId,
        'saleId': sale.id,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'referenceNumber': referenceNumber,
        'remarks': remarks,
        'paymentDate': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      // --------------------------------
      // 3. UPDATE CUSTOMER
      // --------------------------------

      final currentCustomerPaid = (customerData['totalPaid'] ?? 0).toDouble();

      final currentPendingBalance = (customerData['pendingBalance'] ?? 0)
          .toDouble();

      transaction.update(customerRef, {
        'totalPaid': currentCustomerPaid + amount,
        'pendingBalance': currentPendingBalance - amount < 0
            ? 0
            : currentPendingBalance - amount,
      });
    });
  }

  /// ===========================
  /// Update Sale
  /// ===========================
  Future<void> updateSale(SaleModel sale) async {
    await _firestore
        .collection('factories')
        .doc(sale.factoryId)
        .collection('sales')
        .doc(sale.id)
        .update(sale.toMap());
  }

  Stream<double> weekBricksSold(String factoryId) {
    final now = DateTime.now();

    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return FirebaseFirestore.instance
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .where(
          'saleDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek),
        )
        .where('saleDate', isLessThan: Timestamp.fromDate(endOfWeek))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (var doc in snapshot.docs) {
            total += (doc['quantity'] as num).toDouble();
          }

          return total;
        });
  }

  Stream<double> monthBricksSold(String factoryId) {
    final now = DateTime.now();

    final firstDay = DateTime(now.year, now.month, 1);

    final lastDay = DateTime(now.year, now.month + 1, 1);

    return FirebaseFirestore.instance
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('saleDate', isLessThan: Timestamp.fromDate(lastDay))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc['quantity'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// ===========================
  /// Delete Sale
  /// ===========================
  Future<void> deleteSale(String factoryId, String saleId) async {
    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .doc(saleId)
        .delete();
  }

  /// ===========================
  /// All Sales
  /// ===========================
  Stream<List<SaleModel>> getSales(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => SaleModel.fromFirestore(e)).toList(),
        );
  }

  /// ===========================
  /// Customer Sales
  /// ===========================
  Stream<List<SaleModel>> getCustomerSales(
    String factoryId,
    String customerId,
  ) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .where('customerId', isEqualTo: customerId)
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => SaleModel.fromFirestore(e)).toList(),
        );
  }

  /// ===========================
  /// Total Sales Amount
  /// ===========================
  Stream<double> totalSales(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['totalAmount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// ===========================
  /// Today's Sales
  /// ===========================
  Stream<double> todaySales(String factoryId) {
    final today = DateTime.now();

    final start = DateTime(today.year, today.month, today.day);

    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
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

  /// This Week's Sales
  Stream<double> weekSales(String factoryId) {
    final now = DateTime.now();

    final start = now.subtract(Duration(days: now.weekday - 1));

    final weekStart = DateTime(start.year, start.month, start.day);

    final weekEnd = weekStart.add(const Duration(days: 7));

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
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

  /// This Month's Sales
  Stream<double> monthSales(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month);

    final end = DateTime(now.year, now.month + 1);

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
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

  /// ===========================
  /// Total Quantity Sold
  /// ===========================
  Stream<double> totalBricksSold(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('sales')
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['quantity'] ?? 0).toDouble();
          }

          return total;
        });
  }
}
