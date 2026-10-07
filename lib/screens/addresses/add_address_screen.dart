import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/pickup_address_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() =>
      _AddAddressScreenState();
}

class _AddAddressScreenState
    extends State<AddAddressScreen> {
  final PickupAddressService _addressService =
      PickupAddressService();

  final _formKey = GlobalKey<FormState>();

  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _addressService.addAddress(
        label: _labelController.text,
        address: _addressController.text,
        city: _cityController.text,
        pincode: _pincodeController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save address: $e',
          ),
        ),
      );

      setState(() {
        _saving = false;
      });
    }
  }

  String? _required(String? value, String name) {
    if (value == null || value.trim().isEmpty) {
      return '$name is required.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Add Address'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              24,
            ),
            children: [
              const Text(
                'Where should we\npick up your dog?',
                style: TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Save your pickup location for an easy booking.',
                style: TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _labelController,
                textCapitalization:
                    TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Address Label',
                  hintText: 'Home, Office, etc.',
                  prefixIcon: Icon(
                    Icons.bookmark_outline_rounded,
                  ),
                ),
                validator: (value) =>
                    _required(value, 'Address label'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                textCapitalization:
                    TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Full Address',
                  hintText:
                      'House no., street, area',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      bottom: 45,
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                    ),
                  ),
                ),
                validator: (value) =>
                    _required(value, 'Address'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cityController,
                textCapitalization:
                    TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'City',
                  prefixIcon: Icon(
                    Icons.location_city_outlined,
                  ),
                ),
                validator: (value) =>
                    _required(value, 'City'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Pincode',
                  hintText: '6 digit pincode',
                  prefixIcon: Icon(
                    Icons.pin_drop_outlined,
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Pincode is required.';
                  }

                  if (value.trim().length != 6) {
                    return 'Enter a valid 6 digit pincode.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _saving ? null : _saveAddress,
                  child: _saving
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
