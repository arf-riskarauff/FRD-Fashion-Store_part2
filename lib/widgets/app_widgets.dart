import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../consts/consts.dart';
import '../models/product_model.dart';
import '../models/app_state.dart';

/// ── Product Card ──────────────────────────────────────────────
class HorizontalWheelScroller extends StatefulWidget {
  final double height;
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final IndexedWidgetBuilder itemBuilder;

  const HorizontalWheelScroller({
    super.key,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<HorizontalWheelScroller> createState() =>
      _HorizontalWheelScrollerState();
}

class _HorizontalWheelScrollerState extends State<HorizontalWheelScroller> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;

    final delta = event.scrollDelta.dy.abs() >= event.scrollDelta.dx.abs()
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    final target = (_controller.offset + delta).clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );

    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: SizedBox(
        height: widget.height,
        child: ListView.builder(
          controller: _controller,
          padding: widget.padding,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder,
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: ProductImage(
                    image: product.image,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        product.price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: bold,
                          fontSize: 16,
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
                            fontSize: 11,
                            color: fontGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: golden),
                      const SizedBox(width: 2),
                      Text(
                        "${product.rating}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: fontGrey,
                          fontFamily: regular,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${product.reviews})",
                        style: const TextStyle(
                          fontSize: 10,
                          color: fontGrey,
                          fontFamily: regular,
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
}

class ProductImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final source = _cleanImageSource(image);
    final isNetworkImage =
        source.startsWith('http://') || source.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  String _cleanImageSource(String value) {
    var text = value.trim();
    while (text.toLowerCase().startsWith('%20')) {
      text = text.substring(3).trim();
    }
    text = text.replaceFirst(RegExp(r'^\s+'), '');

    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme) return uri.toString();

    return text;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: lightGrey,
      child: const Icon(
        Icons.image,
        color: fontGrey,
        size: 40,
      ),
    );
  }
}

/// ── Section Title ─────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText = "See all",
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: bold,
              fontSize: 16,
              color: darkFontGrey,
            ),
          ),
          if (onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText,
                style: const TextStyle(
                  fontFamily: semibold,
                  fontSize: 13,
                  color: redColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ── Custom Button ─────────────────────────────────────────────
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final double? width;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.textColor,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color ?? redColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? whiteColor, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor ?? whiteColor,
                fontFamily: bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Custom TextField ──────────────────────────────────────────
class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: regular,
        color: darkFontGrey,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: fontGrey, fontFamily: regular),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: fontGrey, size: 20)
            : null,
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// ── Rating Stars ──────────────────────────────────────────────
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, size: size, color: golden);
        } else if (i < rating) {
          return Icon(Icons.star_half, size: size, color: golden);
        } else {
          return Icon(Icons.star_border, size: size, color: golden);
        }
      }),
    );
  }
}
