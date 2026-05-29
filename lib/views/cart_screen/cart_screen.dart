import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../consts/consts.dart';
import '../../models/app_state.dart';
import '../../models/product_model.dart';
import '../../utils/price_utils.dart';
import '../../widgets/app_widgets.dart';
import '../home_screen/home.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text(
          cart,
          style: TextStyle(
            fontFamily: bold,
            fontSize: 18,
            color: darkFontGrey,
          ),
        ),
        actions: [
          Consumer<AppState>(
            builder: (_, state, __) => state.cartItems.isEmpty
                ? const SizedBox()
                : TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text(
                            "Clear Cart",
                            style: TextStyle(fontFamily: bold),
                          ),
                          content: const Text(
                            "Remove all items from cart?",
                            style: TextStyle(fontFamily: regular),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: fontGrey),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                state.clearCart();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Clear",
                                style: TextStyle(color: redColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: redColor,
                        fontFamily: semibold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.cartItems.isEmpty) {
            return _emptyCartUI();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.cartItems.length,
                  itemBuilder: (_, i) =>
                      _buildCartItem(context, state.cartItems[i], state),
                ),
              ),
              _buildOrderSummary(context, state),
            ],
          );
        },
      ),
    );
  }

  // ───────────────── CART ITEM UI ─────────────────
  Widget _buildCartItem(
      BuildContext context, CartItem item, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ProductImage(
                image: item.product.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: semibold,
                      fontSize: 14,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.product.price,
                    style: const TextStyle(
                      fontFamily: bold,
                      fontSize: 15,
                      color: redColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _qtyBtn(
                        icon: Icons.remove,
                        onTap: () => state.decrementQty(item),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "${item.quantity}",
                          style: const TextStyle(
                            fontFamily: bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _qtyBtn(
                        icon: Icons.add,
                        color: redColor,
                        iconColor: whiteColor,
                        onTap: () => state.incrementQty(item),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => state.removeFromCart(item),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: redColor,
                          ),
                        ),
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

  // ───────────────── ORDER SUMMARY + CHECKOUT ─────────────────
  Widget _buildOrderSummary(BuildContext context, AppState state) {
    const double delivery = PriceUtils.deliveryFee;
    final double subtotal = state.cartTotal;
    final double total = subtotal + delivery;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _summaryRow("Subtotal", PriceUtils.format(subtotal)),
          const SizedBox(height: 8),
          _summaryRow("Delivery", PriceUtils.format(delivery)),
          const Divider(height: 20),
          _summaryRow("Total", PriceUtils.format(total), isBold: true),
          const SizedBox(height: 14),

          // ✅ PROCEED TO CHECKOUT
          CustomButton(
            text: "Proceed to Checkout",
            icon: Icons.arrow_forward,
            onTap: () {
              Navigator.pushNamed(context, '/address');
            },
          ),

          const SizedBox(height: 10),

          // ✅ PAYMENT METHOD
          CustomButton(
            text: "Select Payment Method",
            icon: Icons.payment,
            color: darkFontGrey,
            onTap: () {
              Navigator.pushNamed(context, '/payment');
            },
          ),

          const SizedBox(height: 14),

          // ✅ PLACE ORDER
          _isPlacingOrder
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: CircularProgressIndicator(color: redColor),
                )
              : CustomButton(
                  text: "Place Order",
                  icon: Icons.check_circle,
                  onTap: () => _placeOrder(context, state),
                ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, AppState state) async {
    setState(() => _isPlacingOrder = true);

    try {
      final orderId = await state.placeOrder();
      if (!context.mounted) return;
      setState(() => _isPlacingOrder = false);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Order Placed!',
            style: TextStyle(fontFamily: bold, color: darkFontGrey),
          ),
          content: Text(
            'Your order was placed successfully.\nOrder ID: #${orderId.toUpperCase()}',
            style: const TextStyle(fontFamily: regular),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'OK',
                style: TextStyle(color: redColor, fontFamily: semibold),
              ),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: redColor),
      );
    }
  }

  // ───────────────── HELPERS ─────────────────
  Widget _summaryRow(String label, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: isBold ? bold : regular,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: bold,
            fontSize: isBold ? 18 : 14,
            color: isBold ? redColor : darkFontGrey,
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    Color color = lightGrey,
    Color iconColor = darkFontGrey,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  Widget _emptyCartUI() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: redColor),
          SizedBox(height: 16),
          Text(
            "Your cart is empty",
            style: TextStyle(fontFamily: bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
