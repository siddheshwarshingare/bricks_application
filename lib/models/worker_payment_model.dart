import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerPaymentModel {
  final String id;
  final String factoryId;
  final String workerId;
  final String workerName;

  final double amount;

  final String paymentMethod;
  final String remarks;

  final Timestamp paymentDate;
  final Timestamp createdAt;

  WorkerPaymentModel({
    required this.id,
    required this.factoryId,
    required this.workerId,
    required this.workerName,
    required this.amount,
    required this.paymentMethod,
    required this.remarks,
    required this.paymentDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "factoryId": factoryId,
      "workerId": workerId,
      "workerName": workerName,
      "amount": amount,
      "paymentMethod": paymentMethod,
      "remarks": remarks,
      "paymentDate": paymentDate,
      "createdAt": createdAt,
    };
  }

  factory WorkerPaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WorkerPaymentModel(
      id: doc.id,
      factoryId: data["factoryId"] ?? "",
      workerId: data["workerId"] ?? "",
      workerName: data["workerName"] ?? "",
      amount: (data["amount"] ?? 0).toDouble(),
      paymentMethod: data["paymentMethod"] ?? "",
      remarks: data["remarks"] ?? "",
      paymentDate: data["paymentDate"] ?? Timestamp.now(),
      createdAt: data["createdAt"] ?? Timestamp.now(),
    );
  }

  WorkerPaymentModel copyWith({
    String? id,
    String? factoryId,
    String? workerId,
    String? workerName,
    double? amount,
    String? paymentMethod,
    String? remarks,
    Timestamp? paymentDate,
    Timestamp? createdAt,
  }) {
    return WorkerPaymentModel(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      remarks: remarks ?? this.remarks,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
