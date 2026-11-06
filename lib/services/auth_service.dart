import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LOGIN USING MOBILE NUMBER AND PASSWORD
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final cleanPhone = phone.trim();

      // 1. Find user in Firestore using mobile number
      final snapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: cleanPhone)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Invalid mobile number or password.');
      }

      final userData = snapshot.docs.first.data();

      // 2. Get registered email
      final email = userData['email']?.toString();

      if (email == null || email.isEmpty) {
        throw Exception('User email not found.');
      }

      // 3. Authenticate using Firebase Authentication
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Unable to authenticate user.');
      }

      // 4. Fetch user profile using Firebase Auth UID
      final userDocument = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDocument.exists) {
        await _auth.signOut();
        throw Exception('User profile not found.');
      }

      final profileData = userDocument.data()!;

      // 5. Save session locally
      final prefs = await SharedPreferences.getInstance();

      final factoryIds = List<String>.from(profileData['factoryIds'] ?? []);

      final mustChangePassword = profileData['mustChangePassword'] ?? false;

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uid', firebaseUser.uid);
      await prefs.setString('name', profileData['name'] ?? '');
      await prefs.setString('email', profileData['email'] ?? email);
      await prefs.setString('phone', profileData['phone'] ?? cleanPhone);
      await prefs.setString('role', profileData['role'] ?? '');
      await prefs.setStringList('factoryIds', factoryIds);
      await prefs.setBool('mustChangePassword', mustChangePassword);

      // Save createdAt if available
      final createdAt = profileData['createdAt'];

      if (createdAt is Timestamp) {
        await prefs.setInt('createdAt', createdAt.millisecondsSinceEpoch);
      }

      return {
        'success': true,
        'uid': firebaseUser.uid,
        'name': profileData['name'] ?? '',
        'email': profileData['email'] ?? email,
        'phone': profileData['phone'] ?? cleanPhone,
        'role': profileData['role'] ?? '',
        'factoryIds': factoryIds,
        'mustChangePassword': mustChangePassword,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.code == 'invalid-credential' ||
                e.code == 'wrong-password' ||
                e.code == 'user-not-found'
            ? 'Invalid mobile number or password.'
            : e.message ?? 'Login failed.',
      );
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Unable to access user data.');
    } catch (e) {
      rethrow;
    }
  }

  // CHECK LOCAL LOGIN SESSION
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        await prefs.setBool('isLoggedIn', false);
        return false;
      }

      final savedUid = prefs.getString('uid');
      final isSessionActive = prefs.getBool('isLoggedIn') == true;

      final isValid = isSessionActive && savedUid == firebaseUser.uid;

      debugPrint('Firebase UID: ${firebaseUser.uid}');
      debugPrint('Saved UID: $savedUid');
      debugPrint('Session active: $isSessionActive');
      debugPrint('Valid session: $isValid');

      if (!isValid) {
        await prefs.setBool('isLoggedIn', false);
      }

      return isValid;
    } catch (e) {
      debugPrint('Session check error: $e');
      return false;
    }
  }

  // GET SAVED USER DATA
  static Future<Map<String, dynamic>> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'uid': prefs.getString('uid') ?? '',
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'phone': prefs.getString('phone') ?? '',
      'role': prefs.getString('role') ?? '',
      'factoryIds': prefs.getStringList('factoryIds') ?? [],
      'mustChangePassword': prefs.getBool('mustChangePassword') ?? false,
      'createdAt': prefs.getInt('createdAt'),
    };
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
    await _auth.signOut();
  }
}
