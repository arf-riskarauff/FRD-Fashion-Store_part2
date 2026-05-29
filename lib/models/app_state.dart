import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../firestore_service.dart';
import '../utils/price_utils.dart';
import 'product_model.dart';

class AppState extends ChangeNotifier {
  static const String _defaultName = 'Guest User';
  static const String _defaultEmail = '';

  // ─── User Profile ──────────────────────────────────────────────
  String _userName = _defaultName;
  String _userEmail = _defaultEmail;
  String _userPhone = '';
  String _userGender = '';
  String _userDob = '';
  String _userAvatarInitials = 'GU';
  String _userPhotoUrl = '';
  Uint8List? _userPhotoBytes;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userGender => _userGender;
  String get userDob => _userDob;
  String get userAvatarInitials => _userAvatarInitials;
  String get userPhotoUrl => _userPhotoUrl;
  Uint8List? get userPhotoBytes => _userPhotoBytes;

  Future<void> loadUserProfile() async {
    final data = await FirestoreService.fetchUserProfile();
    if (data == null) return;

    await updateProfile(
      name: (data['name'] ?? _userName).toString(),
      email: (data['email'] ?? _userEmail).toString(),
      phone: (data['phone'] ?? _userPhone).toString(),
      gender: (data['gender'] ?? _userGender).toString(),
      dob: (data['dob'] ?? _userDob).toString(),
      photoUrl: (data['photoUrl'] ?? _userPhotoUrl).toString(),
      saveRemote: false,
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String gender = '',
    String dob = '',
    String? photoUrl,
    bool saveRemote = true,
  }) async {
    final nextName = name.trim().isEmpty ? _defaultName : name.trim();
    final nextEmail = email.trim().isEmpty ? _defaultEmail : email.trim();
    final nextPhone = phone.trim();
    final nextGender = gender.trim();
    final nextDob = dob.trim();
    final nextPhotoUrl = photoUrl?.trim();

    if (saveRemote) {
      await FirestoreService.createOrUpdateUser(
        name: nextName,
        email: nextEmail,
        phone: nextPhone,
        gender: nextGender,
        dob: nextDob,
        photoUrl: nextPhotoUrl ?? _userPhotoUrl,
      );
      try {
        await AuthService.updateDisplayName(nextName);
      } catch (_) {
        // Firestore is the source of truth for the editable profile fields.
      }
    }

    _applyProfileLocal(
      name: nextName,
      email: nextEmail,
      phone: nextPhone,
      gender: nextGender,
      dob: nextDob,
      photoUrl: nextPhotoUrl,
    );
  }

  Future<void> updateProfilePhoto({
    required Uint8List bytes,
    required String extension,
  }) async {
    _userPhotoBytes = bytes;
    notifyListeners();

    try {
      final photoUrl = await FirestoreService.uploadProfileImage(
        bytes: bytes,
        extension: extension,
      );
      _applyProfileLocal(
        name: _userName,
        email: _userEmail,
        phone: _userPhone,
        gender: _userGender,
        dob: _userDob,
        photoUrl: photoUrl,
      );
    } catch (_) {
      _userPhotoBytes = null;
      notifyListeners();
      rethrow;
    }
  }

  // ─── Cart ──────────────────────────────────────────────────────
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal => _cartItems.fold(
        0.0,
        (sum, item) =>
            sum + PriceUtils.parse(item.product.price) * item.quantity,
      );

  void addToCart(Product product) {
    final existing = _cartItems.where((i) => i.product.name == product.name);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
    final item = _cartItems.firstWhere((i) => i.product.name == product.name);
    FirestoreService.saveCartItem(item.product, item.quantity);
  }

  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
    FirestoreService.removeCartItem(item.product);
  }

  void incrementQty(CartItem item) {
    item.quantity++;
    notifyListeners();
    FirestoreService.saveCartItem(item.product, item.quantity);
  }

  void decrementQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cartItems.remove(item);
      FirestoreService.removeCartItem(item.product);
      notifyListeners();
      return;
    }
    notifyListeners();
    FirestoreService.saveCartItem(item.product, item.quantity);
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    FirestoreService.clearCart();
  }

  Future<String> placeOrder() async {
    const double delivery = PriceUtils.deliveryFee;
    final subtotal = cartTotal;
    final items = List<CartItem>.from(_cartItems);

    final orderId = await FirestoreService.placeOrder(
      items: items,
      subtotal: subtotal,
      delivery: delivery,
      total: subtotal + delivery,
    );
    _cartItems.clear();
    notifyListeners();
    return orderId;
  }

  // ─── Wishlist ──────────────────────────────────────────────────
  final List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  bool isWishlisted(Product product) =>
      _wishlist.any((p) => p.name == product.name);

  void toggleWishlist(Product product) {
    if (isWishlisted(product)) {
      _wishlist.removeWhere((p) => p.name == product.name);
      FirestoreService.removeWishlistProduct(product);
    } else {
      _wishlist.add(product);
      FirestoreService.saveWishlistProduct(product);
    }
    notifyListeners();
  }

  // ─── Search ────────────────────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ─── Category filter ──────────────────────────────────────────
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String get userInitials => _userAvatarInitials;
  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  Future<void> setUser({
    required String name,
    required String email,
    String photoUrl = '',
    bool saveRemote = true,
  }) {
    _userPhone = '';
    _userGender = '';
    _userDob = '';
    _userPhotoUrl = photoUrl.trim();
    _userPhotoBytes = null;

    return updateProfile(
      name: name,
      email: email,
      phone: '',
      gender: '',
      dob: '',
      photoUrl: _userPhotoUrl,
      saveRemote: saveRemote,
    );
  }

  void clearUserProfile() {
    _userName = _defaultName;
    _userEmail = _defaultEmail;
    _userPhone = '';
    _userGender = '';
    _userDob = '';
    _userAvatarInitials = 'GU';
    _userPhotoUrl = '';
    _userPhotoBytes = null;
    notifyListeners();
  }

  void _applyProfileLocal({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String dob,
    String? photoUrl,
  }) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _userGender = gender;
    _userDob = dob;
    if (photoUrl != null) {
      _userPhotoUrl = photoUrl;
      _userPhotoBytes = null;
    }

    final parts = _userName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      _userAvatarInitials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      _userAvatarInitials = parts.first[0].toUpperCase();
    } else {
      _userAvatarInitials = 'GU';
    }

    notifyListeners();
  }
}
