import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add Payment
  Future<void> addPayment(PaymentModel payment) async {
    final paymentRef = _firestore
        .collection('factories')
        .doc(payment.factoryId)
        .collection('payments')
        .doc();

    final customerRef = _firestore
        .collection('factories')
        .doc(payment.factoryId)
        .collection('customers')
        .doc(payment.customerId);

    await _firestore.runTransaction((transaction) async {
      final customerSnapshot = await transaction.get(customerRef);

      if (!customerSnapshot.exists) {
        throw Exception("Customer not found");
      }

      final customer = CustomerModel.fromFirestore(customerSnapshot);

      final updatedPaid = customer.totalPaid + payment.amount;
      final updatedPending = customer.pendingBalance - payment.amount;

      transaction.set(paymentRef, payment.copyWith(id: paymentRef.id).toMap());

      transaction.update(customerRef, {
        "totalPaid": updatedPaid,
        "pendingBalance": updatedPending < 0 ? 0 : updatedPending,
      });
    });
  }

  /// Update Payment
  Future<void> updatePayment(PaymentModel payment) async {
    await _firestore
        .collection('factories')
        .doc(payment.factoryId)
        .collection('payments')
        .doc(payment.id)
        .update(payment.toMap());
  }

  /// Delete Payment
  Future<void> deletePayment(String factoryId, String paymentId) async {
    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('payments')
        .doc(paymentId)
        .delete();
  }

  /// All Payments
  Stream<List<PaymentModel>> getPayments(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('payments')
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => PaymentModel.fromFirestore(e)).toList(),
        );
  }

  /// Customer Payment History
  Stream<List<PaymentModel>> getCustomerPayments(
    String factoryId,
    String customerId,
  ) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('payments')
        .where('customerId', isEqualTo: customerId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => PaymentModel.fromFirestore(e)).toList(),
        );
  }

  /// Today's Collection
  Stream<double> todayCollection(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);

    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('payments')
        .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('paymentDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['amount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// This Week's Collection
  Stream<double> weekCollection(String factoryId) {
    final now = DateTime.now();

    final start = now.subtract(Duration(days: now.weekday - 1));

    final weekStart = DateTime(start.year, start.month, start.day);

    final weekEnd = weekStart.add(const Duration(days: 7));

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('payments')
        .where(
          'paymentDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
        )
        .where('paymentDate', isLessThan: Timestamp.fromDate(weekEnd))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['amount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// This Month's Collection
  Stream<double> monthCollection(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month);

    final end = DateTime(now.year, now.month + 1);

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('payments')
        .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('paymentDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['amount'] ?? 0).toDouble();
          }

          return total;
        });
  }
}
