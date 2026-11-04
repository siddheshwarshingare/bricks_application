import 'package:bricks_application/models/material_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Record material usage without deleting purchase history.
  Future<void> addMaterialUsage({
    required String factoryId,
    required String materialName,
    required String unit,
    required double quantity,
    required DateTime usageDate,
    String remarks = '',
  }) async {
    if (quantity <= 0) {
      throw Exception('Usage quantity must be greater than zero.');
    }

    final normalizedName = materialName.trim().toLowerCase();

    await _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('material_usages')
        .add({
          'factoryId': factoryId,
          'materialName': materialName.trim(),
          'materialKey': normalizedName,
          'unit': unit.trim(),
          'quantity': quantity,
          'usageDate': Timestamp.fromDate(usageDate),
          'remarks': remarks.trim(),
          'createdAt': Timestamp.now(),
        });
  }

  /// Stream material usage records.
  Stream<QuerySnapshot<Map<String, dynamic>>> getMaterialUsages(
    String factoryId,
  ) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('material_usages')
        .snapshots();
  }

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
