import 'package:bricks_application/models/worker_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _workers(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('workers');
  }

  CollectionReference<Map<String, dynamic>> _payments(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('worker_payments');
  }

  CollectionReference<Map<String, dynamic>> _attendance(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('temporary_worker_attendance');
  }

  /// ADD WORKER
  Future<void> addWorker(WorkerModel worker) async {
    await _workers(worker.factoryId).add(worker.toMap());
  }

  /// GET ALL WORKERS
  Stream<List<WorkerModel>> getWorkers(String factoryId) {
    return _workers(factoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkerModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// GET WORKERS BY TYPE
  Stream<List<WorkerModel>> getWorkersByType({
    required String factoryId,
    required String workerType,
  }) {
    return _workers(factoryId)
        .where('workerType', isEqualTo: workerType)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkerModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// UPDATE WORKER
  Future<void> updateWorker(WorkerModel worker) async {
    await _workers(worker.factoryId).doc(worker.id).update(worker.toMap());
  }

  /// GET SINGLE WORKER
  Future<WorkerModel?> getWorker({
    required String factoryId,
    required String workerId,
  }) async {
    final doc = await _workers(factoryId).doc(workerId).get();

    if (!doc.exists) return null;

    return WorkerModel.fromFirestore(doc);
  }

  /// DELETE WORKER
  Future<void> deleteWorker({
    required String factoryId,
    required String workerId,
  }) async {
    await _workers(factoryId).doc(workerId).delete();
  }

  /// MARK TEMPORARY WORKER ATTENDANCE
  Future<void> markTemporaryAttendance({
    required String factoryId,
    required String workerId,
    required String workerName,
    required DateTime date,
    required String attendance,
    required double dailyWage,
  }) async {
    if (!['full_day', 'half_day', 'absent'].contains(attendance)) {
      throw ArgumentError('Invalid attendance type.');
    }

    if (dailyWage < 0) {
      throw ArgumentError('Daily wage cannot be negative.');
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey =
        '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}';

    final attendanceId = '${workerId}_$dateKey';

    final earnedAmount = attendance == 'full_day'
        ? dailyWage
        : attendance == 'half_day'
        ? dailyWage / 2
        : 0.0;

    await _attendance(factoryId).doc(attendanceId).set({
      'factoryId': factoryId,
      'workerId': workerId,
      'workerName': workerName,
      'date': Timestamp.fromDate(normalizedDate),
      'dateKey': dateKey,
      'attendance': attendance,
      'dailyWage': dailyWage,
      'earnedAmount': earnedAmount,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// GET TEMPORARY WORKER ATTENDANCE
  Stream<QuerySnapshot<Map<String, dynamic>>> getTemporaryAttendance({
    required String factoryId,
    required String workerId,
  }) {
    return _attendance(factoryId)
        .where('workerId', isEqualTo: workerId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// GET MONTHLY TEMPORARY WORKER EARNINGS
  Stream<double> getMonthlyTemporaryEarnings({
    required String factoryId,
    required String workerId,
    required DateTime month,
  }) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return _attendance(factoryId)
        .where('workerId', isEqualTo: workerId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            total += (doc.data()['earnedAmount'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// MONTHLY SALARY EXPENSE
  Stream<double> monthSalaryExpense(String factoryId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    return _payments(factoryId)
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

  /// WEEKLY SALARY EXPENSE
  Stream<double> weekSalaryExpense(String factoryId) {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));

    return _payments(factoryId)
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
