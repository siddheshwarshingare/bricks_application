import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String id;
  final String factoryId;
  final String customerId;
  final String customerName;

  final String brickType;
  final double quantity;
  final double rate;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;

  final String vehicleNumber;
  final String remarks;

  final Timestamp saleDate;
  final Timestamp createdAt;

  SaleModel({
    required this.id,
    required this.factoryId,
    required this.customerId,
    required this.customerName,
    required this.brickType,
    required this.quantity,
    required this.rate,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.vehicleNumber,
    required this.remarks,
    required this.saleDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'factoryId': factoryId,
      'customerId': customerId,
      'customerName': customerName,
      'brickType': brickType,
      'quantity': quantity,
      'rate': rate,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'vehicleNumber': vehicleNumber,
      'remarks': remarks,
      'saleDate': saleDate,
      'createdAt': createdAt,
    };
  }

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SaleModel(
      id: doc.id,
      factoryId: data['factoryId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      brickType: data['brickType'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      rate: (data['rate'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      pendingAmount: (data['pendingAmount'] ?? 0).toDouble(),
      vehicleNumber: data['vehicleNumber'] ?? '',
      remarks: data['remarks'] ?? '',
      saleDate: data['saleDate'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  SaleModel copyWith({
    String? id,
    String? factoryId,
    String? customerId,
    String? customerName,
    String? brickType,
    double? quantity,
    double? rate,
    double? totalAmount,
    double? paidAmount,
    double? pendingAmount,
    String? vehicleNumber,
    String? remarks,
    Timestamp? saleDate,
    Timestamp? createdAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      brickType: brickType ?? this.brickType,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      remarks: remarks ?? this.remarks,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
