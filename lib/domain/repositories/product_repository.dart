import '../models/product.dart';

abstract interface class ProductRepository {
  Stream<List<Product>> watchProducts();
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<List<Product>> searchProducts(String query);
}
