import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialPurchaseModel {
  final String id;
  final String materialName;
  final double quantity;
  final double amount;
  final Timestamp purchaseDate;

  MaterialPurchaseModel({
    required this.id,
    required this.materialName,
    required this.quantity,
    required this.amount,
    required this.purchaseDate,
  });

  factory MaterialPurchaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MaterialPurchaseModel(
      id: doc.id,
      materialName: data['materialName'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      amount: (data['amount'] ?? 0).toDouble(),
      purchaseDate: data['purchaseDate'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialName': materialName,
      'quantity': quantity,
      'amount': amount,
      'purchaseDate': purchaseDate,
    };
  }
}
