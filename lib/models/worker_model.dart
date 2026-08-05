import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerModel {
  final String id;
  final String factoryId;
  final String name;
  final String mobile;
  final String address;
  final double salary;
  final String workType;
  final bool isActive;
  final Timestamp joiningDate;
  final Timestamp createdAt;
  double ratePer1000;
  double advanceBalance;

  WorkerModel({
    required this.id,
    required this.factoryId,
    required this.name,
    required this.mobile,
    required this.address,
    required this.salary,
    required this.workType,
    required this.isActive,
    required this.joiningDate,
    required this.createdAt,
    this.ratePer1000 = 0.0,
    this.advanceBalance = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'factoryId': factoryId,
      'name': name,
      'mobile': mobile,
      'address': address,
      'salary': salary,
      'workType': workType,
      'isActive': isActive,
      'joiningDate': joiningDate,
      'createdAt': createdAt,
      'ratePer1000': ratePer1000,
      'advanceBalance': advanceBalance,
    };
  }

  factory WorkerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WorkerModel(
      id: doc.id,
      factoryId: data['factoryId'] ?? '',
      name: data['name'] ?? '',
      mobile: data['mobile'] ?? '',
      address: data['address'] ?? '',
      salary: (data['salary'] ?? 0).toDouble(),
      workType: data['workType'] ?? '',
      isActive: data['isActive'] ?? true,
      joiningDate: data['joiningDate'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      ratePer1000: (data['ratePer1000'] ?? 0).toDouble(),
      advanceBalance: (data['advanceBalance'] ?? 0).toDouble(),
    );
  }
  // ADD HERE 👇
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkerModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
