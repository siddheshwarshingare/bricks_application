import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String factoryId;
  final String customerId;
  final String customerName;

  final double amount;

  final String paymentMethod;
  final String referenceNumber;
  final String remarks;

  final Timestamp paymentDate;
  final Timestamp createdAt;

  PaymentModel({
    required this.id,
    required this.factoryId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.remarks,
    required this.paymentDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "factoryId": factoryId,
      "customerId": customerId,
      "customerName": customerName,
      "amount": amount,
      "paymentMethod": paymentMethod,
      "referenceNumber": referenceNumber,
      "remarks": remarks,
      "paymentDate": paymentDate,
      "createdAt": createdAt,
    };
  }

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PaymentModel(
      id: doc.id,
      factoryId: data["factoryId"] ?? "",
      customerId: data["customerId"] ?? "",
      customerName: data["customerName"] ?? "",
      amount: (data["amount"] ?? 0).toDouble(),
      paymentMethod: data["paymentMethod"] ?? "Cash",
      referenceNumber: data["referenceNumber"] ?? "",
      remarks: data["remarks"] ?? "",
      paymentDate: data["paymentDate"] ?? Timestamp.now(),
      createdAt: data["createdAt"] ?? Timestamp.now(),
    );
  }
  PaymentModel copyWith({
    String? id,
    String? factoryId,
    String? customerId,
    String? customerName,
    double? amount,
    String? paymentMethod,
    String? referenceNumber,
    String? remarks,
    Timestamp? paymentDate,
    Timestamp? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      remarks: remarks ?? this.remarks,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
