import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../models/app_data.dart';
import '../../models/app_state.dart';
import '../product_screen/product_detail_screen.dart';

class TopBrandsScreen extends StatefulWidget {
  const TopBrandsScreen({super.key});

  @override
  State<TopBrandsScreen> createState() => _TopBrandsScreenState();
}

class _TopBrandsScreenState extends State<TopBrandsScreen> {
  String _selectedBrand = 'All';

  static const List<Map<String, dynamic>> _brands = [
    {'name': 'All', 'icon': Icons.grid_view, 'color': Color(0xFF6C63FF)},
    {'name': 'FashionX', 'icon': Icons.checkroom, 'color': Color(0xFFE91E8C)},
    {'name': 'KidsWear', 'icon': Icons.child_care, 'color': Color(0xFF00BCD4)},
    {'name': 'WatchPro', 'icon': Icons.watch, 'color': Color(0xFFFF9800)},
    {'name': 'StyleHub', 'icon': Icons.style, 'color': Color(0xFF4CAF50)},
    {'name': 'TrendSet', 'icon': Icons.trending_up, 'color': Color(0xFF9C27B0)},
  ];

  // Map products to brands (mock assignment)
  List<dynamic> get _filteredProducts {
    final all = [
      ...AppData.featuredProducts,
      ...AppData.flashSaleProducts,
    ];
    if (_selectedBrand == 'All') return all;

    // Assign brands to products by index (mock logic)
    final brandIndex =
        _brands.indexWhere((b) => b['name'] == _selectedBrand) - 1;
    return all
        .where((p) => all.indexOf(p) % (_brands.length - 1) == brandIndex)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: const Text(
          brand,
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
          // Top Brands Header
          Container(
            width: double.infinity,
            color: const Color(0xFF6C63FF),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star_outline, color: whiteColor, size: 28),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Top Brands",
                        style: TextStyle(
                          fontFamily: bold,
                          fontSize: 15,
                          color: whiteColor,
                        ),
                      ),
                      Text(
                        "Discover premium fashion brands",
                        style: TextStyle(
                          fontFamily: regular,
                          fontSize: 11,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Brand filter chips
          Container(
            color: whiteColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _brands
                    .map((b) => _buildBrandChip(b))
                    .toList(),
              ),
            ),
          ),

          // Brand logo showcase (horizontal scroll)
          if (_selectedBrand == 'All') ...[
            Container(
              color: whiteColor,
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: Text(
                      "Featured Brands",
                      style: TextStyle(
                        fontFamily: bold,
                        fontSize: 14,
                        color: darkFontGrey,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _brands.length - 1,
                      itemBuilder: (context, i) {
                        final b = _brands[i + 1];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedBrand = b['name']),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: (b['color'] as Color)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (b['color'] as Color)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  b['icon'] as IconData,
                                  color: b['color'] as Color,
                                  size: 26,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b['name'] as String,
                                  style: TextStyle(
                                    fontFamily: semibold,
                                    fontSize: 9,
                                    color: b['color'] as Color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Products
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, _) {
                final products = _filteredProducts;

                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: fontGrey),
                        SizedBox(height: 12),
                        Text(
                          "No products for this brand",
                          style: TextStyle(
                            fontFamily: semibold,
                            fontSize: 15,
                            color: fontGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final p = products[i];
                    const brandColor = Color(0xFF6C63FF);

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
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: brandColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "BRAND",
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
                                          color: brandColor,
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

  Widget _buildBrandChip(Map<String, dynamic> b) {
    final selected = _selectedBrand == b['name'];
    final color = b['color'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedBrand = b['name'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : lightGrey,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? color : textfieldGrey,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              b['icon'] as IconData,
              size: 14,
              color: selected ? whiteColor : fontGrey,
            ),
            const SizedBox(width: 5),
            Text(
              b['name'] as String,
              style: TextStyle(
                fontFamily: selected ? semibold : regular,
                fontSize: 12,
                color: selected ? whiteColor : fontGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
