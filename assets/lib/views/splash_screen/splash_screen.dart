import 'package:flutter/material.dart';
import '../../consts/consts.dart';
import '../auth_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<Offset> _logoSlide;
  late Animation<double> _logoRotate;

  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // 🔹 Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoRotate = Tween<double>(
      begin: -0.4,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    // 🔹 Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textFade =
        Tween<double>(begin: 0, end: 1).animate(_textController);

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 600), () {
      _textController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [redColor, Color(0xFFFF6B6B)], // ✅ SAME COLORS
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔥 NEW LOGO MODEL (Slide + Rotate)
            SlideTransition(
              position: _logoSlide,
              child: RotationTransition(
                turns: _logoRotate,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 60),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    icAppLogo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.shopping_bag_rounded,
                      size: 60,
                      color: redColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ✨ Staggered Text Animation
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: const Column(
                  children: [
                    Text(
                      appname,
                      style: TextStyle(
                        color: whiteColor,
                        fontFamily: bold,
                        fontSize: 36,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Shop Smarter, Live Better",
                      style: TextStyle(
                        color: whiteColor,
                        fontFamily: regular,
                        fontSize: 15,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 65),

            // 🔄 Smooth Loader
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (_, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: const CircularProgressIndicator(
                color: whiteColor,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}