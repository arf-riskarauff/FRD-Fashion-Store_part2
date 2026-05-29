import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../consts/consts.dart';

class MyCouponsScreen extends StatelessWidget {
  const MyCouponsScreen({super.key});

  static const List<Map<String, dynamic>> _coupons = [
    {
      'code': 'WELCOME20',
      'discount': '20% OFF',
      'desc': 'On your first order',
      'expiry': 'Expires: 30 Jun 2026',
      'valid': true,
    },
    {
      'code': 'FLASH50',
      'discount': '\$50 OFF',
      'desc': 'On orders above \$200',
      'expiry': 'Expires: 15 May 2026',
      'valid': true,
    },
    {
      'code': 'SUMMER10',
      'discount': '10% OFF',
      'desc': 'On summer collection',
      'expiry': 'Expired: 01 Jan 2026',
      'valid': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(title: const Text('My Coupons')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _coupons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _couponCard(_coupons[i], context),
      ),
    );
  }

  Widget _couponCard(Map<String, dynamic> c, BuildContext context) {
    final bool valid = c['valid'] as bool;
    return Opacity(
      opacity: valid ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left color strip
            Container(
              width: 8,
              height: 100,
              decoration: BoxDecoration(
                color: valid ? redColor : fontGrey,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['discount'],
                            style: TextStyle(
                              fontFamily: bold,
                              fontSize: 20,
                              color: valid ? redColor : fontGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(c['desc'],
                              style: const TextStyle(
                                  fontSize: 13, color: darkFontGrey)),
                          const SizedBox(height: 6),
                          Text(c['expiry'],
                              style: const TextStyle(
                                  fontSize: 11, color: fontGrey)),
                        ],
                      ),
                    ),
                    // Copy button
                    GestureDetector(
                      onTap: valid
                          ? () {
                              Clipboard.setData(
                                  ClipboardData(text: c['code']));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Coupon "${c['code']}" copied!'),
                                  backgroundColor: redColor,
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: valid
                              // ignore: deprecated_member_use
                              ? redColor.withOpacity(0.1)
                              // ignore: deprecated_member_use
                              : fontGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: valid ? redColor : fontGrey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              c['code'],
                              style: TextStyle(
                                fontFamily: bold,
                                fontSize: 13,
                                color: valid ? redColor : fontGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              valid ? 'Tap to copy' : 'Expired',
                              style: TextStyle(
                                fontSize: 10,
                                color: valid ? redColor : fontGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
