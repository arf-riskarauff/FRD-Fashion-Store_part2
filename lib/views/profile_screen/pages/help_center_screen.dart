import 'package:flutter/material.dart';
import '../../../consts/consts.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'q': 'How do I track my order?',
      'a':
          'Go to My Orders, select your order, and tap "Track Order" to see real-time updates.',
      'open': false,
    },
    {
      'q': 'What is the return policy?',
      'a':
          'We offer a 30-day return policy. Items must be unused and in their original packaging.',
      'open': false,
    },
    {
      'q': 'How do I cancel an order?',
      'a':
          'You can cancel an order within 1 hour of placing it from My Orders screen.',
      'open': false,
    },
    {
      'q': 'Are my payment details safe?',
      'a':
          'Yes! We use industry-standard SSL encryption to protect all your payment information.',
      'open': false,
    },
    {
      'q': 'How do I apply a coupon?',
      'a':
          'During checkout, enter your coupon code in the "Coupon Code" field and tap Apply.',
      'open': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact options
          _contactCard(),
          const SizedBox(height: 20),

          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
                fontFamily: bold, fontSize: 16, color: darkFontGrey),
          ),
          const SizedBox(height: 12),

          Container(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ExpansionPanelList(
                elevation: 0,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (i, isOpen) {
                  setState(() => _faqs[i]['open'] = !isOpen);
                },
                children: _faqs
                    .map(
                      (faq) => ExpansionPanel(
                        isExpanded: faq['open'] as bool,
                        headerBuilder: (_, __) => ListTile(
                          title: Text(
                            faq['q'],
                            style: const TextStyle(
                              fontFamily: semibold,
                              fontSize: 14,
                              color: darkFontGrey,
                            ),
                          ),
                        ),
                        body: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['a'],
                            style: const TextStyle(
                                fontSize: 13, color: fontGrey),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Support',
              style: TextStyle(
                  fontFamily: bold, fontSize: 15, color: darkFontGrey)),
          const SizedBox(height: 14),
          Row(
            children: [
              _contactBtn(Icons.chat_bubble_outline, 'Live Chat', () {}),
              const SizedBox(width: 12),
              _contactBtn(Icons.email_outlined, 'Email Us', () {}),
              const SizedBox(width: 12),
              _contactBtn(Icons.phone_outlined, 'Call Us', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: redColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: redColor, size: 22),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontFamily: semibold, fontSize: 11, color: redColor)),
            ],
          ),
        ),
      ),
    );
  }
}
