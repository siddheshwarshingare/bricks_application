import 'package:cloud_firestore/cloud_firestore.dart';

class StockModel {
  final String id;
  final String factoryId;
  final String productId;
  final String productName;
  final String productSize;

  final double quantity;

  final double openingStock;
  final double producedQuantity;
  final double soldQuantity;
  final double adjustmentQuantity;

  final String unit;

  final Timestamp updatedAt;
  final Timestamp createdAt;

  StockModel({
    required this.id,
    required this.factoryId,
    required this.productId,
    required this.productName,
    this.productSize = '',
    required this.quantity,
    required this.openingStock,
    required this.producedQuantity,
    required this.soldQuantity,
    required this.adjustmentQuantity,
    required this.unit,
    required this.updatedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'factoryId': factoryId,
      'productId': productId,
      'productName': productName,
      'productSize': productSize,
      'quantity': quantity,
      'openingStock': openingStock,
      'producedQuantity': producedQuantity,
      'soldQuantity': soldQuantity,
      'adjustmentQuantity': adjustmentQuantity,
      'unit': unit,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
    };
  }

  factory StockModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return StockModel(
      id: doc.id,
      factoryId: data['factoryId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productSize: (data['productSize'] ?? '').toString(),
      quantity: (data['quantity'] ?? 0).toDouble(),
      openingStock: (data['openingStock'] ?? 0).toDouble(),
      producedQuantity: (data['producedQuantity'] ?? 0).toDouble(),
      soldQuantity: (data['soldQuantity'] ?? 0).toDouble(),
      adjustmentQuantity: (data['adjustmentQuantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'pcs',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  StockModel copyWith({
    String? id,
    String? factoryId,
    String? productId,
    String? productName,
    String? productSize,
    double? quantity,
    double? openingStock,
    double? producedQuantity,
    double? soldQuantity,
    double? adjustmentQuantity,
    String? unit,
    Timestamp? updatedAt,
    Timestamp? createdAt,
  }) {
    return StockModel(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSize: productSize ?? this.productSize,
      quantity: quantity ?? this.quantity,
      openingStock: openingStock ?? this.openingStock,
      producedQuantity: producedQuantity ?? this.producedQuantity,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      adjustmentQuantity: adjustmentQuantity ?? this.adjustmentQuantity,
      unit: unit ?? this.unit,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
