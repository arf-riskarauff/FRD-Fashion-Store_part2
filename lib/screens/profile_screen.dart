import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/app_constants.dart';
import 'login_screen.dart';
import 'product_listing_screen.dart';
import 'cart_screen.dart';

// ════════════════════════════════════════════════════════════════
//  PROFILE SCREEN
// ════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _darkModeOn = false;

  final _menuItems = [
    {'icon': Icons.shopping_bag_outlined, 'label': 'My Orders', 'badge': '3'},
    {'icon': Icons.favorite_outline, 'label': 'Wishlist', 'badge': ''},
    {'icon': Icons.location_on_outlined, 'label': 'Saved Addresses', 'badge': ''},
    {'icon': Icons.payment_outlined, 'label': 'Payment Methods', 'badge': ''},
    {'icon': Icons.local_offer_outlined, 'label': 'Vouchers & Offers', 'badge': '2'},
    {'icon': Icons.help_outline, 'label': 'Help & Support', 'badge': ''},
    {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy Policy', 'badge': ''},
    {'icon': Icons.info_outline, 'label': 'About F-Dilu', 'badge': ''},
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

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
            tooltip: 'Edit Profile',
            onPressed: () => _openEditProfile(context, state),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            _ProfileHeader(state: state),

            // ── Stats row ────────────────────────────────────────
            _StatsRow(wishlistCount: state.wishlist.length),
            const SizedBox(height: 12),

            // ── User Info Card ───────────────────────────────────
            _UserInfoCard(state: state, onEdit: () => _openEditProfile(context, state)),
            const SizedBox(height: 12),

            // ── Quick Settings ────────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _SettingTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: Switch(
                      value: _notificationsOn,
                      onChanged: (v) => setState(() => _notificationsOn = v),
                      activeThumbColor: AppColors.accent,
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _SettingTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    trailing: Switch(
                      value: _darkModeOn,
                      onChanged: (v) => setState(() => _darkModeOn = v),
                      activeThumbColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Menu items ────────────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: List.generate(_menuItems.length, (i) {
                  final item = _menuItems[i];
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          item['icon'] as IconData,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          item['label'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if ((item['badge'] as String).isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['badge'] as String,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textGrey),
                          ],
                        ),
                        onTap: () => _handleMenuTap(item['label'] as String),
                      ),
                      if (i < _menuItems.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ── Logout ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Version ───────────────────────────────────────────
            const Text(
              'F-Dilu Fashion Store v1.0.0',
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Open Edit Profile Sheet ──────────────────────────────────
  void _openEditProfile(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(state: state),
    );
  }

  // ── Menu taps ────────────────────────────────────────────────
  void _handleMenuTap(String label) {
    switch (label) {
      case 'My Orders':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CartScreen()));
        break;
      case 'Wishlist':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ProductListingScreen(category: '')));
        break;
      default:
        _showComingSoon(label);
    }
  }

  void _showComingSoon(String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.construction_outlined,
                size: 48, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('This feature is coming soon!',
                style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  PROFILE HEADER
// ════════════════════════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  final AppState state;
  const _ProfileHeader({required this.state});

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1000,
    );
    if (picked == null) return;

    try {
      final bytes = await picked.readAsBytes();
      final extension = picked.name.split('.').last;
      await state.updateProfilePhoto(bytes: bytes, extension: extension);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Row(
        children: [
          // Avatar with camera button
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.accent,
                backgroundImage: state.userPhotoUrl.isEmpty
                    ? null
                    : NetworkImage(state.userPhotoUrl),
                child: state.userPhotoUrl.isEmpty
                    ? Text(
                        state.userAvatarInitials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickAndUploadImage(context),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        size: 13, color: Colors.white60),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        state.userEmail,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (state.userPhone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 13, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        state.userPhone,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⭐ Premium Member',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  STATS ROW
// ════════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  final int wishlistCount;
  const _StatsRow({required this.wishlistCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _statItem('12', 'Orders'),
          _vDivider(),
          _statItem('$wishlistCount', 'Wishlist'),
          _vDivider(),
          _statItem('3', 'Reviews'),
          _vDivider(),
          _statItem('850', 'Points'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textGrey, fontSize: 12)),
          ],
        ),
      );

  Widget _vDivider() => Container(
      width: 1, height: 40, color: Colors.grey.shade200);
}

// ════════════════════════════════════════════════════════════════
//  USER INFO CARD
// ════════════════════════════════════════════════════════════════
class _UserInfoCard extends StatelessWidget {
  final AppState state;
  final VoidCallback onEdit;
  const _UserInfoCard({required this.state, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final hasExtra = state.userGender.isNotEmpty || state.userDob.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text('Edit',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.person_outline, 'Full Name', state.userName),
          _infoRow(Icons.email_outlined, 'Email', state.userEmail),
          if (state.userPhone.isNotEmpty)
            _infoRow(Icons.phone_outlined, 'Phone', state.userPhone),
          if (state.userGender.isNotEmpty)
            _infoRow(Icons.wc_outlined, 'Gender', state.userGender),
          if (state.userDob.isNotEmpty)
            _infoRow(Icons.cake_outlined, 'Date of Birth', state.userDob),
          if (!hasExtra && state.userPhone.isEmpty)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      // ignore: deprecated_member_use
                      color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 16, color: AppColors.accent),
                    SizedBox(width: 8),
                    Text(
                      'Complete your profile for a better experience',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textDark)),
                ],
              ),
            ),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════════
//  SETTING TILE HELPER
// ════════════════════════════════════════════════════════════════
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const _SettingTile(
      {required this.icon, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing,
      );
}

// ════════════════════════════════════════════════════════════════
//  EDIT PROFILE BOTTOM SHEET
// ════════════════════════════════════════════════════════════════
class _EditProfileSheet extends StatefulWidget {
  final AppState state;
  const _EditProfileSheet({required this.state});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;
  String _gender = '';

  final _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.state.userName);
    _emailCtrl = TextEditingController(text: widget.state.userEmail);
    _phoneCtrl = TextEditingController(text: widget.state.userPhone);
    _dobCtrl = TextEditingController(text: widget.state.userDob);
    _gender = widget.state.userGender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.state.updateProfile(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        gender: _gender,
        dob: _dobCtrl.text,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 10),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.accent,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    if (picked != null) {
      _dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  const Icon(Icons.person_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Full Name
              _buildLabel('Full Name *'),
              _buildField(
                controller: _nameCtrl,
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 14),

              // Email
              _buildLabel('Email Address *'),
              _buildField(
                controller: _emailCtrl,
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                  if (!re.hasMatch(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone
              _buildLabel('Phone Number'),
              _buildField(
                controller: _phoneCtrl,
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Gender
              _buildLabel('Gender'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _gender.isEmpty ? null : _gender,
                    isExpanded: true,
                    hint: const Text('Select gender',
                        style: TextStyle(color: AppColors.textGrey)),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textGrey),
                    items: _genders
                        .map((g) => DropdownMenuItem(
                            value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Date of Birth
              _buildLabel('Date of Birth'),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildField(
                    controller: _dobCtrl,
                    hint: 'DD/MM/YYYY',
                    icon: Icons.cake_outlined,
                    suffixIcon: Icons.calendar_today_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark)),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: AppColors.textGrey, size: 18)
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      );
}
