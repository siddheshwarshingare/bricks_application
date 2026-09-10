import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/factory_model.dart';

class FactoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFactory(FactoryModel factory) async {
    await _firestore.collection('factories').add(factory.toMap());
  }
 
  Stream<List<FactoryModel>> getFactories() {
    return FirebaseFirestore.instance
        .collection('factories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FactoryModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> updateFactory(FactoryModel factory) async {
    await _firestore
        .collection('factories')
        .doc(factory.id)
        .update(factory.toMap());
  }

  Future<void> deleteFactory(String id) async {
    await _firestore.collection('factories').doc(id).delete();
  }
}
