import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../repositories/firebase_auth_repository.dart';
import '../repositories/firestore_product_repository.dart';

class AppProvider {
  AppProvider._();

  static final AuthRepository authRepository = FirebaseAuthRepository(
    FirebaseAuth.instance,
  );
  static final ProductRepository productRepository = FirestoreProductRepository(
    FirebaseFirestore.instance,
  );
}
