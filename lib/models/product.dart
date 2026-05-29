import '../utils/price_utils.dart';

class Product {
  final int id;
  final String image;
  final String title;
  final String description;
  final double ratingRate;
  final int ratingCount;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.ratingRate,
    required this.ratingCount,
    required this.price,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      description: json['description'],
      ratingRate: (json['rating']['rate'] as num).toDouble(),
      ratingCount: json['rating']['count'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
    );
  }

  double get lkrPrice => price * PriceUtils.usdToLkr;
}
