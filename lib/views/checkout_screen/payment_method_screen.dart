import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firestore_service.dart';

// ─────────────────────────────────────────────
//  FRD Fashion Store – Payment Method Screen
// ─────────────────────────────────────────────

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() {
    return _PaymentMethodScreenState();
  }
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _savedCards = [
    {
      'type': 'VISA',
      'number': '**** **** **** 4242',
      'holder': 'Arjun Kumar',
      'expiry': '08/27',
      'color': const Color(0xFF1A237E),
    },
    {
      'type': 'MASTERCARD',
      'number': '**** **** **** 5353',
      'holder': 'Arjun Kumar',
      'expiry': '12/26',
      'color': const Color(0xFF880E4F),
    },
  ];

  final List<Map<String, String>> _otherMethods = [
    {'icon': 'upi', 'label': 'UPI', 'sub': 'Pay via UPI ID or QR'},
    {'icon': 'bank', 'label': 'Net Banking', 'sub': 'All major banks'},
    {'icon': 'cod', 'label': 'Cash on Delivery', 'sub': 'Pay when you receive'},
  ];

  void _showAddCardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _AddCardSheet();
      },
    );
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
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _showAddCardSheet,
            child: const Text(
              '+ Add',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.paymentMethodsStream(),
        builder: (context, snapshot) {
          final remoteCards = snapshot.data?.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'type': (data['type'] ?? data['label'] ?? 'CARD').toString(),
                  'number':
                      (data['number'] ?? data['label'] ?? data['type'] ?? '')
                          .toString(),
                  'holder': (data['holder'] ?? 'Saved method').toString(),
                  'expiry': (data['expiry'] ?? '').toString(),
                  'color': const Color(0xFF1A237E),
                };
              }).toList() ??
              [];
          final savedCards = remoteCards.isEmpty ? _savedCards : remoteCards;

          if (_selectedIndex >= savedCards.length + _otherMethods.length) {
            _selectedIndex = 0;
          }

          return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('Saved Cards'),
            const SizedBox(height: 12),

            // Saved cards
            ...savedCards.asMap().entries.map((e) {
              return _CardTile(
                card: e.value,
                isSelected: _selectedIndex == e.key,
                onTap: () {
                  setState(() {
                    _selectedIndex = e.key;
                  });
                },
                onDelete: () async {
                  final id = e.value['id'];
                  if (id is String) {
                    await FirestoreService.deletePaymentMethod(id);
                  } else {
                    setState(() {
                      _savedCards.removeAt(e.key);
                      _selectedIndex = 0;
                    });
                  }
                },
              );
            }),

            const SizedBox(height: 24),
            const _SectionLabel('Other Payment Methods'),
            const SizedBox(height: 12),

            // Other methods
            ..._otherMethods.asMap().entries.map((e) {
              return _OtherMethodTile(
                method: e.value,
                isSelected:
                    _selectedIndex == savedCards.length + e.key,
                onTap: () {
                  setState(() {
                    _selectedIndex =
                        savedCards.length + e.key;
                  });
                },
              );
            }),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final selectedPayment = _selectedIndex < savedCards.length
                      ? savedCards[_selectedIndex]
                      : _otherMethods[_selectedIndex - savedCards.length];
                  try {
                    await FirestoreService.savePaymentMethod({
                      'type': selectedPayment['type'] ?? selectedPayment['label'],
                      'label': selectedPayment['label'] ?? selectedPayment['type'],
                      'number': selectedPayment['number'],
                      'holder': selectedPayment['holder'],
                      'expiry': selectedPayment['expiry'],
                    });
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFFE53935),
                      ),
                    );
                    return;
                  }
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment method saved!'),
                      backgroundColor:
                          Color(0xFF43A047),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Confirm Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }
}

// ───────────────── CARD TILE ─────────────────
class _CardTile extends StatelessWidget {
  final Map<String, dynamic> card;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardTile({
    required this.card,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = card['color'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor,
              baseColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card['type'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: Colors.white),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              card['number'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card['holder'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  card['expiry'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── OTHER METHOD TILE ─────────────────
class _OtherMethodTile extends StatelessWidget {
  final Map<String, String> method;
  final bool isSelected;
  final VoidCallback onTap;

  const _OtherMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (method['icon']) {
      case 'upi':
        return Icons.account_balance_wallet_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFFFEBEE) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE53935)
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Icon(_icon,
                color: isSelected
                    ? const Color(0xFFE53935)
                    : const Color(0xFF757575)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['label']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFE53935)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    method['sub']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFFE53935)
                  : const Color(0xFFBDBDBD),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── ADD CARD SHEET ─────────────────
class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() {
    return _AddCardSheetState();
  }
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            _field('Card Number', _numberCtrl),
            const SizedBox(height: 14),
            _field('Card Holder Name', _nameCtrl),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _field('Expiry', _expiryCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field('CVV', _cvvCtrl)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await FirestoreService.savePaymentMethod({
                      'type': 'CARD',
                      'number': _maskedNumber(_numberCtrl.text),
                      'holder': _nameCtrl.text.trim(),
                      'expiry': _expiryCtrl.text.trim(),
                    });
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFFE53935),
                      ),
                    );
                    return;
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          v == null || v.isEmpty ? 'Required' : null,
    );
  }

  String _maskedNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '****';
    return '**** **** **** ${digits.substring(digits.length - 4)}';
  }
}

// ───────────────── SECTION LABEL ─────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Color(0xFF9E9E9E),
      ),
    );
  }
}
