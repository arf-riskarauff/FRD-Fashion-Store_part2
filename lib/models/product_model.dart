import '../utils/price_utils.dart';

class Product {
  final String name;
  final String image;
  final String price;
  final String oldPrice;
  final String category;
  final double rating;
  final int reviews;
  final String description;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.oldPrice,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.description,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      name: (data['name'] ?? 'Product').toString(),
      image: _cleanImageValue(data['image'] ?? data['imageUrl']),
      price: PriceUtils.display(data['price'] ?? data['displayPrice']),
      oldPrice: data['oldPrice'] == null &&
              data['old_price'] == null &&
              data['displayOldPrice'] == null
          ? ''
          : PriceUtils.display(
              data['oldPrice'] ?? data['old_price'] ?? data['displayOldPrice'],
            ),
      category: (data['category'] ?? 'All').toString(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviews: (data['reviews'] as num?)?.toInt() ?? 0,
      description: (data['description'] ?? '').toString(),
    );
  }

  static String _cleanImageValue(dynamic value) {
    var text = (value ?? '').toString().trim();
    while (text.toLowerCase().startsWith('%20')) {
      text = text.substring(3).trim();
    }

    final decoded = Uri.tryParse(text)?.toString();
    if (decoded != null) return decoded.trim();

    return text;
  }
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}
