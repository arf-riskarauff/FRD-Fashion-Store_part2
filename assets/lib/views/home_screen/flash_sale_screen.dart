import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../models/app_data.dart';
import '../../models/app_state.dart';
import '../product_screen/product_detail_screen.dart';

class FlashSaleScreen extends StatefulWidget {
  const FlashSaleScreen({super.key});

  @override
  State<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends State<FlashSaleScreen> {
  late Timer _timer;
  int _remainingSeconds = 3 * 3600 + 45 * 60 + 0; // 3h 45m countdown

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hours = _twoDigits(_remainingSeconds ~/ 3600);
    final minutes = _twoDigits((_remainingSeconds % 3600) ~/ 60);
    final seconds = _twoDigits(_remainingSeconds % 60);
    final saleProducts = AppData.flashSaleProducts;

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB100),
        elevation: 0,
        title: const Text(
          flashSale,
          style: TextStyle(
            fontFamily: bold,
            fontSize: 18,
            color: whiteColor,
          ),
        ),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: Column(
        children: [
          // Flash Sale Header with countdown
          Container(
            width: double.infinity,
            color: const Color(0xFFFFB100),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: whiteColor, size: 28),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Flash Sale!",
                        style: TextStyle(
                          fontFamily: bold,
                          fontSize: 15,
                          color: whiteColor,
                        ),
                      ),
                      Text(
                        "Hurry up! Ends soon",
                        style: TextStyle(
                          fontFamily: regular,
                          fontSize: 11,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Countdown timer
                  Row(
                    children: [
                      _timeBox(hours),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          ":",
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 18,
                            fontFamily: bold,
                          ),
                        ),
                      ),
                      _timeBox(minutes),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          ":",
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 18,
                            fontFamily: bold,
                          ),
                        ),
                      ),
                      _timeBox(seconds),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Products Grid
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, _) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: saleProducts.length,
                  itemBuilder: (context, i) {
                    final p = saleProducts[i];

                    // Calculate discount %
                    final orig = double.tryParse(
                            p.oldPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                        1;
                    final curr = double.tryParse(
                            p.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                        0;
                    final discountPct =
                        (((orig - curr) / orig) * 100).round();

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      p.image,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported,
                                              color: fontGrey),
                                    ),
                                  ),
                                ),
                                // Discount badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFB100),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "-$discountPct%",
                                      style: const TextStyle(
                                        color: whiteColor,
                                        fontSize: 9,
                                        fontFamily: bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => state.toggleWishlist(p),
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: whiteColor,
                                      child: Icon(
                                        state.isWishlisted(p)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 16,
                                        color: redColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: semibold,
                                      color: darkFontGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        p.price,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontFamily: bold,
                                          color: Color(0xFFFFB100),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        p.oldPrice,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: fontGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 11, color: golden),
                                      const SizedBox(width: 2),
                                      Text(
                                        "${p.rating}",
                                        style: const TextStyle(
                                            fontSize: 10, color: fontGrey),
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String value) {
    return Container(
      width: 34,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          color: whiteColor,
          fontSize: 16,
          fontFamily: bold,
        ),
      ),
    );
  }
}
