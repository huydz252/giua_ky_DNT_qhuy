/// Product data model. The Firestore document ID is not stored as a field.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  final String id;
  final String name;
  final double price;
  final int quantity;
  final String image;

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    final rawPrice = map['price'];
    final rawQuantity = map['soluong'];
    if (rawPrice is! num || rawQuantity is! int) {
      throw const FormatException('Product price/soluong has an invalid type.');
    }
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      price: rawPrice.toDouble(),
      quantity: rawQuantity,
      image: map['image'] as String? ?? '',
    );
  }

  /// Persist exactly the four fields specified by the exam.
  Map<String, Object?> toMap() => {
    'name': name,
    'price': price,
    'soluong': quantity,
    'image': image,
  };
}
