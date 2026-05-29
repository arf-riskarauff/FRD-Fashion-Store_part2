import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../firestore_service.dart';
import '../../utils/price_utils.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

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
    final args = ModalRoute.of(context)?.settings.arguments;
    final orderId = args is String ? args : null;
    final stream = orderId == null
        ? FirestoreService.latestOrderStream()
        : FirestoreService.orderStream(orderId).map((doc) {
            return doc.exists ? doc : null;
          });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E), size: 20),
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            );
          }

          if (snapshot.hasError) {
            return _MessageState(message: snapshot.error.toString());
          }

          final doc = snapshot.data;
          final data = doc?.data();
          if (doc == null || data == null) {
            return const _MessageState(message: 'No order found to track.');
          }

          final status = (data['status'] ?? 'Processing').toString();
          final currentStep = (data['trackingStep'] as num?)?.toInt() ??
              _statusToStep(status);
          final steps = _stepsFromData(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _OrderCard(orderId: doc.id, data: data),
                const SizedBox(height: 16),
                _LiveBanner(
                  pulseCtrl: _pulseCtrl,
                  title: (data['estimatedDelivery'] ??
                          'Your order is being processed')
                      .toString(),
                  subtitle: (data['trackingLabel'] ?? status).toString(),
                ),
                const SizedBox(height: 16),
                _TimelineCard(steps: steps, currentStep: currentStep),
                const SizedBox(height: 16),
                _DeliveryPartnerCard(data: data['deliveryPartner']),
                const SizedBox(height: 16),
                _StatusHelpCard(orderId: doc.id, status: status),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_TrackStep> _stepsFromData(Map<String, dynamic> data) {
    final history = data['trackingHistory'];
    if (history is List && history.isNotEmpty) {
      final icons = [
        Icons.check_circle_outline_rounded,
        Icons.inventory_2_outlined,
        Icons.local_shipping_outlined,
        Icons.delivery_dining_rounded,
        Icons.home_rounded,
      ];

      return history.asMap().entries.map((entry) {
        final value = entry.value is Map
            ? Map<String, dynamic>.from(entry.value as Map)
            : <String, dynamic>{};
        return _TrackStep(
          icon: icons[entry.key.clamp(0, icons.length - 1)],
          title: (value['title'] ?? 'Tracking update').toString(),
          subtitle: (value['subtitle'] ?? '').toString(),
          time: _formatTime(value['time']),
        );
      }).toList();
    }

    return const [
      _TrackStep(
        icon: Icons.check_circle_outline_rounded,
        title: 'Order Placed',
        subtitle: 'Your order has been confirmed',
        time: 'Now',
      ),
      _TrackStep(
        icon: Icons.inventory_2_outlined,
        title: 'Order Packed',
        subtitle: 'Seller will pack your order soon',
        time: '-',
      ),
      _TrackStep(
        icon: Icons.local_shipping_outlined,
        title: 'Shipped',
        subtitle: 'Waiting for courier pickup',
        time: '-',
      ),
      _TrackStep(
        icon: Icons.delivery_dining_rounded,
        title: 'Out for Delivery',
        subtitle: 'Your delivery partner is on the way',
        time: '-',
      ),
      _TrackStep(
        icon: Icons.home_rounded,
        title: 'Delivered',
        subtitle: 'Package handed over',
        time: '-',
      ),
    ];
  }

  static int _statusToStep(String status) {
    switch (status.toLowerCase()) {
      case 'packed':
        return 1;
      case 'shipped':
        return 2;
      case 'out for delivery':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }

  static String _formatTime(dynamic value) {
    if (value == null) return '-';
    if (value is Timestamp) {
      final date = value.toDate();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day}/${date.month}/${date.year} $hour:$minute';
    }
    return value.toString();
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const _OrderCard({required this.orderId, required this.data});

  @override
  Widget build(BuildContext context) {
    final items = data['items'] is List ? data['items'] as List : const [];
    final firstItem = items.isNotEmpty && items.first is Map
        ? Map<String, dynamic>.from(items.first as Map)
        : <String, dynamic>{};
    final total = (data['total'] as num?)?.toDouble() ?? 0;
    final status = (data['status'] ?? 'Processing').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: Color(0xFF5C6BC0), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (firstItem['name'] ?? 'FRD Fashion Order').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${items.length} item${items.length == 1 ? '' : 's'} - ${PriceUtils.format(total)} - #${orderId.toUpperCase()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Color(0xFFF9A825),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBanner extends StatelessWidget {
  final AnimationController pulseCtrl;
  final String title;
  final String subtitle;

  const _LiveBanner({
    required this.pulseCtrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFEF5350)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
                color: Colors.white.withValues(
                  alpha: 0.5 + pulseCtrl.value * 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.access_time_rounded,
              color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final List<_TrackStep> steps;
  final int currentStep;

  const _TimelineCard({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded,
                  color: Color(0xFF5C6BC0), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tracking Status',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...steps.asMap().entries.map(
                (entry) => _TrackTile(
                  step: entry.value,
                  index: entry.key,
                  currentStep: currentStep,
                  isLast: entry.key == steps.length - 1,
                ),
              ),
        ],
      ),
    );
  }
}

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
    final isDone = index < currentStep;
    final isActive = index == currentStep;
    final isPending = index > currentStep;
    final iconColor = isDone
        ? const Color(0xFF43A047)
        : isActive
            ? const Color(0xFF5C6BC0)
            : const Color(0xFFBDBDBD);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFFE8F5E9)
                      : isActive
                          ? const Color(0xFFE8EAF6)
                          : const Color(0xFFF5F5F5),
                  border: Border.all(color: iconColor, width: 1.5),
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : step.icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 42,
                  color: isDone
                      ? const Color(0xFF43A047)
                      : const Color(0xFFE0E0E0),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isPending
                        ? const Color(0xFFBDBDBD)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPending
                        ? const Color(0xFFDDDDDD)
                        : const Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? const Color(0xFF5C6BC0)
                        : const Color(0xFF9E9E9E),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeliveryPartnerCard extends StatelessWidget {
  final dynamic data;

  const _DeliveryPartnerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final partner =
        data is Map ? Map<String, dynamic>.from(data as Map) : <String, dynamic>{};
    final name = (partner['name'] ?? 'FRD Express').toString();
    final rating = (partner['rating'] ?? 4.8).toString();
    final phone = (partner['phone'] ?? '+94 112 345 678').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE8EAF6),
            child: Icon(Icons.person_rounded,
                color: Color(0xFF5C6BC0), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFC107), size: 15),
                    const SizedBox(width: 3),
                    Text(
                      '$rating - Delivery Partner',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Tooltip(
            message: phone,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.call_rounded,
                  color: Color(0xFF43A047), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHelpCard extends StatelessWidget {
  final String orderId;
  final String status;

  const _StatusHelpCard({required this.orderId, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF5C6BC0)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Order #${orderId.toUpperCase()} is currently $status.',
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;

  const _MessageState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFE53935)),
        ),
      ),
    );
  }
}

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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
