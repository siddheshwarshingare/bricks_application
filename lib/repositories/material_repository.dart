import 'package:bricks_application/models/material_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add Material
  Future<void> addMaterial(MaterialModel material) async {
    final docRef = _firestore
        .collection('factories')
        .doc(material.factoryId)
        .collection('materials')
        .doc();

    final newMaterial = material.copyWith(id: docRef.id);

    await docRef.set(newMaterial.toMap());
  }

  /// Update Material
  Future<void> updateMaterial(MaterialModel material) async {
    await _firestore
        .collection('factories')
        .doc(material.factoryId)
        .collection('materials')
        .doc(material.id)
        .update(material.toMap());
  }

  /// Delete Material
  Future<void> deleteMaterial(String factoryId, String materialId) async {
    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('materials')
        .doc(materialId)
        .delete();
  }

  /// Get All Materials
  Stream<List<MaterialModel>> getMaterials(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('materials')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MaterialModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get Single Material
  Future<MaterialModel?> getMaterial(
    String factoryId,
    String materialId,
  ) async {
    final doc = await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('materials')
        .doc(materialId)
        .get();

    if (!doc.exists) return null;

    return MaterialModel.fromFirestore(doc);
  }

  /// Search Materials
  Stream<List<MaterialModel>> searchMaterials(
    String factoryId,
    String keyword,
  ) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('materials')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MaterialModel.fromFirestore(doc))
              .where(
                (material) => material.materialName.toLowerCase().contains(
                  keyword.toLowerCase(),
                ),
              )
              .toList();
        });
  }

  /// Total Material Cost
  Stream<double> totalMaterialCost(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('materials')
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();
            total += (data['price'] ?? 0).toDouble();
          }

          return total;
        });
  }

  /// Total Quantity by Material Name
  Stream<double> totalQuantity(String factoryId, String materialName) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('materials')
        .where('materialName', isEqualTo: materialName)
        .snapshots()
        .map((snapshot) {
          double total = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();
            total += (data['quantity'] ?? 0).toDouble();
          }

          return total;
        });
  }
}
