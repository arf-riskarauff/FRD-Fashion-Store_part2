import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../consts/consts.dart';
import '../../firestore_service.dart';
import '../../models/app_data.dart';
import '../../models/app_state.dart';
import '../../models/product_model.dart';
import '../../widgets/app_widgets.dart';
import '../product_screen/all_products_screen.dart';
import '../product_screen/product_detail_screen.dart';
import '../category_screen/category_screen.dart';
import 'todays_deal_screen.dart';
import 'flash_sale_screen.dart';
import 'top_brands_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _sliderController = PageController();
  int _currentSlide = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-scroll slider
    Future.delayed(const Duration(seconds: 1), _autoSlide);
  }

  void _autoSlide() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final next = (_currentSlide + 1) % AppData.sliders.length;
      _sliderController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _autoSlide();
    });
  }

  @override
  void dispose() {
    _sliderController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: redColor,
            elevation: 0,
            title: Row(
              children: [
                Image.asset(
                  icAppLogo,
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag,
                      color: whiteColor, size: 28),
                ),
                const SizedBox(width: 8),
                const Text(
                  appname,
                  style: TextStyle(
                    color: whiteColor,
                    fontFamily: bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.notifications_outlined, color: whiteColor),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => context.read<AppState>().setSearch(val),
                    style: const TextStyle(
                      fontFamily: regular,
                      fontSize: 14,
                      color: darkFontGrey,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      hintStyle: const TextStyle(
                          color: fontGrey, fontFamily: regular, fontSize: 14),
                      prefixIcon:
                          const Icon(Icons.search, color: fontGrey, size: 20),
                      suffixIcon:
                          context.watch<AppState>().searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: fontGrey, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<AppState>().setSearch('');
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: StreamBuilder<List<Product>>(
              stream: FirestoreService.productsStream(),
              builder: (context, productSnapshot) {
                final remoteProducts = productSnapshot.data ?? [];
                final hasRemoteProducts = remoteProducts.isNotEmpty;
                final featuredProducts = hasRemoteProducts
                    ? remoteProducts
                    : AppData.featuredProducts;
                final flashSaleProducts = hasRemoteProducts
                    ? remoteProducts.take(4).toList()
                    : AppData.flashSaleProducts;
                final visibleProducts =
                    hasRemoteProducts ? remoteProducts : AppData.allProducts;
                final categoryItems =
                    _categoryItemsFromProducts(visibleProducts);

                return Consumer<AppState>(
                  builder: (context, state, _) {
                    final query = state.searchQuery.toLowerCase();

                    // Search results mode
                    if (query.isNotEmpty) {
                      final results = visibleProducts
                          .where((p) =>
                              p.name.toLowerCase().contains(query) ||
                              p.category.toLowerCase().contains(query))
                          .toList();
                      return _buildSearchResults(results);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slider
                        _buildSlider(),

                        // Today's Deal
                        const SizedBox(height: 8),
                        _buildDealBanner(),

                        // Flash Sale
                        const SizedBox(height: 8),
                        Container(
                          color: whiteColor,
                          child: Column(
                            children: [
                              SectionTitle(
                                title: flashSale,
                                onAction: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AllProductsScreen(),
                                  ),
                                ),
                              ),
                              HorizontalWheelScroller(
                                height: 250,
                                padding: const EdgeInsets.only(left: 16),
                                itemCount: flashSaleProducts.length,
                                itemBuilder: (_, i) => ProductCard(
                                  product: flashSaleProducts[i],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        product: flashSaleProducts[i],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),

                        // Top Categories
                        const SizedBox(height: 8),
                        Container(
                          color: whiteColor,
                          child: Column(
                            children: [
                              SectionTitle(
                                title: topCategories,
                                onAction: () {
                                  context.read<AppState>().setCategory('All');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CategoryScreen(),
                                    ),
                                  );
                                },
                              ),
                              HorizontalWheelScroller(
                                height: 110,
                                padding: const EdgeInsets.only(left: 16),
                                itemCount: categoryItems.length,
                                itemBuilder: (_, i) =>
                                    _buildCategoryChip(categoryItems[i]),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),

                        // Featured Products
                        const SizedBox(height: 8),
                        Container(
                          color: whiteColor,
                          child: Column(
                            children: [
                              SectionTitle(
                                title: featuredProduct,
                                onAction: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AllProductsScreen(),
                                    ),
                                  );
                                },
                              ),
                              HorizontalWheelScroller(
                                height: 250,
                                padding: const EdgeInsets.only(left: 16),
                                itemCount: featuredProducts.length,
                                itemBuilder: (_, i) => ProductCard(
                                  product: featuredProducts[i],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        product: featuredProducts[i],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),

                        // All Products grid
                        const SizedBox(height: 8),
                        Container(
                          color: whiteColor,
                          child: Column(
                            children: [
                              SectionTitle(
                                title: allProducts,
                                onAction: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AllProductsScreen(),
                                  ),
                                ),
                              ),
                              GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                                itemCount: visibleProducts.length,
                                itemBuilder: (_, i) {
                                  final p = visibleProducts[i];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailScreen(product: p),
                                      ),
                                    ),
                                    child: _buildGridProduct(p, state),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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

  Widget _buildSlider() {
    return Container(
      color: whiteColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: _sliderController,
              itemCount: AppData.sliders.length,
              onPageChanged: (i) => setState(() => _currentSlide = i),
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: lightGrey,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  AppData.sliders[i]["image"]!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFFFE5E5),
                    child: const Center(
                      child: Icon(Icons.image, size: 60, color: redColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              AppData.sliders.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentSlide == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentSlide == i ? redColor : textfieldGrey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealBanner() {
    return Container(
      color: whiteColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TodaysDealScreen()),
              ),
              child: _buildBannerItem(
                "Today's\nDeal",
                Icons.local_offer,
                const Color(0xFFFF6B6B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FlashSaleScreen()),
              ),
              child: _buildBannerItem(
                "Flash\nSale",
                Icons.flash_on,
                const Color(0xFFFFB100),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TopBrandsScreen()),
              ),
              child: _buildBannerItem(
                "Top\nBrands",
                Icons.star_outline,
                const Color(0xFF6C63FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontFamily: semibold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Map<String, String> cat) {
    return GestureDetector(
      onTap: () {
        context.read<AppState>().setCategory(cat["name"]!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CategoryScreen(),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                cat["icon"]!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.grid_view, color: redColor, size: 28),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cat["name"]!,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                color: darkFontGrey,
                fontFamily: regular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _categoryItemsFromProducts(List<Product> products) {
    final categoryIconByName = {
      for (final category in AppData.categories)
        category['name']!: category['icon']!,
    };
    final seen = <String>{};
    final items = <Map<String, String>>[];

    for (final product in products) {
      final name = product.category.trim();
      if (name.isEmpty || name.toLowerCase() == 'all' || seen.contains(name)) {
        continue;
      }
      seen.add(name);
      items.add({
        'name': name,
        'icon': categoryIconByName[name] ?? 'assets/icons/categories.png',
      });
    }

    return items.isEmpty ? AppData.categories : items;
  }

  Widget _buildGridProduct(dynamic p, AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
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
                    image: p.image,
                    fit: BoxFit.contain,
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
                  style: const TextStyle(
                    fontFamily: semibold,
                    fontSize: 12,
                    color: darkFontGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                      p.price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: bold,
                        fontSize: 15,
                        color: redColor,
                      ),
                    ),
                    if (p.oldPrice.isNotEmpty)
                      Text(
                        p.oldPrice,
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
                Row(
                  children: [
                    const Icon(Icons.star, size: 11, color: golden),
                    const SizedBox(width: 2),
                    Text(
                      "${p.rating}",
                      style: const TextStyle(fontSize: 10, color: fontGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 60, color: fontGrey),
              SizedBox(height: 12),
              Text(
                "No products found",
                style: TextStyle(
                  fontFamily: semibold,
                  fontSize: 16,
                  color: fontGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final p = results[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: p),
            ),
          ),
          child: _buildGridProduct(p, context.read<AppState>()),
        );
      },
    );
  }
}
