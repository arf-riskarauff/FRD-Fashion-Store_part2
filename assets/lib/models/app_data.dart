import 'product_model.dart';

class AppData {
  static List<Product> featuredProducts = [
    Product(
      name: "Stylish Women Dress",
      image: "assets/images/p1.jpeg",
      price: "LKR 7,500",
      oldPrice: "LKR 10,500",
      category: "Women Dress",
      rating: 4.5,
      reviews: 120,
      description:
          "Beautiful stylish women dress perfect for all occasions. Made with premium quality fabric.",
    ),
    Product(
      name: "Casual T-Shirt",
      image: "assets/images/p2.jpeg",
      price: "LKR 4,500",
      oldPrice: "LKR 6,600",
      category: "T-Shirts",
      rating: 4.2,
      reviews: 85,
      description:
          "Comfortable casual t-shirt available in multiple colors. Perfect for everyday wear.",
    ),
    Product(
      name: "Girls Party Dress",
      image: "assets/images/p3.jpeg",
      price: "LKR 9,000",
      oldPrice: "LKR 13,500",
      category: "Girls Dress",
      rating: 4.8,
      reviews: 200,
      description:
          "Elegant girls party dress with beautiful design. Your little one will love it!",
    ),
    Product(
      name: "Smart Watch",
      image: "assets/images/p4.jpeg",
      price: "LKR 29,700",
      oldPrice: "LKR 38,700",
      category: "Girls Watches",
      rating: 4.6,
      reviews: 340,
      description:
          "Feature-packed smart watch with health monitoring and stylish design.",
    ),
    Product(
      name: "Trendy Hand Bag",
      image: "assets/images/p5.jpeg",
      price: "LKR 5,400",
      oldPrice: "LKR 8,400",
      category: "Boys & Girls Accessories",
      rating: 4.3,
      reviews: 95,
      description: "Trendy Hand Bag with a stylish design and premium finish. Spacious, lightweight, and perfect for daily use or special occasions. A perfect accessory to complete your fashionable look.",
    ),
    Product(
      name: "Latest Kids Fancy Dress",
      image: "assets/images/p6.jpeg",
      price: "LKR 89,700",
      oldPrice: "LKR 119,700",
      category: "Kids Dresses",
      rating: 4.7,
      reviews: 520,
      description:
          "Comfortable to wear and perfect for parties, functions, and special occasions.",
    ),
  ];

  static List<Product> flashSaleProducts = [
    Product(
      name: "Summer Dress",
      image: "assets/images/fc1.jpeg",
      price: "LKR 3,600",
      oldPrice: "LKR 9,000",
      category: "Women Dress",
      rating: 4.1,
      reviews: 60,
      description: "Light and breezy summer dress perfect for hot days.",
    ),
    Product(
      name: "Designer Glasses",
      image: "assets/images/fc2.jpeg",
      price: "LKR 7,500",
      oldPrice: "LKR 16,500",
      category: "Boys Glasses",
      rating: 4.4,
      reviews: 77,
      description: "Premium designer glasses with UV protection.",
    ),
    Product(
      name: "Kids Frock",
      image: "assets/images/fc3.jpeg",
      price: "LKR 5,400",
      oldPrice: "LKR 10,500",
      category: "Girls Dress",
      rating: 4.6,
      reviews: 110,
      description: "Adorable kids frock with colorful patterns.",
    ),
    Product(
      name: "Sports T-Shirt",
      image: "assets/images/fc4.jpeg",
      price: "LKR 3,000",
      oldPrice: "LKR 6,000",
      category: "T-Shirts",
      rating: 4.0,
      reviews: 45,
      description: "Breathable sports t-shirt for active lifestyle.",
    ),
  ];

  static List<Map<String, String>> categories = [
    {"name": "Women Dress", "icon": "assets/icons/categories.png"},
    {"name": "Girls Dress", "icon": "assets/icons/categories.png"},
    {"name": "Girls Watches", "icon": "assets/icons/categories.png"},
    {"name": "Boys Glasses", "icon": "assets/icons/categories.png"},
    {"name": "Kids Dresses", "icon": "assets/icons/categories.png"},
    {"name": "T-Shirts", "icon": "assets/icons/categories.png"},
  ];

  static List<Map<String, String>> sliders = [
    {"image": "assets/images/slider_1.png"},
    {"image": "assets/images/slider_2.png"},
    {"image": "assets/images/slider_3.png"},
  ];
}
