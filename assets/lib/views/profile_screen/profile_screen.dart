import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../models/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../auth_screen/login_screen.dart';
import '../product_screen/product_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: lightGrey,
      body: SafeArea(
        child: ListView(
          children: [
            _profileHeader(state),
            const SizedBox(height: 10),

            if (state.wishlist.isNotEmpty)
              _wishlistSection(context, state),

            const SizedBox(height: 10),

            _menuSection(
              context,
              [
                _MenuData(Icons.shopping_bag_outlined, orders,
                    onTap: () => _showComingSoon(context, orders)),
                _MenuData(Icons.location_on_outlined, 'My Addresses',
                    onTap: () =>
                        Navigator.pushNamed(context, '/address')),
                _MenuData(Icons.payment_outlined, 'Payment Methods',
                    onTap: () =>
                        Navigator.pushNamed(context, '/payment')),
                _MenuData(Icons.local_offer_outlined, 'My Coupons',
                    onTap: () =>
                        _showComingSoon(context, 'My Coupons')),
                _MenuData(Icons.notifications_outlined, 'Notifications',
                    onTap: () =>
                        _showComingSoon(context, 'Notifications')),
              ],
            ),

            const SizedBox(height: 10),

            _menuSection(
              context,
              [
                _MenuData(Icons.help_outline, 'Help Center',
                    onTap: () =>
                        _showComingSoon(context, 'Help Center')),
                _MenuData(Icons.privacy_tip_outlined, privacyPolicy,
                    onTap: () => _showPrivacyPolicy(context)),
                _MenuData(Icons.info_outline, 'About App',
                    onTap: () => _showAboutApp(context)),
              ],
            ),

            _logoutButton(context),
            _footerText(),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _profileHeader(AppState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 52,
                backgroundColor: lightGrey,
                backgroundImage:
                    AssetImage('assets/images/'),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: redColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: whiteColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Riska Fikri',
            style: TextStyle(
                fontFamily: bold,
                fontSize: 20,
                color: darkFontGrey),
          ),
          const SizedBox(height: 4),
          const Text(
            'riska.fikri@email.com',
            style: TextStyle(fontSize: 14, color: fontGrey),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat('Cart', state.cartCount.toString()),
              _divider(),
              _stat(
                  'Wishlist', state.wishlist.length.toString()),
              _divider(),
              _stat('Orders', '5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontFamily: bold,
                  fontSize: 18,
                  color: darkFontGrey)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: fontGrey)),
        ],
      );

  Widget _divider() =>
      Container(width: 1, height: 32, color: textfieldGrey);

  // ================= WISHLIST =================

  Widget _wishlistSection(BuildContext context, AppState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: wishlist),
          SizedBox(
            height: 220,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16),
              scrollDirection: Axis.horizontal,
              itemCount: state.wishlist.length,
              itemBuilder: (_, i) =>
                  ProductCard(
                product: state.wishlist[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(
                            product:
                                state.wishlist[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU =================

  Widget _menuSection(
      BuildContext context, List<_MenuData> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: items
            .map(
              (item) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        // ignore: deprecated_member_use
                        redColor.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon,
                      color: redColor, size: 20),
                ),
                title: Text(item.title,
                    style: const TextStyle(
                        fontFamily: semibold,
                        fontSize: 14,
                        color: darkFontGrey)),
                trailing: const Icon(
                    Icons.chevron_right,
                    color: fontGrey),
                onTap: item.onTap,
              ),
            )
            .toList(),
      ),
    );
  }

  // ================= LOGOUT =================

  Widget _logoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomButton(
        text: logout,
        icon: Icons.logout,
        color: lightGrey,
        textColor: darkFontGrey,
        onTap: () =>
            Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const LoginScreen()),
          (_) => false,
        ),
      ),
    );
  }

  Widget _footerText() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Center(
        child: Text(
          '$appversion • $credits',
          style:
              TextStyle(fontSize: 11, color: fontGrey),
        ),
      ),
    );
  }

  // ================= DIALOG =================

  void _showComingSoon(
      BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature – Coming Soon!'),
        backgroundColor: redColor,
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {}
  void _showAboutApp(BuildContext context) {}
}

// ================= MENU MODEL =================

class _MenuData {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _MenuData(this.icon, this.title,
      {this.onTap});
}
