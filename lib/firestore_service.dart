import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'models/app_data.dart';
import 'models/product_model.dart';
import 'utils/price_utils.dart';

class FirestoreService {
  FirestoreService._();

  static bool get _isReady => Firebase.apps.isNotEmpty;
  static bool get hasSignedInUser => uid != null;
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String? get uid =>
      _isReady ? FirebaseAuth.instance.currentUser?.uid : null;

  static DocumentReference<Map<String, dynamic>>? get _userDoc {
    final currentUid = uid;
    if (currentUid == null) return null;
    return _db.collection('users').doc(currentUid);
  }

  static CollectionReference<Map<String, dynamic>>? get _cartCollection {
    final userDoc = _userDoc;
    return userDoc?.collection('cart');
  }

  static CollectionReference<Map<String, dynamic>>? get _wishlistCollection {
    final userDoc = _userDoc;
    return userDoc?.collection('wishlist');
  }

  static CollectionReference<Map<String, dynamic>>? get _ordersCollection {
    final userDoc = _userDoc;
    return userDoc?.collection('orders');
  }

  static CollectionReference<Map<String, dynamic>>? get _addressesCollection {
    final userDoc = _userDoc;
    return userDoc?.collection('addresses');
  }

  static CollectionReference<Map<String, dynamic>>? get _couponsCollection {
    final userDoc = _userDoc;
    return userDoc?.collection('coupons');
  }

