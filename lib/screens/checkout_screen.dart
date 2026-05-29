import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/price_utils.dart';
import 'cart_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<DemoCartItem> cartItems;
  final double total;
  final double subtotal;
  final double shipping;
  final double discount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.total,
    required this.subtotal,
    required this.shipping,
    required this.discount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedPayment = 'Credit Card';
  bool _saveAddress = true;

  final _nameCtrl = TextEditingController(text: 'John Doe');
  final _phoneCtrl = TextEditingController(text: '+1 234 567 8900');
  final _addressCtrl = TextEditingController(text: '123 Fashion Street');
  final _cityCtrl = TextEditingController(text: 'New York');
  final _zipCtrl = TextEditingController(text: '10001');
  final _cardNumCtrl = TextEditingController(text: '**** **** **** 4242');
  final _expiryCtrl = TextEditingController(text: '12/26');
  final _cvvCtrl = TextEditingController(text: '***');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _cardNumCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Shipping', 'Payment', 'Review'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < _currentStep
                    ? AppColors.accent
                    : Colors.grey.shade300,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final done = stepIndex < _currentStep;
          final active = stepIndex == _currentStep;
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: done || active
                      ? AppColors.accent
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: active ? Colors.white : AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  color: active ? AppColors.accent : AppColors.textGrey,
                  fontWeight:
                      active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildShippingStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildShippingStep() {
    return Column(
      key: const ValueKey('shipping'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Delivery Address'),
        _inputField('Full Name', _nameCtrl, Icons.person_outline),
        _inputField('Phone', _phoneCtrl, Icons.phone_outlined,
            keyboardType: TextInputType.phone),
        _inputField('Address', _addressCtrl, Icons.home_outlined),
        Row(
          children: [
            Expanded(
                child: _inputField('City', _cityCtrl, Icons.location_city)),
            const SizedBox(width: 12),
            Expanded(
                child: _inputField('ZIP', _zipCtrl, Icons.markunread_mailbox_outlined,
                    keyboardType: TextInputType.number)),
          ],
        ),
        CheckboxListTile(
          value: _saveAddress,
          onChanged: (v) => setState(() => _saveAddress = v!),
          title: const Text('Save this address',
              style: TextStyle(fontSize: 14)),
          activeColor: AppColors.accent,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        _sectionTitle('Delivery Method'),
        _deliveryOption('Standard', '5-7 Business Days', 'LKR 1,800'),
        _deliveryOption('Express', '2-3 Business Days', 'LKR 3,900'),
        _deliveryOption('Overnight', 'Next Business Day', 'LKR 7,500'),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final paymentMethods = [
      {'label': 'Credit Card', 'icon': Icons.credit_card},
      {'label': 'PayPal', 'icon': Icons.paypal},
      {'label': 'Cash on Delivery', 'icon': Icons.money},
    ];
    return Column(
      key: const ValueKey('payment'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Payment Method'),
        ...paymentMethods.map((m) => GestureDetector(
              onTap: () =>
                  setState(() => _selectedPayment = m['label'] as String),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedPayment == m['label']
                      // ignore: deprecated_member_use
                      ? AppColors.accent.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedPayment == m['label']
                        ? AppColors.accent
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(m['icon'] as IconData,
                        color: _selectedPayment == m['label']
                            ? AppColors.accent
                            : AppColors.textGrey),
                    const SizedBox(width: 12),
                    Text(m['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _selectedPayment == m['label']
                              ? AppColors.accent
                              : AppColors.textDark,
                        )),
                    const Spacer(),
                    if (_selectedPayment == m['label'])
                      const Icon(Icons.check_circle,
                          color: AppColors.accent, size: 20),
                  ],
                ),
              ),
            )),
        if (_selectedPayment == 'Credit Card') ...[
          const SizedBox(height: 8),
          _sectionTitle('Card Details'),
          _inputField('Card Number', _cardNumCtrl, Icons.credit_card,
              keyboardType: TextInputType.number),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      'Expiry (MM/YY)', _expiryCtrl, Icons.date_range)),
              const SizedBox(width: 12),
              Expanded(
                  child: _inputField('CVV', _cvvCtrl, Icons.lock_outline,
                      keyboardType: TextInputType.number)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      key: const ValueKey('review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Order Summary'),
        ...widget.cartItems.map((item) => _reviewItem(
              item.image,
              item.title,
              '${item.size} / ${item.color}',
              PriceUtils.format(item.price * item.qty),
              'x${item.qty}',
            )),
        const SizedBox(height: 16),
        _sectionTitle('Shipping Address'),
        _infoCard([
          '${_nameCtrl.text}  •  ${_phoneCtrl.text}',
          _addressCtrl.text,
          '${_cityCtrl.text}, ${_zipCtrl.text}',
        ], Icons.location_on_outlined),
        const SizedBox(height: 12),
        _sectionTitle('Payment'),
        _infoCard([
          _selectedPayment,
          if (_selectedPayment == 'Credit Card') _cardNumCtrl.text,
        ], Icons.payment),
        const SizedBox(height: 12),
        _sectionTitle('Price Details'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _priceLine('Subtotal', PriceUtils.format(widget.subtotal)),
              _priceLine('Shipping', PriceUtils.format(widget.shipping)),
              _priceLine('Discount', '-${PriceUtils.format(widget.discount)}'),
              const Divider(height: 20),
              _priceLine('Total', PriceUtils.format(widget.total),
                  bold: true, color: AppColors.accent),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.accent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        ),
      ),
    );
  }

  Widget _deliveryOption(String name, String duration, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(duration,
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Text(price,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _reviewItem(String image, String title, String variant, String price,
      String qty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(variant,
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent)),
              Text(qty,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<String> lines, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines
                .map((l) => Text(l,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textDark)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _priceLine(String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? AppColors.textDark : AppColors.textGrey,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: color ?? AppColors.textDark,
                  fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentStep == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Back',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (isLast) {
                  _showOrderSuccess();
                } else {
                  setState(() => _currentStep++);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                isLast ? 'Place Order' : 'Continue',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Colors.green, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('Order Placed!',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Your order has been placed successfully. You will receive a confirmation soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop()
                    ..pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
