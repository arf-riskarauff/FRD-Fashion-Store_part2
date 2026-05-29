import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frd_fashion_store_app/screens/cart_screen.dart';
import 'package:frd_fashion_store_app/screens/product_listing_screen.dart';
import 'package:frd_fashion_store_app/screens/login_screen.dart';

import 'package:frd_fashion_store_app/utils/app_constants.dart';
import 'package:frd_fashion_store_app/models/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _darkModeOn = false;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.shopping_bag_outlined, 'label': 'My Orders', 'badge': '3'},
    {'icon': Icons.favorite_outline, 'label': 'Wishlist', 'badge': ''},
    {'icon': Icons.location_on_outlined, 'label': 'Saved Addresses', 'badge': ''},
    {'icon': Icons.payment_outlined, 'label': 'Payment Methods', 'badge': ''},
    {'icon': Icons.local_offer_outlined, 'label': 'Vouchers & Offers', 'badge': '2'},
    {'icon': Icons.help_outline, 'label': 'Help & Support', 'badge': ''},
    {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy Policy', 'badge': ''},
    {'icon': Icons.info_outline, 'label': 'About F‑Dilu', 'badge': ''},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final String displayName = appState.userName.trim().isEmpty
        ? 'F-Dilu Customer'
        : appState.userName;
    final String displayEmail = appState.userEmail;
    final String initials = appState.userInitials;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditProfile(context, appState),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ─── Profile Header ───────────────────────────────
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// ─── Settings ─────────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Notifications'),
                    trailing: Switch(
                      value: _notificationsOn,
                      onChanged: (v) =>
                          setState(() => _notificationsOn = v),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.dark_mode_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: _darkModeOn,
                      onChanged: (v) =>
                          setState(() => _darkModeOn = v),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// ─── Menu Items ───────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: List.generate(_menuItems.length, (i) {
                  final item = _menuItems[i];
                  return ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: AppColors.primary,
                    ),
                    title: Text(item['label'] as String),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _handleMenuTap(item['label'] as String),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            /// ─── Logout ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (_) => false,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _handleMenuTap(String label) {
    switch (label) {
      case 'My Orders':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        break;

      case 'Wishlist':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ProductListingScreen(category: ''),
          ),
        );
        break;

      default:
        _showComingSoon(label);
    }
  }

  void _showComingSoon(String title) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Coming Soon!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      ),
    );
  }

  void _openEditProfile(BuildContext context, AppState appState) {}
}
