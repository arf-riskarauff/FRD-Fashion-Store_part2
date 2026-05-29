import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../consts/consts.dart';
import '../../auth_service.dart';
import '../../firestore_service.dart';
import '../../models/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../home_screen/home.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final appState = context.read<AppState>();
    try {
      final credential = await AuthService.signIn(
        email: _emailController.text,
        password: _passController.text,
      );
      final user = credential.user;
      if (user != null) {
        await appState.setUser(
          name: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : user.email!.split('@').first,
          email: user.email ?? _emailController.text.trim(),
          photoUrl: user.photoURL ?? '',
          saveRemote: false,
        );
        try {
          await appState.loadUserProfile();
        } on FirebaseException catch (e) {
          if (e.code != 'permission-denied') rethrow;
        }
        try {
          await FirestoreService.ensureDefaultProducts();
        } catch (_) {
          // Product seeding is best-effort; local fallback still works.
        }
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: redColor),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first')),
      );
      return;
    }
    await AuthService.sendPasswordReset(_emailController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top banner
            Container(
              height: 260,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [redColor, Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      icAppLogo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag,
                        size: 50,
                        color: redColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    appname,
                    style: TextStyle(
                      color: whiteColor,
                      fontFamily: bold,
                      fontSize: 28,
                    ),
                  ),
                  const Text(
                    "Welcome back!",
                    style: TextStyle(
                      color: whiteColor,
                      fontFamily: regular,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Sign In",
                    style: TextStyle(
                      fontFamily: bold,
                      fontSize: 24,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Login to continue shopping",
                    style: TextStyle(
                      fontFamily: regular,
                      fontSize: 14,
                      color: fontGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        forgetPass,
                        style: TextStyle(
                          color: redColor,
                          fontFamily: semibold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: redColor))
                      : CustomButton(text: login, onTap: _login),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: textfieldGrey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          or,
                          style: TextStyle(
                            color: fontGrey,
                            fontFamily: regular,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: textfieldGrey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Social login buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            _login();
                          },
                          icon: Image.asset(
                            icGoogleLogo,
                            height: 20,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.g_mobiledata, size: 20),
                          ),
                          label: const Text(
                            "Google",
                            style: TextStyle(
                              color: darkFontGrey,
                              fontFamily: semibold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: textfieldGrey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _login,
                          icon: Image.asset(
                            icFacebookLogo,
                            height: 20,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.facebook,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                          label: const Text(
                            "Facebook",
                            style: TextStyle(
                              color: darkFontGrey,
                              fontFamily: semibold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: textfieldGrey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        dontHaveAccount,
                        style: TextStyle(
                          color: fontGrey,
                          fontFamily: regular,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        ),
                        child: const Text(
                          signup,
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
          ],
        ),
      ),
    );
  }
}
