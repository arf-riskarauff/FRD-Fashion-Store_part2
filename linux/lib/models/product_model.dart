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
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}