  static Stream<List<Product>> productsStream() {
    if (!_isReady) {
      return const Stream.empty();
    }

    return _db.collection('products').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList(),
        );
  }

  static Future<void> ensureDefaultProducts() async {
    if (!_isReady || uid == null) return;

    final products = _db.collection('products');
    final batch = _db.batch();
    for (var i = 0; i < AppData.allProducts.length; i++) {
      final product = AppData.allProducts[i];
      batch.set(
          products.doc(_docId(product.name)),
          {
            ..._productToMap(product),
            'sortOrder': i,
            'source': 'local_assets_seed',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    }

    await batch.commit();
  }

  static Future<void> createOrUpdateUser({
    required String name,
    required String email,
    String phone = '',
    String gender = '',
    String dob = '',
    String? photoUrl,
  }) async {
    final userDoc = _requireUserDoc();

    final data = {
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'gender': gender.trim(),
      'dob': dob.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (photoUrl != null) {
      data['photoUrl'] = photoUrl.trim();
    }

    await userDoc.set(data, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final userDoc = _userDoc;
    if (userDoc == null) return null;

    final snapshot = await userDoc.get();
    return snapshot.data();
  }

  static Future<String> uploadProfileImage({
    required Uint8List bytes,
    required String extension,
  }) async {
    final currentUid = uid;
    if (currentUid == null) {
      throw Exception('Please sign in before updating your profile image.');
    }
    if (bytes.isEmpty) {
      throw Exception('Selected image is empty. Choose another image.');
    }

    final normalizedExt = _normalizeImageExtension(extension);
    final contentType = normalizedExt == 'jpg' || normalizedExt == 'jpeg'
        ? 'image/jpeg'
        : 'image/$normalizedExt';
    final profileImagePath = 'users/$currentUid/profile/avatar.$normalizedExt';
    final storage = FirebaseStorage.instanceFor(app: Firebase.app());
    final ref = storage.ref(profileImagePath);

    try {
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'ownerUid': currentUid,
            'type': 'profile_image',
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw Exception(
        'Profile image Firebase Storage upload failed: ${e.message ?? e.code}',
      );
    }

    final url = await ref.getDownloadURL();

    await _requireUserDoc().set({
      'photoUrl': url,
      'photoPath': profileImagePath,
      'photoStorageBucket': storage.bucket,
      'photoUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    try {
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);
    } catch (_) {
      // Storage and Firestore already contain the saved profile image.
    }

    return url;
  }

  static Future<void> saveCartItem(Product product, int quantity) async {
    final cart = _cartCollection;
    if (cart == null) return;

    await cart.doc(_docId(product.name)).set({
      ..._productToMap(product),
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> removeCartItem(Product product) async {
    final cart = _cartCollection;
    if (cart == null) return;

    await cart.doc(_docId(product.name)).delete();
  }

  static Future<void> clearCart() async {
    final cart = _cartCollection;
    if (cart == null) return;

    final snapshot = await cart.get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Future<void> saveWishlistProduct(Product product) async {
    final wishlist = _wishlistCollection;
    if (wishlist == null) return;

    await wishlist.doc(_docId(product.name)).set({
      ..._productToMap(product),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> removeWishlistProduct(Product product) async {
    final wishlist = _wishlistCollection;
    if (wishlist == null) return;

    await wishlist.doc(_docId(product.name)).delete();
  }

  static Future<String> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double delivery,
    required double total,
  }) async {
    if (items.isEmpty) {
      throw Exception('Cart is empty. Add items before placing an order.');
    }

    final userDoc = _requireUserDoc();
    final now = Timestamp.now();
    final orderData = {
      'items': items
          .map((item) => {
                ..._productToMap(item.product),
                'quantity': item.quantity,
              })
          .toList(),
      'subtotal': subtotal,
      'delivery': delivery,
      'total': total,
      'status': 'Processing',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'trackingStep': 0,
      'trackingLabel': 'Order Placed',
      'estimatedDelivery': 'Arriving in 3-5 business days',
      'deliveryPartner': {
        'name': 'FRD Express',
        'rating': 4.8,
        'phone': '+94 112 345 678',
      },
      'trackingHistory': [
        {
          'title': 'Order Placed',
          'subtitle': 'Your order has been confirmed',
          'time': now,
        },
        {
          'title': 'Order Packed',
          'subtitle': 'Seller will pack your order soon',
          'time': null,
        },
        {
          'title': 'Shipped',
          'subtitle': 'Waiting for courier pickup',
          'time': null,
        },
        {
          'title': 'Out for Delivery',
          'subtitle': 'Your delivery partner is on the way',
          'time': null,
        },
        {
          'title': 'Delivered',
          'subtitle': 'Package handed over',
          'time': null,
        },
      ],
      'userId': uid,
    };

    final userOrder = userDoc.collection('orders').doc();
    final batch = _db.batch()
      ..set(userOrder, orderData)
      ..set(_db.collection('orders').doc(userOrder.id), {
        ...orderData,
        'userOrderPath': userOrder.path,
      });
    await batch.commit();
    await clearCart();
    return userOrder.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> ordersStream() {
    final orders = _ordersCollection;
    if (orders == null) {
      return const Stream.empty();
    }
    return orders.orderBy('createdAt', descending: true).snapshots();
  }

  static Stream<int> orderCountStream() {
    return ordersStream().map((snapshot) => snapshot.docs.length);
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> orderStream(
    String orderId,
  ) {
    final userDoc = _userDoc;
    if (userDoc == null) {
      return const Stream.empty();
    }
    return userDoc.collection('orders').doc(orderId).snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>?> latestOrderStream() {
    final orders = _ordersCollection;
    if (orders == null) {
      return const Stream.empty();
    }

    return orders
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty ? null : snapshot.docs.first);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> addressesStream() {
    final addresses = _addressesCollection;
    if (addresses == null) {
      return const Stream.empty();
    }
    return addresses.orderBy('createdAt', descending: false).snapshots();
  }

  static Future<void> saveAddress(Map<String, dynamic> address,
      {String? id}) async {
    final addresses = _requireUserDoc().collection('addresses');

    final data = Map<String, dynamic>.from(address)
      ..remove('icon')
      ..['updatedAt'] = FieldValue.serverTimestamp()
      ..putIfAbsent('createdAt', () => FieldValue.serverTimestamp());

    if (id == null) {
      await addresses.add(data);
    } else {
      await addresses.doc(id).set(data, SetOptions(merge: true));
    }
  }

  static Future<void> deleteAddress(String id) async {
    final addresses = _requireUserDoc().collection('addresses');

    await addresses.doc(id).delete();
  }

  static Future<void> savePaymentMethod(Map<String, dynamic> payment) async {
    final payments = _requireUserDoc().collection('payment_methods');

    await payments.add({
      ...payment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> paymentMethodsStream() {
    final userDoc = _userDoc;
    if (userDoc == null) {
      return const Stream.empty();
    }
    return userDoc
        .collection('payment_methods')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> deletePaymentMethod(String id) async {
    await _requireUserDoc().collection('payment_methods').doc(id).delete();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> couponsStream() {
    final coupons = _couponsCollection;
    if (coupons == null) {
      return const Stream.empty();
    }
    return coupons.orderBy('sortOrder').snapshots();
  }

  static Future<void> ensureDefaultCoupons() async {
    final coupons = _requireUserDoc().collection('coupons');
    final existing = await coupons.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    final defaults = [
      {
        'code': 'WELCOME20',
        'discount': '20% OFF',
        'desc': 'On your first order',
        'expiry': 'Expires: 30 Jun 2026',
        'valid': true,
        'sortOrder': 0,
      },
      {
        'code': 'FLASH50',
        'discount': 'LKR 15,000 OFF',
        'desc': 'On orders above LKR 60,000',
        'expiry': 'Expires: 15 May 2026',
        'valid': true,
        'sortOrder': 1,
      },
      {
        'code': 'SUMMER10',
        'discount': '10% OFF',
        'desc': 'On summer collection',
        'expiry': 'Expired: 01 Jan 2026',
        'valid': false,
        'sortOrder': 2,
      },
    ];

    for (final coupon in defaults) {
      batch.set(coupons.doc(coupon['code'] as String), {
        ...coupon,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static DocumentReference<Map<String, dynamic>> _requireUserDoc() {
    if (!_isReady) {
      throw Exception('Firebase is not ready. Restart the app and try again.');
    }

    final currentUid = uid;
    if (currentUid == null) {
      throw Exception('Please sign in before using this feature.');
    }

    return _db.collection('users').doc(currentUid);
  }

  static Map<String, dynamic> _productToMap(Product product) {
    return {
      'name': product.name,
      'image': product.image,
      'price': PriceUtils.parse(product.price),
      'oldPrice':
          product.oldPrice.isEmpty ? null : PriceUtils.parse(product.oldPrice),
      'displayPrice': product.price,
      'displayOldPrice': product.oldPrice,
      'category': product.category,
      'rating': product.rating,
      'reviews': product.reviews,
      'description': product.description,
    };
  }

  static String _docId(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  static String _normalizeImageExtension(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '').trim();
    if (ext == 'jpg') return 'jpeg';
    if (ext == 'jpeg' || ext == 'png' || ext == 'webp' || ext == 'gif') {
      return ext;
    }
    return 'jpeg';
  }
}
