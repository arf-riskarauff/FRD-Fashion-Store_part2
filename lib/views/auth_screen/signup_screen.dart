import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_service.dart';
import '../../consts/consts.dart';
import '../../firestore_service.dart';
import '../../models/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../home_screen/home.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _retypePassController = TextEditingController();
  bool _isLoading = false;

  void _signup() async {
    setState(() => _isLoading = true);
    final appState = context.read<AppState>();
    if (_passController.text != _retypePassController.text) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      final credential = await AuthService.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passController.text,
      );
      await FirestoreService.createOrUpdateUser(
        name: _nameController.text,
        email: credential.user?.email ?? _emailController.text,
      );
      if (!mounted) return;
      await appState.setUser(
        name: _nameController.text,
        email: credential.user?.email ?? _emailController.text.trim(),
      );
      try {
        await FirestoreService.ensureDefaultProducts();
      } catch (_) {
        // Product seeding is best-effort; local fallback still works.
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: redColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: redColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: whiteColor,
            fontFamily: bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Join FRD Fashion Store",
              style: TextStyle(
                fontFamily: bold,
                fontSize: 24,
                color: darkFontGrey,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Create your account to start shopping",
              style: TextStyle(
                fontFamily: regular,
                fontSize: 14,
                color: fontGrey,
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              hint: name,
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: emailHint,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: passwordHint,
              controller: _passController,
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: retypePasswordHint,
              controller: _retypePassController,
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 8),
            RichText(
              text: const TextSpan(
                text: "By signing up, you agree to our ",
                style: TextStyle(
                  color: fontGrey,
                  fontFamily: regular,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: termsAndCond,
                    style: TextStyle(
                      color: redColor,
                      fontFamily: semibold,
                    ),
                  ),
                  TextSpan(text: " and "),
                  TextSpan(
                    text: privacyPolicy,
                    style: TextStyle(
                      color: redColor,
                      fontFamily: semibold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: redColor))
                : CustomButton(text: signup, onTap: _signup),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  alreadyHaveAccount,
                  style: TextStyle(
                    color: fontGrey,
                    fontFamily: regular,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    login,
                    style: TextStyle(
                      color: redColor,
                      fontFamily: bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
