import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String factoryId;
  final String name;
  final String size;
  final String unit;

  final double sellingPrice;
  final double productionCost;

  final double stock;
  final double minimumStock;

  final bool active;
  final Timestamp createdAt;

  ProductModel({
    required this.id,
    required this.factoryId,
    required this.name,
    required this.size,
    required this.unit,
    required this.sellingPrice,
    required this.productionCost,
    required this.stock,
    required this.minimumStock,
    required this.active,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'factoryId': factoryId,
      'name': name,
      'size': size,
      'unit': unit,
      'sellingPrice': sellingPrice,
      'productionCost': productionCost,

      'stock': stock,
      'minimumStock': minimumStock,

      'active': active,
      'createdAt': createdAt,
    };
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,

      factoryId: data['factoryId'] ?? '',
      name: data['name'] ?? '',
      size: data['size'] ?? '',
      unit: data['unit'] ?? 'piece',

      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      productionCost: (data['productionCost'] ?? 0).toDouble(),

      stock: (data['stock'] ?? 0).toDouble(),
      minimumStock: (data['minimumStock'] ?? 0).toDouble(),

      active: data['active'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? factoryId,
    String? name,
    String? size,
    String? unit,
    double? sellingPrice,
    double? productionCost,
    double? stock,
    double? minimumStock,
    bool? active,
    Timestamp? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      name: name ?? this.name,
      size: size ?? this.size,
      unit: unit ?? this.unit,

      sellingPrice: sellingPrice ?? this.sellingPrice,
      productionCost: productionCost ?? this.productionCost,

      stock: stock ?? this.stock,
      minimumStock: minimumStock ?? this.minimumStock,

      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
