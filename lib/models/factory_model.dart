import 'package:cloud_firestore/cloud_firestore.dart';

class FactoryModel {
  final String id;
  final String name;
  final String location;
  final String owner;
  final Timestamp createdAt;

  FactoryModel({
    required this.id,
    required this.name,
    required this.location,
    required this.owner,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'owner': owner,
      'createdAt': createdAt,
    };
  }

  factory FactoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FactoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      owner: data['owner'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
