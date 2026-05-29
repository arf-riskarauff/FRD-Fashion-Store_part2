import 'package:flutter/material.dart';
import '../../../consts/consts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            'Information We Collect',
            'We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support. This includes name, email address, phone number, shipping address, and payment information.',
          ),
          _section(
            'How We Use Your Information',
            'We use your information to process orders and payments, communicate with you about orders and promotions, improve our services, send marketing communications (with your consent), and comply with legal obligations.',
          ),
          _section(
            'Information Sharing',
            'We do not sell, trade, or transfer your personal information to third parties without your consent, except for trusted partners who assist us in operating our platform and conducting our business.',
          ),
          _section(
            'Data Security',
            'We implement industry-standard security measures including SSL encryption to protect your personal information. However, no method of transmission over the internet is 100% secure.',
          ),
          _section(
            'Cookies',
            'We use cookies to enhance your browsing experience, analyze site traffic, and personalize content. You can choose to disable cookies in your browser settings.',
          ),
          _section(
            'Your Rights',
            'You have the right to access, correct, or delete your personal information. You may also opt out of marketing communications at any time by contacting us.',
          ),
          _section(
            'Contact Us',
            'If you have questions about this Privacy Policy, please contact us at privacy@frdfashion.com or call +1 (800) FRD-HELP.',
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Last updated: January 1, 2026',
              style: TextStyle(fontSize: 12, color: fontGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontFamily: bold, fontSize: 14, color: darkFontGrey)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  fontSize: 13, color: fontGrey, height: 1.5)),
        ],
      ),
    );
  }
}

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(title: const Text('About App')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: redColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: redColor, size: 50),
                ),
                const SizedBox(height: 16),
                const Text(
                  appname,
                  style: TextStyle(
                      fontFamily: bold, fontSize: 22, color: darkFontGrey),
                ),
                const SizedBox(height: 6),
                const Text(
                  appversion,
                  style: TextStyle(fontSize: 14, color: fontGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _infoCard('Description',
              'FRD Fashion Store is your one-stop destination for trendy, affordable fashion. Discover the latest styles in women\'s wear, kids\' clothing, accessories, and much more.'),
          _infoCard('Developer', 'FRD Fashion Store Team'),
          _infoCard('Contact', 'support@frdfashion.com'),
          _infoCard('Website', 'www.frdfashionstore.com'),

          const SizedBox(height: 8),
          const Center(
            child: Text(
              credits,
              style: TextStyle(fontSize: 12, color: fontGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(14),
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
          Text(label,
              style: const TextStyle(
                  fontFamily: semibold, fontSize: 13, color: fontGrey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: darkFontGrey),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
