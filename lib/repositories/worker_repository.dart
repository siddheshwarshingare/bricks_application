import 'package:bricks_application/models/worker_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add Worker
  Future<void> addWorker(WorkerModel worker) async {
    await _firestore
        .collection('factories')
        .doc(worker.factoryId)
        .collection('workers')
        .add(worker.toMap());
  }

  /// Get All Workers of Selected Factory
  Stream<List<WorkerModel>> getWorkers(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('workers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkerModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Update Worker
  Future<void> updateWorker(WorkerModel worker) async {
    await _firestore
        .collection('factories')
        .doc(worker.factoryId)
        .collection('workers')
        .doc(worker.id)
        .update(worker.toMap());
  }

  Stream<double> monthSalaryExpense(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, 1);

    final end = DateTime(now.year, now.month + 1, 1);

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

    final start = now.subtract(Duration(days: now.weekday - 1));

    final end = start.add(const Duration(days: 7));

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

  /// Delete Worker
  Future<void> deleteWorker({
    required String factoryId,
    required String workerId,
  }) async {
    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('workers')
        .doc(workerId)
        .delete();
  }

  /// Get Single Worker
  Future<WorkerModel?> getWorker({
    required String factoryId,
    required String workerId,
  }) async {
    final doc = await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('workers')
        .doc(workerId)
        .get();

    if (!doc.exists) return null;

    return WorkerModel.fromFirestore(doc);
  }
}
