import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';

class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository(this._firestore);

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  @override
  Stream<List<Product>> watchProducts() => _products.snapshots().map(
    (snapshot) => snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList(growable: false),
  );

  @override
  Future<void> addProduct(Product product) async {
    await _products.add(product.toMap());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _products.doc(product.id).update(product.toMap());
  }

  @override
  Future<void> deleteProduct(String id) => _products.doc(id).delete();

  @override
  Future<List<Product>> searchProducts(String query) async {
    final normalized = query.trim().toLowerCase();
    final snapshot = await _products.get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .where((product) => product.name.toLowerCase().contains(normalized))
        .toList(growable: false);
  }
}
