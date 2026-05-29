import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../firestore_service.dart';
import '../../models/app_data.dart';
import '../../models/app_state.dart';
import '../../models/product_model.dart';
import '../../widgets/app_widgets.dart';
import 'product_detail_screen.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text(allProducts),
      ),
      body: StreamBuilder<List<Product>>(
        stream: FirestoreService.productsStream(),
        builder: (context, snapshot) {
          final remoteProducts = snapshot.data ?? [];
          final products =
              remoteProducts.isNotEmpty ? remoteProducts : AppData.allProducts;

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products available',
                style: TextStyle(
                  fontFamily: semibold,
                  color: fontGrey,
                ),
              ),
            );
          }

          return Consumer<AppState>(
            builder: (context, state, _) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _AllProductCard(product: product, state: state);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AllProductCard extends StatelessWidget {
  final Product product;
  final AppState state;

  const _AllProductCard({
    required this.product,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                    child: ProductImage(
                      image: product.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => state.toggleWishlist(product),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: whiteColor,
                      child: Icon(
                        state.isWishlisted(product)
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
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: semibold,
                      fontSize: 13,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 5,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        product.price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: bold,
                          fontSize: 14,
                          color: redColor,
                        ),
                      ),
                      if (product.oldPrice.isNotEmpty)
                        Text(
                          product.oldPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: regular,
                            fontSize: 10,
                            color: fontGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 11, color: golden),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating} (${product.reviews})',
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
