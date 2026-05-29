import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../consts/consts.dart';
import '../../models/product_model.dart';
import '../../models/app_state.dart';
import '../../widgets/app_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedSize = 0;
  int _qty = 1;
  final List<String> _sizes = ["XS", "S", "M", "L", "XL", "XXL"];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = widget.product;

    return Scaffold(
      backgroundColor: lightGrey,
      body: CustomScrollView(
        slivers: [
          /// -------------------- APP BAR --------------------
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: whiteColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: darkFontGrey,
                  size: 18,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => state.toggleWishlist(p),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isWishlisted(p)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: redColor,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                p.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: lightGrey,
                  child: const Icon(
                    Icons.image,
                    size: 80,
                    color: fontGrey,
                  ),
                ),
              ),
            ),
          ),

          /// -------------------- CONTENT --------------------
          SliverToBoxAdapter(
            child: Container(
              color: whiteColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Category
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: redColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.category,
                      style: const TextStyle(
                        color: redColor,
                        fontFamily: semibold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Name
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontFamily: bold,
                      fontSize: 20,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Rating
                  Row(
                    children: [
                      RatingStars(rating: p.rating),
                      const SizedBox(width: 8),
                      Text(
                        "${p.rating} (${p.reviews} reviews)",
                        style: const TextStyle(
                          color: fontGrey,
                          fontFamily: regular,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        p.price,
                        style: const TextStyle(
                          fontFamily: bold,
                          fontSize: 26,
                          color: redColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          p.oldPrice,
                          style: const TextStyle(
                            fontFamily: regular,
                            fontSize: 16,
                            color: fontGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "In Stock",
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontFamily: semibold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: lightGrey),

                  /// Size selector
                  const Text(
                    "Select Size",
                    style: TextStyle(
                      fontFamily: semibold,
                      fontSize: 15,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      _sizes.length,
                      (i) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSize = i;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                _selectedSize == i ? redColor : whiteColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedSize == i
                                  ? redColor
                                  : textfieldGrey,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _sizes[i],
                              style: TextStyle(
                                color: _selectedSize == i
                                    ? whiteColor
                                    : darkFontGrey,
                                fontFamily: semibold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Divider(height: 24, color: lightGrey),

                  /// Quantity
                  Row(
                    children: [
                      const Text(
                        "Quantity",
                        style: TextStyle(
                          fontFamily: semibold,
                          fontSize: 15,
                          color: darkFontGrey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: textfieldGrey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove,
                                  size: 18, color: darkFontGrey),
                              onPressed: () {
                                if (_qty > 1) {
                                  setState(() {
                                    _qty--;
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              width: 32,
                              child: Text(
                                "$_qty",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: bold,
                                  fontSize: 16,
                                  color: darkFontGrey,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  size: 18, color: redColor),
                              onPressed: () {
                                setState(() {
                                  _qty++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: lightGrey),

                  /// Description
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontFamily: semibold,
                      fontSize: 15,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: const TextStyle(
                      fontFamily: regular,
                      fontSize: 14,
                      color: fontGrey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      /// -------------------- BOTTOM BAR --------------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        color: whiteColor,
        child: Row(
          children: [
            /// Wishlist
            GestureDetector(
              onTap: () => state.toggleWishlist(p),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: redColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  state.isWishlisted(p)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: redColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            /// Add to Cart
            Expanded(
              child: CustomButton(
                text: "Add to Cart",
                icon: Icons.shopping_cart_outlined,
                onTap: () {
                  for (int i = 0; i < _qty; i++) {
                    state.addToCart(p);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${p.name} added to cart!",
                        style: const TextStyle(fontFamily: regular),
                      ),
                      backgroundColor: darkFontGrey,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}