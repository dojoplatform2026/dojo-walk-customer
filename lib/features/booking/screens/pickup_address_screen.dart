
import 'package:flutter/material.dart';

import 'booking_start_screen.dart';
import 'walk_schedule_screen.dart';

const Color addressOrange = Color(0xFFFF7900);
const Color addressText = Color(0xFF202020);
const Color addressBackground = Color(0xFFFFFAF5);

class PickupAddressScreen extends StatefulWidget {
  const PickupAddressScreen({
    super.key,
    required this.walkType,
    required this.dogDetails,
  });

  final WalkBookingType walkType;
  final Map<String, dynamic> dogDetails;

  @override
  State<PickupAddressScreen> createState() =>
      _PickupAddressScreenState();
}

class _PickupAddressScreenState extends State<PickupAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController(text: 'Jaipur');
  final _pincodeController = TextEditingController();

  String _addressType = 'Home';

  @override
  void dispose() {
    _addressController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final pickupAddress = <String, dynamic>{
      'label': _addressType,
      'address': _addressController.text.trim(),
      'area': _areaController.text.trim(),
      'landmark': _landmarkController.text.trim(),
      'city': _cityController.text.trim(),
      'pincode': _pincodeController.text.trim(),
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkScheduleScreen(
          walkType: widget.walkType,
          dogDetails: widget.dogDetails,
          pickupAddress: pickupAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: addressBackground,
      appBar: AppBar(
        backgroundColor: addressBackground,
        elevation: 0,
        title: const Text(
          'Pickup Address',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: addressText,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const Text(
                'Where should we pick up your dog?',
                style: TextStyle(
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  color: addressText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add the location where your walker should arrive.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: addressOrange,
                      size: 30,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Accurate pickup details help your walker find you.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Save address as',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: ['Home', 'Work', 'Other'].map((type) {
                  final selected = _addressType == type;

                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    selectedColor:
                        addressOrange.withValues(alpha: 0.15),
                    checkmarkColor: addressOrange,
                    onSelected: (_) {
                      setState(() => _addressType = type);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              _fieldLabel('House / Flat / Building *'),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _decoration('House number and street'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your house or street address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              _fieldLabel('Area / Locality *'),
              TextFormField(
                controller: _areaController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _decoration('Enter your area or locality'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your area';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              _fieldLabel('Landmark (optional)'),
              TextFormField(
                controller: _landmarkController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _decoration('Nearby landmark'),
              ),

              const SizedBox(height: 18),

              _fieldLabel('City *'),
              TextFormField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _decoration('Enter city'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              _fieldLabel('PIN code *'),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textInputAction: TextInputAction.done,
                decoration: _decoration('6-digit PIN code'),
                validator: (value) {
                  final pin = value?.trim() ?? '';

                  if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
                    return 'Enter a valid 6-digit PIN code';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: addressOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: addressText,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      counterText: '',
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE7E7E7),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE7E7E7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: addressOrange,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }
}
