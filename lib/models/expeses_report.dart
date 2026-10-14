import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String factoryId;
  final String title;
  final String category;
  final double amount;
  final String note;
  final Timestamp expenseDate;
  final Timestamp createdAt;

  ExpenseModel({
    required this.id,
    required this.factoryId,
    required this.title,
    required this.category,
    required this.amount,
    required this.note,
    required this.expenseDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "factoryId": factoryId,
      "title": title,
      "category": category,
      "amount": amount,
      "note": note,
      "expenseDate": expenseDate,
      "createdAt": createdAt,
    };
  }

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ExpenseModel(
      id: doc.id,
      factoryId: data["factoryId"] ?? "",
      title: data["title"] ?? "",
      category: data["category"] ?? "Other",
      amount: (data["amount"] ?? 0).toDouble(),
      note: data["note"] ?? "",
      expenseDate: data["expenseDate"] ?? Timestamp.now(),
      createdAt: data["createdAt"] ?? Timestamp.now(),
    );
  }
}
