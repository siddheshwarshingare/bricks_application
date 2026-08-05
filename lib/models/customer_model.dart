import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String factoryId;
  final String name;
  final String mobile;
  final String address;
  final String village;
  final String gstNumber;
  final double openingBalance;
  final double pendingBalance;
  final double totalPurchase;
  final Timestamp createdAt;
  final double totalPaid;
  final double totalQuantity;
  CustomerModel({
    required this.id,
    required this.factoryId,
    required this.name,
    required this.mobile,
    required this.address,
    required this.village,
    required this.gstNumber,
    required this.openingBalance,
    required this.pendingBalance,
    required this.totalPurchase,
    required this.createdAt,
    required this.totalPaid,
    required this.totalQuantity,
  });

  /// Convert Object to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'factoryId': factoryId,
      'name': name,
      'mobile': mobile,
      'address': address,
      'village': village,
      'gstNumber': gstNumber,
      'openingBalance': openingBalance,
      'pendingBalance': pendingBalance,
      'totalPurchase': totalPurchase,
      'createdAt': createdAt,
      'totalPaid': totalPaid,
      'totalQuantity': totalQuantity,
    };
  }

  /// Firestore Document -> CustomerModel
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CustomerModel(
      id: doc.id,
      factoryId: data['factoryId'] ?? '',
      name: data['name'] ?? '',
      mobile: data['mobile'] ?? '',
      address: data['address'] ?? '',
      village: data['village'] ?? '',
      gstNumber: data['gstNumber'] ?? '',
      openingBalance: (data['openingBalance'] ?? 0).toDouble(),
      pendingBalance: (data['pendingBalance'] ?? 0).toDouble(),
      totalPurchase: (data['totalPurchase'] ?? 0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      totalPaid: (data['totalPaid'] ?? 0).toDouble(),
      totalQuantity: (data['totalQuantity'] ?? 0).toDouble(),
    );
  }

  /// Copy Object
  CustomerModel copyWith({
    String? id,
    String? factoryId,
    String? name,
    String? mobile,
    String? address,
    String? village,
    String? gstNumber,
    double? openingBalance,
    double? pendingBalance,
    double? totalPurchase,
    Timestamp? createdAt,
    double? totalPaid,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      factoryId: factoryId ?? this.factoryId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      village: village ?? this.village,
      gstNumber: gstNumber ?? this.gstNumber,
      openingBalance: openingBalance ?? this.openingBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalPurchase: totalPurchase ?? this.totalPurchase,
      createdAt: createdAt ?? this.createdAt,
      totalPaid: totalPaid ?? this.totalPaid,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CustomerModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
