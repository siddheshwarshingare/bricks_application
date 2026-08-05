import 'package:bricks_application/models/worker_payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerPaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<double> todaySalaryExpense(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('factories')
        .doc(factoryId)
        .collection('worker_payments')
        .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('paymentDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc['amount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  Stream<double> weekSalaryExpense(String factoryId) {
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
        .collection('worker_payments')
        .where(
          'paymentDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek),
        )
        .where('paymentDate', isLessThan: Timestamp.fromDate(endOfWeek))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (var doc in snapshot.docs) {
            total += (doc['amount'] as num).toDouble();
          }

          return total;
        });
  }

  /// ===========================
  /// Add Worker Payment
  /// ===========================
  Future<void> addPayment(WorkerPaymentModel payment) async {
    final paymentRef = _firestore
        .collection("factories")
        .doc(payment.factoryId)
        .collection("worker_payments")
        .doc();

    final newPayment = payment.copyWith(id: paymentRef.id);

    await paymentRef.set(newPayment.toMap());
  }

  /// ===========================
  /// Update Payment
  /// ===========================
  Future<void> updatePayment(WorkerPaymentModel payment) async {
    await _firestore
        .collection("factories")
        .doc(payment.factoryId)
        .collection("worker_payments")
        .doc(payment.id)
        .update(payment.toMap());
  }

  Stream<double> monthSalaryExpense(String factoryId) {
    final now = DateTime.now();

    final firstDay = DateTime(now.year, now.month, 1);

    final lastDay = DateTime(now.year, now.month + 1, 1);

    return FirebaseFirestore.instance
        .collection('factories')
        .doc(factoryId)
        .collection('worker_payments')
        .where(
          'paymentDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay),
        )
        .where('paymentDate', isLessThan: Timestamp.fromDate(lastDay))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc['amount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// ===========================
  /// Delete Payment
  /// ===========================
  Future<void> deletePayment({
    required String factoryId,
    required String paymentId,
  }) async {
    await _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("worker_payments")
        .doc(paymentId)
        .delete();
  }

  /// ===========================
  /// Worker Payment History
  /// ===========================
  Stream<List<WorkerPaymentModel>> getWorkerPayments(
    String factoryId,
    String workerId,
  ) {
    return _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("worker_payments")
        .where("workerId", isEqualTo: workerId)
        .orderBy("paymentDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkerPaymentModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// ===========================
  /// Total Salary Paid
  /// ===========================
  Stream<double> totalSalaryPaid(String factoryId, String workerId) {
    return _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("worker_payments")
        .where("workerId", isEqualTo: workerId)
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()["amount"] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// ===========================
  /// Factory Total Salary Paid
  /// ===========================
  Stream<double> totalFactorySalaryPaid(String factoryId) {
    return _firestore
        .collection("factories")
        .doc(factoryId)
        .collection("worker_payments")
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()["amount"] ?? 0).toDouble();
          }

          return total;
        });
  }
}
