import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionModel {
  final String id;
  final String factoryId;
  final String workerId;
  final String workerName;
  final int bricksProduced;
  final String remarks;
  final Timestamp productionDate;
  final Timestamp createdAt;
  double salaryPaid;
  double cashReturned;
  double ratePer1000;
  double salaryEarned;
  ProductionModel({
    required this.id,
    required this.factoryId,
    required this.workerId,
    required this.workerName,
    required this.bricksProduced,
    required this.remarks,
    required this.productionDate,
    required this.createdAt,
    this.salaryPaid = 0.0,
    this.cashReturned = 0.0,
    this.ratePer1000 = 0.0,
    this.salaryEarned = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      "factoryId": factoryId,
      "workerId": workerId,
      "workerName": workerName,
      "bricksProduced": bricksProduced,
      "remarks": remarks,
      "productionDate": productionDate,
      "createdAt": createdAt,
      "salaryPaid": salaryPaid,
      "cashReturned": cashReturned,
      "ratePer1000": ratePer1000,
      "salaryEarned": salaryEarned,
    };
  }

  factory ProductionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductionModel(
      id: doc.id,
      factoryId: data["factoryId"] ?? "",
      workerId: data["workerId"] ?? "",
      workerName: data["workerName"] ?? "",
      bricksProduced: data["bricksProduced"] ?? 0,
      remarks: data["remarks"] ?? "",
      productionDate: data["productionDate"] ?? Timestamp.now(),
      createdAt: data["createdAt"] ?? Timestamp.now(),
      salaryPaid: (data["salaryPaid"] ?? 0).toDouble(),
      cashReturned: (data["cashReturned"] ?? 0).toDouble(),
      ratePer1000: (data["ratePer1000"] ?? 0).toDouble(),
      salaryEarned: (data["salaryEarned"] ?? 0).toDouble(),
    );
  }
  //double get salaryEarned => (bricksProduced / 1000) * ratePer1000;
}
