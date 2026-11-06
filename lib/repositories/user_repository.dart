import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ============================================================
  // CREATE USER PROFILE
  // ============================================================

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set(user.toMap());
  }

  // ============================================================
  // GET LOGGED-IN USER
  // ============================================================

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromFirestore(doc);
  }

  // ============================================================
  // GET ALL USERS
  // ============================================================

  Stream<List<UserModel>> getUsers() {
    return _users.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.id).update(user.toMap());
  }

  // ============================================================
  // DELETE USER ACCOUNT
  // ============================================================

  Future<void> deleteUser(String uid) async {
    final callable = _functions.httpsCallable('deleteOwnerAccount');

    await callable.call({'uid': uid});
  }
}
