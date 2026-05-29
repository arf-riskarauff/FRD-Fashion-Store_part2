import 'package:flutter/material.dart';
import 'product_model.dart';

class AppState extends ChangeNotifier {
  // ── User Profile ──
  String _userName = 'Riska Fikri';
  String _userEmail = 'riska.fikri@email.com';
  String _userPhone = '+91 98765 43210';
  String _userGender = 'Female';
  String _userDob = '01 / 01 / 1995';

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userGender => _userGender;
  String get userDob => _userDob;

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String dob,
  }) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _userGender = gender;
    _userDob = dob;
    notifyListeners();
  }

  // ── Cart ──
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal => _cartItems.fold(
        0.0,
        (sum, item) =>
            sum +
            (double.tryParse(
                    item.product.price.replaceAll('\$', '').replaceAll(',', '')) ??
                0) *
                item.quantity,
      );

  void addToCart(Product product) {
    final existing = _cartItems.where((i) => i.product.name == product.name);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void incrementQty(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decrementQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cartItems.remove(item);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ── Wishlist ──
  final List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  bool isWishlisted(Product product) =>
      _wishlist.any((p) => p.name == product.name);

  void toggleWishlist(Product product) {
    if (isWishlisted(product)) {
      _wishlist.removeWhere((p) => p.name == product.name);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  // ── Search ──
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Selected category filter ──
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;
  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }
}
