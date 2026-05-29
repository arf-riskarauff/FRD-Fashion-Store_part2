import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../consts/consts.dart';
import '../../../models/app_state.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _genderCtrl;
  late TextEditingController _dobCtrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _nameCtrl = TextEditingController(text: state.userName);
    _emailCtrl = TextEditingController(text: state.userEmail);
    _phoneCtrl = TextEditingController(text: state.userPhone);
    _genderCtrl = TextEditingController(text: state.userGender);
    _dobCtrl = TextEditingController(text: state.userDob);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _genderCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AppState>().updateProfile(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              gender: _genderCtrl.text.trim(),
              dob: _dobCtrl.text.trim(),
            );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_firebaseMessage(e)),
            backgroundColor: redColor,
          ),
        );
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: redColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1000,
    );
    if (picked == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final bytes = await picked.readAsBytes();
      final extension = picked.name.split('.').last;
      if (!mounted) return;
      await context.read<AppState>().updateProfilePhoto(
            bytes: bytes,
            extension: extension,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated successfully!'),
          backgroundColor: redColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_firebaseMessage(e)),
          backgroundColor: redColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  String _firebaseMessage(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied' ||
          error.code == 'unauthorized' ||
          error.code == 'storage/unauthorized') {
        return 'Firebase permission denied. Please login again and check Firebase rules are deployed.';
      }
      return 'Firebase error: ${error.message ?? error.code}';
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: redColor,
                fontFamily: bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Avatar ──
              Center(
                child: Consumer<AppState>(
                  builder: (context, state, _) {
                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 58,
                          backgroundColor: textfieldGrey,
                          backgroundImage: state.userPhotoBytes != null
                              ? MemoryImage(state.userPhotoBytes!)
                              : state.userPhotoUrl.isEmpty
                                  ? const AssetImage(
                                      'assets/images/profile_image.png')
                                  : NetworkImage(state.userPhotoUrl)
                                      as ImageProvider,
                        ),
                        GestureDetector(
                          onTap: _isUploadingImage
                              ? null
                              : _pickAndUploadProfileImage,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: redColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: _isUploadingImage
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: whiteColor,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt,
                                    size: 16, color: whiteColor),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // ── Fields ──
              _buildCard([
                _field(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name required' : null,
                ),
                _divider(),
                _field(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Valid email required'
                      : null,
                ),
                _divider(),
                _field(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ]),

              const SizedBox(height: 16),

              _buildCard([
                _field(
                  controller: _genderCtrl,
                  label: 'Gender',
                  icon: Icons.wc_outlined,
                ),
                _divider(),
                _field(
                  controller: _dobCtrl,
                  label: 'Date of Birth',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.datetime,
                  hint: 'DD / MM / YYYY',
                ),
              ]),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontFamily: bold,
                      fontSize: 15,
                      color: whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: redColor, size: 20),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          color: fontGrey,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56, endIndent: 16);
}
