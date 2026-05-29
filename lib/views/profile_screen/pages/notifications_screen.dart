import 'package:flutter/material.dart';
import '../../../consts/consts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.local_offer_rounded,
      'color': redColor,
      'title': 'Flash Sale is Live!',
      'body': 'Up to 60% off on selected items. Limited time only!',
      'time': '2 min ago',
      'read': false,
    },
    {
      'icon': Icons.local_shipping_outlined,
      'color': const Color(0xFF2196F3),
      'title': 'Order Shipped',
      'body': 'Your order #ORD-002 has been shipped.',
      'time': '1 hr ago',
      'read': false,
    },
    {
      'icon': Icons.check_circle_outline,
      'color': const Color(0xFF4CAF50),
      'title': 'Order Delivered',
      'body': 'Your order #ORD-001 was delivered successfully.',
      'time': '3 hrs ago',
      'read': true,
    },
    {
      'icon': Icons.card_giftcard_outlined,
      'color': const Color(0xFFFF9800),
      'title': 'New Coupon Available',
      'body': 'Use code SUMMER10 for 10% off on summer collection.',
      'time': 'Yesterday',
      'read': true,
    },
    {
      'icon': Icons.favorite_outline,
      'color': const Color(0xFFE91E63),
      'title': 'Item Back in Stock',
      'body': 'Smart Watch from your wishlist is back in stock!',
      'time': '2 days ago',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (final n in _notifications) {
                  n['read'] = true;
                }
              });
            },
            child: const Text('Mark all read',
                style: TextStyle(color: redColor, fontSize: 13)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _notifCard(_notifications[i], i),
      ),
    );
  }

  Widget _notifCard(Map<String, dynamic> n, int i) {
    return GestureDetector(
      onTap: () => setState(() => _notifications[i]['read'] = true),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: n['read'] ? whiteColor : redColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            // ignore: deprecated_member_use
            color: n['read'] ? Colors.transparent : redColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: (n['color'] as Color).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(n['icon'] as IconData,
                  color: n['color'] as Color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n['title'],
                            style: TextStyle(
                              fontFamily: bold,
                              fontSize: 14,
                              color: darkFontGrey,
                              fontWeight: n['read']
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            )),
                      ),
                      if (!(n['read'] as bool))
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: redColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n['body'],
                      style:
                          const TextStyle(fontSize: 13, color: fontGrey)),
                  const SizedBox(height: 6),
                  Text(n['time'],
                      style: const TextStyle(
                          fontSize: 11, color: textfieldGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
