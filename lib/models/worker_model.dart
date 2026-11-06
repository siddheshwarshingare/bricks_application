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

  // Existing fields
  double ratePer1000;
  double advanceBalance;

  // New fields
  final String workerType;
  final String paymentType;
  final double dailyWage;

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

    // Defaults preserve existing workers
    this.workerType = 'permanent',
    this.paymentType = 'monthly',
    this.dailyWage = 0.0,
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

      // New fields
      'workerType': workerType,
      'paymentType': paymentType,
      'dailyWage': dailyWage,
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

      // New fields with backward compatibility
      workerType: data['workerType'] ?? 'permanent',
      paymentType: data['paymentType'] ?? 'monthly',
      dailyWage: (data['dailyWage'] ?? 0).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkerModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
