import 'package:bricks_application/models/customer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add Customer
  Future<void> addCustomer(CustomerModel customer) async {
    final docRef = _firestore
        .collection('factories')
        .doc(customer.factoryId)
        .collection('customers')
        .doc();

    final newCustomer = customer.copyWith(id: docRef.id);

    await docRef.set(newCustomer.toMap());
  }

  /// Update Customer
  Future<void> updateCustomer(CustomerModel customer) async {
    await _firestore
        .collection('factories')
        .doc(customer.factoryId)
        .collection('customers')
        .doc(customer.id)
        .update(customer.toMap());
  }

  /// Delete Customer
  Future<void> deleteCustomer(String factoryId, String customerId) async {
    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .doc(customerId)
        .delete();
  }

  /// Get All Customers
  Stream<List<CustomerModel>> getCustomers(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CustomerModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get Single Customer
  Future<CustomerModel?> getCustomer(
    String factoryId,
    String customerId,
  ) async {
    final doc = await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .doc(customerId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return CustomerModel.fromFirestore(doc);
  }

  /// Search Customers
  Stream<List<CustomerModel>> searchCustomers(
    String factoryId,
    String keyword,
  ) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CustomerModel.fromFirestore(doc))
              .where(
                (customer) =>
                    customer.name.toLowerCase().contains(
                      keyword.toLowerCase(),
                    ) ||
                    customer.mobile.contains(keyword),
              )
              .toList();
        });
  }

  /// Update Pending Balance
  Future<void> updatePendingBalance({
    required String factoryId,
    required String customerId,
    required double pendingBalance,
  }) async {
    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .doc(customerId)
        .update({'pendingBalance': pendingBalance});
  }

  /// Update Total Purchase
  Future<void> updateTotalPurchase({
    required String factoryId,
    required String customerId,
    required double totalPurchase,
  }) async {
    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .doc(customerId)
        .update({'totalPurchase': totalPurchase});
  }

  /// Increase Purchase Amount
  Future<void> increasePurchase({
    required String factoryId,
    required String customerId,
    required double amount,
  }) async {
    final docRef = _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .doc(customerId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;

      final data = snapshot.data()!;

      final currentPurchase = (data['totalPurchase'] ?? 0).toDouble();

      final currentPending = (data['pendingBalance'] ?? 0).toDouble();

      transaction.update(docRef, {
        'totalPurchase': currentPurchase + amount,
        'pendingBalance': currentPending + amount,
      });
    });
  }

  /// Receive Payment
  Future<void> receivePayment({
    required String factoryId,
    required String customerId,
    required double amount,
  }) async {
    final docRef = _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .doc(customerId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;

      final data = snapshot.data()!;

      final currentPending = (data['pendingBalance'] ?? 0).toDouble();

      double newPending = currentPending - amount;

      if (newPending < 0) {
        newPending = 0;
      }

      transaction.update(docRef, {'pendingBalance': newPending});
    });
  }

  /// Total Customers
  Stream<int> totalCustomers(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Total Pending Amount
  Stream<double> totalPendingAmount(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['pendingBalance'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// Top Pending Customers
  Stream<QuerySnapshot<Map<String, dynamic>>> topPendingCustomers(
    String factoryId,
  ) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('customers')
        .orderBy('pendingBalance', descending: true)
        .limit(5)
        .snapshots();
  }
}
