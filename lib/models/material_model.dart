import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  final String id;
  final String factoryId;
  final String materialName;
  final double quantity;
  final String unit;
  final double price;
  final String supplier;
  final String remarks;
  final Timestamp purchaseDate;
  final Timestamp createdAt;

  MaterialModel({
    required this.id,
    required this.factoryId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.supplier,
    required this.remarks,
    required this.purchaseDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'factoryId': factoryId,
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'supplier': supplier,
      'remarks': remarks,
      'purchaseDate': purchaseDate,
      'createdAt': createdAt,
    };
  }

  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MaterialModel(
      id: doc.id,
      factoryId: data['factoryId'] ?? '',
      materialName: data['materialName'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      supplier: data['supplier'] ?? '',
      remarks: data['remarks'] ?? '',
      purchaseDate: data['purchaseDate'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  MaterialModel copyWith({
    String? id,
    String? factoryId,
    String? materialName,
    double? quantity,
    String? unit,
    double? price,
    String? supplier,
    String? remarks,
    Timestamp? purchaseDate,
    Timestamp? createdAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      supplier: supplier ?? this.supplier,
      remarks: remarks ?? this.remarks,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MaterialModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
