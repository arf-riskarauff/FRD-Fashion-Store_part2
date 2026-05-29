import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/price_utils.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

// Demo cart items for UI
class DemoCartItem {
  final String image;
  final String title;
  final String size;
  final String color;
  double price;
  int qty;

  DemoCartItem({
    required this.image,
    required this.title,
    required this.size,
    required this.color,
    required this.price,
    this.qty = 1,
  });
}

/// Global cart manager — lives for the app lifetime
class CartManager {
  CartManager._();
  static final CartManager instance = CartManager._();

  final List<DemoCartItem> items = [];

  void add(DemoCartItem newItem) {
    final idx = items.indexWhere(
      (i) => i.title == newItem.title && i.size == newItem.size && i.color == newItem.color,
    );
    if (idx >= 0) {
      items[idx].qty += newItem.qty;
    } else {
      items.add(newItem);
    }
  }

  void remove(int index) => items.removeAt(index);
  void clear() => items.clear();
}

class _CartScreenState extends State<CartScreen> {
  List<DemoCartItem> get _items => CartManager.instance.items;

  double get _subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.price * i.qty);
  double get _shipping => _subtotal > 0 ? PriceUtils.deliveryFee : 0;
  double get _discount => _subtotal > 15000 ? 3000 : 0;
  double get _total => _subtotal + _shipping - _discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'My Cart (${_items.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => CartManager.instance.clear()),
              child: const Text('Clear', style: TextStyle(color: AppColors.accent)),
            ),
        ],
      ),
      body: _items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => _buildCartItem(i),
                  ),
                ),
                _buildSummary(),
              ],
            ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      cartItems: List.from(_items),
                      total: _total,
                      subtotal: _subtotal,
                      shipping: _shipping,
                      discount: _discount,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Proceed to Checkout  •  ${PriceUtils.format(_total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Add items to get started',
              style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Continue Shopping',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _items[index];
    return Dismissible(
      key: Key('${item.title}$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
      ),
      onDismissed: (_) => setState(() => CartManager.instance.remove(index)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${item.size} | Color: ${item.color}',
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        PriceUtils.format(item.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      const Spacer(),
                      // Qty controls
                      _smallQtyBtn(
                        Icons.remove,
                        () => setState(() {
                          if (item.qty > 1) {
                            item.qty--;
                          } else {
                            CartManager.instance.remove(index);
                          }
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('${item.qty}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      _smallQtyBtn(
                        Icons.add,
                        () => setState(() => item.qty++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', PriceUtils.format(_subtotal)),
          const SizedBox(height: 6),
          _summaryRow('Shipping', PriceUtils.format(_shipping)),
          if (_discount > 0) ...[
            const SizedBox(height: 6),
            _summaryRow('Discount', '-${PriceUtils.format(_discount)}',
                valueColor: Colors.green),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _summaryRow('Total', PriceUtils.format(_total),
              isBold: true, valueColor: AppColors.accent),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: isBold ? AppColors.textDark : AppColors.textGrey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            )),
        Text(value,
            style: TextStyle(
              color: valueColor ?? AppColors.textDark,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 18 : 14,
            )),
      ],
    );
  }
}
