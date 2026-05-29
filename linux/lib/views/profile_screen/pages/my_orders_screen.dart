import 'package:flutter/material.dart';
import '../../../consts/consts.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  static const List<Map<String, dynamic>> _orders = [
    {
      'id': '#ORD-001',
      'date': '20 Apr 2026',
      'items': 3,
      'total': '\$75.00',
      'status': 'Delivered',
      'color': Color(0xFF4CAF50),
    },
    {
      'id': '#ORD-002',
      'date': '15 Apr 2026',
      'items': 1,
      'total': '\$25.00',
      'status': 'Shipped',
      'color': Color(0xFF2196F3),
    },
    {
      'id': '#ORD-003',
      'date': '10 Apr 2026',
      'items': 2,
      'total': '\$114.00',
      'status': 'Processing',
      'color': Color(0xFFFF9800),
    },
    {
      'id': '#ORD-004',
      'date': '01 Apr 2026',
      'items': 1,
      'total': '\$30.00',
      'status': 'Cancelled',
      'color': Color(0xFFE53935),
    },
    {
      'id': '#ORD-005',
      'date': '22 Mar 2026',
      'items': 4,
      'total': '\$152.00',
      'status': 'Delivered',
      'color': Color(0xFF4CAF50),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(title: const Text('My Orders')),
      body: _orders.isEmpty
          ? _empty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _orderCard(_orders[i], context),
            ),
    );
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
                  onPressed: () {},
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
