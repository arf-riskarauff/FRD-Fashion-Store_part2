import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../models/app_data.dart';
import '../../models/app_state.dart';
import '../product_screen/product_detail_screen.dart';

class TodaysDealScreen extends StatelessWidget {
  const TodaysDealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allDeals = AppData.featuredProducts;

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        title: const Text(
          today,
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
          // Deal Banner Header
          Container(
            width: double.infinity,
            color: const Color(0xFFFF6B6B),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: whiteColor, size: 28),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Special Deals",
                        style: TextStyle(
                          fontFamily: bold,
                          fontSize: 15,
                          color: whiteColor,
                        ),
                      ),
                      Text(
                        "Best prices just for today!",
                        style: TextStyle(
                          fontFamily: regular,
                          fontSize: 12,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${allDeals.length} Items",
                      style: const TextStyle(
                        fontFamily: semibold,
                        fontSize: 12,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
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
                  itemCount: allDeals.length,
                  itemBuilder: (context, i) {
                    final p = allDeals[i];
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
                                // Deal badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "DEAL",
                                      style: TextStyle(
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
                                          color: Color(0xFFFF6B6B),
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
}

// ignore: constant_identifier_names
const int allDeals = 6;
