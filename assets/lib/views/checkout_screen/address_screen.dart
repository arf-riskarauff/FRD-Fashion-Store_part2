import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// FRD Fashion Store – Address Change / Management Screen
// ─────────────────────────────────────────────

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() {
    return _AddressScreenState();
  }
}

class _AddressScreenState extends State<AddressScreen> {
  int _defaultIndex = 0;

  final List<Map<String, dynamic>> _addresses = [
    {
      'tag': 'Home',
      'icon': Icons.home_rounded,
      'name': 'Arjun Kumar',
      'line1': '42, Anna Nagar Main Road',
      'line2': 'Near Reliance Fresh',
      'city': 'Chennai',
      'state': 'Tamil Naadu',
      'pin': '600040',
      'phone': '+91 98765 43210',
    },
    {
      'tag': 'Work',
      'icon': Icons.business_center_rounded,
      'name': 'Arjun Kumar',
      'line1': 'Floor 3, Tech Park Tower B',
      'line2': 'Tidel Park, Taramani',
      'city': 'Chennai',
      'state': 'Tamil Nadu',
      'pin': '600113',
      'phone': '+91 98765 43210',
    },
  ];

  void _showAddressForm({int? editIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _AddressFormSheet(
          initial: editIndex != null ? _addresses[editIndex] : null,
          onSave: (data) {
            setState(() {
              if (editIndex != null) {
                _addresses[editIndex] = data;
              } else {
                _addresses.add(data);
              }
            });
          },
        );
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
          'Delivery Addresses',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _showAddressForm(),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._addresses.asMap().entries.map((e) {
            return _AddressTile(
              address: e.value,
              isDefault: _defaultIndex == e.key,
              onSelect: () {
                setState(() {
                  _defaultIndex = e.key;
                });
              },
              onEdit: () => _showAddressForm(editIndex: e.key),
              onDelete: () {
                setState(() {
                  _addresses.removeAt(e.key);
                  if (_defaultIndex >= _addresses.length) {
                    _defaultIndex = 0;
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }
}

// ───────────────── ADDRESS TILE ─────────────────
class _AddressTile extends StatelessWidget {
  final Map<String, dynamic> address;
  final bool isDefault;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressTile({
    required this.address,
    required this.isDefault,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDefault
                ? const Color(0xFFE53935)
                : const Color(0xFFEEEEEE),
            width: isDefault ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${address['line1']}, ${address['line2']}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              '${address['city']}, ${address['state']} - ${address['pin']}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                TextButton(
                    onPressed: onDelete,
                    child: const Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── ADDRESS FORM SHEET ─────────────────
class _AddressFormSheet extends StatefulWidget {
  final Map<String, dynamic>? initial;
  final Function(Map<String, dynamic>) onSave;

  const _AddressFormSheet({this.initial, required this.onSave});

  @override
  State<_AddressFormSheet> createState() {
    return _AddressFormSheetState();
  }
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _tag = 'Home';

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final a = widget.initial!;
      _nameCtrl.text = a['name'];
      _line1Ctrl.text = a['line1'];
      _line2Ctrl.text = a['line2'];
      _cityCtrl.text = a['city'];
      _stateCtrl.text = a['state'];
      _pinCtrl.text = a['pin'];
      _phoneCtrl.text = a['phone'];
      _tag = a['tag'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCtrl.dispose();
    _phoneCtrl.dispose();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            _field('Name', _nameCtrl),
            const SizedBox(height: 10),
            _field('Phone', _phoneCtrl),
            const SizedBox(height: 10),
            _field('Address Line 1', _line1Ctrl),
            const SizedBox(height: 10),
            _field('Address Line 2', _line2Ctrl),
            const SizedBox(height: 10),
            _field('City', _cityCtrl),
            const SizedBox(height: 10),
            _field('State', _stateCtrl),
            const SizedBox(height: 10),
            _field('PIN', _pinCtrl),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSave({
                    'tag': _tag,
                    'icon': Icons.home,
                    'name': _nameCtrl.text,
                    'line1': _line1Ctrl.text,
                    'line2': _line2Ctrl.text,
                    'city': _cityCtrl.text,
                    'state': _stateCtrl.text,
                    'pin': _pinCtrl.text,
                    'phone': _phoneCtrl.text,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Address'),
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
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }
}
