import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../consts/consts.dart';
import '../../../models/app_data.dart';
import '../../../models/app_state.dart';
import '../../product_screen/product_detail_screen.dart';

class GirlsDressScreen extends StatelessWidget {
  const GirlsDressScreen({super.key});

  static const String categoryName = girlsDress;

  @override
  Widget build(BuildContext context) {
    return const _CategoryProductScreen(categoryName: categoryName);
  }
}

class _CategoryProductScreen extends StatelessWidget {
  final String categoryName;
  const _CategoryProductScreen({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final allProducts = [
      ...AppData.featuredProducts,
      ...AppData.flashSaleProducts,
    ].where((p) => p.category == categoryName).toList();

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: redColor,
        elevation: 0,
        title: Text(
          categoryName,
          style: const TextStyle(
            fontFamily: bold,
            fontSize: 18,
            color: whiteColor,
          ),
        ),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: allProducts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 60, color: fontGrey),
                  SizedBox(height: 12),
                  Text(
                    "No products in this category",
                    style: TextStyle(
                      fontFamily: semibold,
                      fontSize: 15,
                      color: fontGrey,
                    ),
                  ),
                ],
              ),
            )
          : Consumer<AppState>(
              builder: (context, state, _) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: allProducts.length,
                  itemBuilder: (context, i) {
                    final p = allProducts[i];
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
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        color: fontGrey,
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
                                          color: redColor,
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
    );
  }
}
