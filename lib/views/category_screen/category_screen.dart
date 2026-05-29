import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../firestore_service.dart';
import '../../models/app_data.dart';
import '../../models/app_state.dart';
import '../../models/product_model.dart';
import '../../widgets/app_widgets.dart';
import '../product_screen/product_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, String? selectedCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: const Text(
          categories,
          style: TextStyle(
            fontFamily: bold,
            fontSize: 18,
            color: darkFontGrey,
          ),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: FirestoreService.productsStream(),
        builder: (context, productSnapshot) {
          final remoteProducts = productSnapshot.data ?? [];
          final hasRemoteProducts = remoteProducts.isNotEmpty;
          final allProducts =
              hasRemoteProducts ? remoteProducts : AppData.allProducts;
          final categoryNames = hasRemoteProducts
              ? _categoryNamesFromProducts(remoteProducts)
              : {
                  ...AppData.categories.map((c) => c['name']!),
                  ...AppData.allProducts.map((p) => p.category),
                }.toList();

          return Consumer<AppState>(
            builder: (context, state, _) {
              final filtered = state.selectedCategory == 'All'
                  ? allProducts
                  : allProducts
                      .where(
                        (p) => p.category == state.selectedCategory,
                      )
                      .toList();

              return Column(
                children: [
                  // ═════ CATEGORY CHIPS ═════
                  Container(
                    color: whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: HorizontalWheelScroller(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categoryNames.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildChip('All', state);
                        return _buildChip(categoryNames[index - 1], state);
                      },
                    ),
                  ),

                  // ═════ PRODUCT GRID ═════
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 60,
                                  color: fontGrey,
                                ),
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
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final p = filtered[i];

                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailScreen(product: p),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 6,
                                        color: Colors.black
                                            .withValues(alpha: 0.06),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: ProductImage(
                                            image: p.image,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
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
                                                    fontSize: 14,
                                                    fontFamily: bold,
                                                    color: redColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  p.oldPrice,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: fontGrey,
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
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ═════ CATEGORY CHIP ═════
  Widget _buildChip(String label, AppState state) {
    final selected = state.selectedCategory == label;

    return GestureDetector(
      onTap: () => state.setCategory(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    redColor,
                    redColor.withValues(alpha: 0.85),
                  ],
                )
              : null,
          color: selected ? null : lightGrey,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? redColor : textfieldGrey,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: redColor.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: selected ? semibold : regular,
            fontSize: 13,
            color: selected ? whiteColor : fontGrey,
          ),
        ),
      ),
    );
  }

  List<String> _categoryNamesFromProducts(List<Product> products) {
    final seen = <String>{};
    final names = <String>[];

    for (final product in products) {
      final name = product.category.trim();
      if (name.isEmpty || name.toLowerCase() == 'all' || seen.contains(name)) {
        continue;
      }
      seen.add(name);
      names.add(name);
    }

    return names;
  }
}
