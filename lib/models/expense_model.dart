import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialExpenseModel {
  final String id;
  final String factoryId;
  final String materialName;
  final double amount;
  final String note;
  final Timestamp expenseDate;
  final Timestamp createdAt;

  MaterialExpenseModel({
    required this.id,
    required this.factoryId,
    required this.materialName,
    required this.amount,
    required this.note,
    required this.expenseDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "factoryId": factoryId,
      "materialName": materialName,
      "amount": amount,
      "note": note,
      "expenseDate": expenseDate,
      "createdAt": createdAt,
    };
  }

  factory MaterialExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MaterialExpenseModel(
      id: doc.id,
      factoryId: data["factoryId"] ?? "",
      materialName: data["materialName"] ?? "",
      amount: (data["amount"] ?? 0).toDouble(),
      note: data["note"] ?? "",
      expenseDate: data["expenseDate"] ?? Timestamp.now(),
      createdAt: data["createdAt"] ?? Timestamp.now(),
    );
  }
}
