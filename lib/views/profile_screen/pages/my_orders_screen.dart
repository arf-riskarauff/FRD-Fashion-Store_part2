import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../consts/consts.dart';
import '../../../firestore_service.dart';
import '../../../utils/price_utils.dart';
import '../../order_screen/delivery_tracking_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.ordersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: redColor));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: redColor),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final orders = docs.map((doc) => _orderFromDoc(doc)).toList();

          return orders.isEmpty
              ? _empty()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _orderCard(orders[i], context),
                );
        },
      ),
    );
  }

  Map<String, dynamic> _orderFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final items = data['items'] is List ? data['items'] as List : const [];
    final createdAt = data['createdAt'];
    final date = createdAt is Timestamp
        ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
        : 'Today';
    final total = (data['total'] as num?)?.toDouble() ?? 0;
    final status = (data['status'] ?? 'Processing').toString();

    return {
      'id': '#${doc.id.substring(0, doc.id.length > 6 ? 6 : doc.id.length).toUpperCase()}',
      'docId': doc.id,
      'date': date,
      'items': items.length,
      'total': PriceUtils.format(total),
      'status': status,
      'color': _statusColor(status),
    };
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF4CAF50);
      case 'shipped':
        return const Color(0xFF2196F3);
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFF9800);
    }
  }

  Widget _orderCard(Map<String, dynamic> o, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(o['id'],
                  style: const TextStyle(
                      fontFamily: bold, fontSize: 15, color: darkFontGrey)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: (o['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  o['status'],
                  style: TextStyle(
                    fontFamily: semibold,
                    fontSize: 12,
                    color: o['color'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _info(Icons.calendar_today_outlined, o['date']),
              const SizedBox(width: 20),
              _info(Icons.shopping_bag_outlined,
                  '${o['items']} Item${o['items'] > 1 ? 's' : ''}'),
              const Spacer(),
              Text(
                o['total'],
                style: const TextStyle(
                    fontFamily: bold, fontSize: 16, color: redColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeliveryTrackingScreen(),
                        settings: RouteSettings(arguments: o['docId']),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: redColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('View Details',
                      style: TextStyle(color: redColor, fontFamily: semibold)),
                ),
              ),
              const SizedBox(width: 10),
              if (o['status'] == 'Delivered')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reorder',
                        style:
                            TextStyle(color: whiteColor, fontFamily: semibold)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: fontGrey),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(fontSize: 12, color: fontGrey)),
        ],
      );

  Widget _empty() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: textfieldGrey),
            SizedBox(height: 16),
            Text('No orders yet',
                style: TextStyle(
                    fontFamily: semibold, fontSize: 16, color: fontGrey)),
            SizedBox(height: 6),
            Text('Your orders will appear here',
                style: TextStyle(fontSize: 13, color: fontGrey)),
          ],
        ),
      );
}
