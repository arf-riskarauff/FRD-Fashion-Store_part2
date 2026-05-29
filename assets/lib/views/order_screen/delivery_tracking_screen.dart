import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  FRD Fashion Store – Delivery Tracking Screen
// ─────────────────────────────────────────────

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() =>
      _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  // 0 = Ordered, 1 = Packed, 2 = Shipped, 3 = Out for Delivery, 4 = Delivered
  final int _currentStep = 3;

  final List<_TrackStep> _steps = const [
    _TrackStep(
      icon: Icons.check_circle_outline_rounded,
      title: 'Order Placed',
      subtitle: 'Your order has been confirmed',
      time: '11 Apr, 10:22 AM',
    ),
    _TrackStep(
      icon: Icons.inventory_2_outlined,
      title: 'Order Packed',
      subtitle: 'Seller packed your order',
      time: '11 Apr, 02:45 PM',
    ),
    _TrackStep(
      icon: Icons.local_shipping_outlined,
      title: 'Shipped',
      subtitle: 'Order picked up by BlueDart',
      time: '12 Apr, 09:10 AM',
    ),
    _TrackStep(
      icon: Icons.delivery_dining_rounded,
      title: 'Out for Delivery',
      subtitle: 'Arriving at your doorstep soon',
      time: 'Today, 11:30 AM',
    ),
    _TrackStep(
      icon: Icons.home_rounded,
      title: 'Delivered',
      subtitle: 'Package handed over',
      time: '—',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A2E),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Track Order',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _OrderCard(),
            const SizedBox(height: 16),

            _LiveBanner(pulseCtrl: _pulseCtrl),
            const SizedBox(height: 16),

            // ── Tracking Timeline ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tracking Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._steps.asMap().entries.map(
                        (e) => _TrackTile(
                          step: e.value,
                          index: e.key,
                          currentStep: _currentStep,
                          isLast: e.key == _steps.length - 1,
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const _DeliveryPartnerCard(),
            const SizedBox(height: 16),

            // ── Map placeholder ──
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                ),
              ),
              child: CustomPaint(
                painter: _MapGridPainter(),
                size: const Size(double.infinity, 160),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Live Banner (FIXED ERROR HERE ✅)
// ─────────────────────────────────────────────

class _LiveBanner extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _LiveBanner({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFEF5350)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) => Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✅ double value passed (ERROR FIXED)
                color: Colors.white.withValues(
                  alpha: 255 * (0.5 + pulseCtrl.value * 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Arriving Today by 3:00 PM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const Icon(Icons.access_time_rounded,
              color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Order Card
// ─────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Nike Air Max 270 – ₹4,299',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Track Tile
// ─────────────────────────────────────────────

class _TrackTile extends StatelessWidget {
  final _TrackStep step;
  final int index;
  final int currentStep;
  final bool isLast;

  const _TrackTile({
    required this.step,
    required this.index,
    required this.currentStep,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(step.icon),
      title: Text(step.title),
      subtitle: Text(step.subtitle),
      trailing: Text(step.time),
    );
  }
}

// ─────────────────────────────────────────────
//  Delivery Partner Card
// ─────────────────────────────────────────────

class _DeliveryPartnerCard extends StatelessWidget {
  const _DeliveryPartnerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          CircleAvatar(child: Icon(Icons.person)),
          SizedBox(width: 12),
          Text('Ravi M. · 4.8 ⭐'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Map Grid Painter
// ─────────────────────────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 20)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
//  Data Model
// ─────────────────────────────────────────────

class _TrackStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _TrackStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}