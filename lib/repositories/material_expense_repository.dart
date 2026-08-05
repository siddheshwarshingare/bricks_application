import 'package:bricks_application/models/expense_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add Expense
  Future<void> addExpense(MaterialExpenseModel expense) async {
    await _firestore
        .collection('factories')
        .doc(expense.factoryId)
        .collection('material_expenses')
        .add(expense.toMap());
  }

  /// Update Expense
  Future<void> updateExpense(MaterialExpenseModel expense) async {
    await _firestore
        .collection('factories')
        .doc(expense.factoryId)
        .collection('material_expenses')
        .doc(expense.id)
        .update(expense.toMap());
  }

  /// Delete Expense
  Future<void> deleteExpense(String factoryId, String expenseId) async {
    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('material_expenses')
        .doc(expenseId)
        .delete();
  }

  /// All Expenses
  Stream<List<MaterialExpenseModel>> getExpenses(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('material_expenses')
        .orderBy('expenseDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => MaterialExpenseModel.fromFirestore(e))
              .toList(),
        );
  }

  /// Today's Expense
  Stream<double> todayExpense(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);

    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('material_expenses')
        .where('expenseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('expenseDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (var doc in snapshot.docs) {
            total += (doc['amount'] as num).toDouble();
          }

          return total;
        });
  }

  /// Week Expense
  Stream<double> weekExpense(String factoryId) {
    final now = DateTime.now();

    final start = now.subtract(Duration(days: now.weekday - 1));

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('material_expenses')
        .where('expenseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (var doc in snapshot.docs) {
            total += (doc['amount'] as num).toDouble();
          }

          return total;
        });
  }

  /// Month Expense
  Stream<double> monthExpense(String factoryId) {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, 1);

    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('material_expenses')
        .where('expenseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (var doc in snapshot.docs) {
            total += (doc['amount'] as num).toDouble();
          }

          return total;
        });
  }
}
