import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../models/app_state.dart';
import '../../models/product_model.dart';
import '../product_screen/product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final String categoryImage;
  final List<dynamic> products;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.categoryImage,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final prods = products.cast<Product>();

    return Scaffold(
      backgroundColor: lightGrey,
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return CustomScrollView(
            slivers: [
              // ── Collapsible header with category image ──
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: redColor,
                iconTheme: const IconThemeData(color: whiteColor),
                title: Text(
                  categoryName,
                  style: const TextStyle(
                    fontFamily: bold,
                    fontSize: 18,
                    color: whiteColor,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        categoryImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: redColor),
                      ),
                      // Dark gradient overlay so title is readable
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              // ignore: deprecated_member_use
                              Colors.black.withOpacity(0.1),
                              // ignore: deprecated_member_use
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                      // Category info at bottom of header
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontFamily: bold,
                                fontSize: 22,
                                color: whiteColor,
                              ),
                            ),
                            Text(
                              '${prods.length} Products',
                              style: const TextStyle(
                                fontSize: 13,
                                color: whiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Products grid ──
              SliverPadding(
                padding: const EdgeInsets.all(14),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final p = prods[i];
                      return _ProductCard(product: p, state: state);
                    },
                    childCount: prods.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.66,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final AppState state;

  const _ProductCard({required this.product, required this.state});

  @override
  Widget build(BuildContext context) {
    final wishlisted = state.isWishlisted(product);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with wishlist button
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: lightGrey,
                        child: const Icon(Icons.image_not_supported,
                            color: fontGrey, size: 32),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => state.toggleWishlist(product),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: whiteColor,
                      child: Icon(
                        wishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: redColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
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
                        product.price,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: bold,
                          color: redColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          product.oldPrice,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: fontGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 11, color: golden),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating}  (${product.reviews})',
                        style: const TextStyle(fontSize: 10, color: fontGrey),
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
}
