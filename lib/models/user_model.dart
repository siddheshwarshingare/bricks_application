import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final List<String> factoryIds;
  final bool mustChangePassword;
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.factoryIds,
    this.mustChangePassword = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'factoryIds': factoryIds,
      'mustChangePassword': mustChangePassword,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'owner',
      factoryIds: List<String>.from(data['factoryIds'] ?? []),
      mustChangePassword: data['mustChangePassword'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
