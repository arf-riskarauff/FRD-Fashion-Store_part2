 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'consts/consts.dart';
import 'models/app_state.dart';
import 'views/splash_screen/splash_screen.dart';
import 'views/checkout_screen/payment_method_screen.dart';
import 'views/checkout_screen/address_screen.dart';
import 'views/order_screen/delivery_tracking_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appname,
      debugShowCheckedModeBanner: false,

      // ✅ APP THEME
      theme: ThemeData(
        fontFamily: regular,
        primaryColor: redColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: redColor,
          primary: redColor,
        ),
        scaffoldBackgroundColor: lightGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: whiteColor,
          elevation: 0,
          iconTheme: IconThemeData(color: darkFontGrey),
          titleTextStyle: TextStyle(
            color: darkFontGrey,
            fontFamily: bold,
            fontSize: 18,
          ),
        ),
        useMaterial3: false,
      ),

      // ✅ ROUTES (IMPORTANT)
      routes: {
        '/payment': (context) => const PaymentMethodScreen(),
        '/address': (context) => const AddressScreen(),
        '/tracking': (context) => const DeliveryTrackingScreen(),
      },

      // ✅ START SCREEN
      home: const SplashScreen(),
    );
  }
}
