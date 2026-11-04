import 'package:bricks_application/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _products(String factoryId) {
    return _firestore
        .collection('factories')
        .doc(factoryId)
        .collection('products');
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      debugPrint("================================");
      debugPrint("ADDING PRODUCT");
      debugPrint("Factory ID: ${product.factoryId}");
      debugPrint("Product name: ${product.name}");
      debugPrint("Product size: ${product.size}");
      debugPrint("================================");

      final docRef = _products(product.factoryId).doc();

      final newProduct = product.copyWith(id: docRef.id);

      debugPrint("Firestore path: ${docRef.path}");
      debugPrint("Product data: ${newProduct.toMap()}");

      await docRef.set(newProduct.toMap());

      debugPrint("PRODUCT SAVED SUCCESSFULLY");
      debugPrint("Document ID: ${docRef.id}");
    } catch (e, stackTrace) {
      debugPrint("ERROR ADDING PRODUCT: $e");
      debugPrint("$stackTrace");

      rethrow;
    }
  }

  // Future<void> addProduct(ProductModel product) async {
  //   final docRef = _products(product.factoryId).doc();

  //   final newProduct = product.copyWith(id: docRef.id);

  //   await docRef.set(newProduct.toMap());
  // }
  /// Increase stock after production
  Future<void> addProductionStock({
    required String factoryId,
    required String productId,
    required double quantity,
  }) async {
    if (quantity <= 0) {
      throw Exception("Invalid production quantity");
    }

    final productRef = _products(factoryId).doc(productId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception("Product not found");
      }

      final data = snapshot.data()!;

      final double currentStock = (data['stock'] as num?)?.toDouble() ?? 0;

      final double newStock = currentStock + quantity;

      transaction.update(productRef, {'stock': newStock});
    });
  }

  /// Decrease stock after sale
  Future<void> reduceSaleStock({
    required String factoryId,
    required String productId,
    required double quantity,
  }) async {
    if (quantity <= 0) {
      throw Exception("Invalid sale quantity");
    }

    final productRef = _products(factoryId).doc(productId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception("Product not found");
      }

      final data = snapshot.data()!;

      final double currentStock = (data['stock'] as num?)?.toDouble() ?? 0;

      // Don't allow selling more than available stock
      if (quantity > currentStock) {
        throw Exception(
          "Insufficient stock. Available stock: "
          "${currentStock.toStringAsFixed(0)}",
        );
      }

      final double newStock = currentStock - quantity;

      transaction.update(productRef, {'stock': newStock});
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    await _products(product.factoryId).doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String factoryId, String productId) async {
    await _products(factoryId).doc(productId).delete();
  }

  Stream<List<ProductModel>> getProducts(String factoryId) {
    return _products(factoryId)
        .where('active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }
  // Stream<List<ProductModel>> getProducts(String factoryId) {
  //   return _products(factoryId).snapshots().map((snapshot) {
  //     debugPrint("================================");
  //     debugPrint("FACTORY ID = $factoryId");
  //     debugPrint("FIRESTORE PRODUCT DOCS = ${snapshot.docs.length}");

  //     for (final doc in snapshot.docs) {
  //       debugPrint("DOC ID = ${doc.id}");
  //       debugPrint("DOC DATA = ${doc.data()}");
  //     }

  //     final products = snapshot.docs
  //         .map((doc) => ProductModel.fromFirestore(doc))
  //         .toList();

  //     debugPrint("PRODUCT COUNT = ${products.length}");

  //     for (final product in products) {
  //       debugPrint(
  //         "PRODUCT => id=${product.id}, name=${product.name}, active=${product.active}",
  //       );
  //     }

  //     return products;
  //   });
  // }

  Future<ProductModel?> getProduct(String factoryId, String productId) async {
    final doc = await _products(factoryId).doc(productId).get();

    if (!doc.exists) {
      return null;
    }

    return ProductModel.fromFirestore(doc);
  }
}
