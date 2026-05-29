import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../consts/consts.dart';
import '../../../firestore_service.dart';

class MyCouponsScreen extends StatefulWidget {
  const MyCouponsScreen({super.key});

  @override
  State<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen> {
  late final Future<void> _seedCoupons;

  @override
  void initState() {
    super.initState();
    _seedCoupons = FirestoreService.ensureDefaultCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(title: const Text('My Coupons')),
      body: FutureBuilder<void>(
        future: _seedCoupons,
        builder: (context, seedSnapshot) {
          if (seedSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: redColor));
          }

          if (seedSnapshot.hasError) {
            return _error(seedSnapshot.error.toString());
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreService.couponsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: redColor),
                );
              }

              if (snapshot.hasError) {
                return _error(snapshot.error.toString());
              }

              final coupons = snapshot.data?.docs
                      .map((doc) => {'id': doc.id, ...doc.data()})
                      .toList() ??
                  [];

              if (coupons.isEmpty) {
                return _empty();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: coupons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _couponCard(coupons[i], context),
              );
            },
          );
        },
      ),
    );
  }

  Widget _couponCard(Map<String, dynamic> c, BuildContext context) {
    final bool valid = c['valid'] == true;
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
                            (c['discount'] ?? '').toString(),
                            style: TextStyle(
                              fontFamily: bold,
                              fontSize: 20,
                              color: valid ? redColor : fontGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text((c['desc'] ?? '').toString(),
                              style: const TextStyle(
                                  fontSize: 13, color: darkFontGrey)),
                          const SizedBox(height: 6),
                          Text((c['expiry'] ?? '').toString(),
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
                                  ClipboardData(text: (c['code'] ?? '').toString()));
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
                              (c['code'] ?? '').toString(),
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

  Widget _empty() {
    return const Center(
      child: Text(
        'No coupons available',
        style: TextStyle(fontFamily: semibold, color: fontGrey),
      ),
    );
  }

  Widget _error(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: redColor),
        ),
      ),
    );
  }
}
