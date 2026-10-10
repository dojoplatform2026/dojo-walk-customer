
import 'package:flutter/material.dart';

import 'booking_start_screen.dart';

const Color dogDetailsOrange = Color(0xFFFF7900);

class DogDetailsScreen extends StatefulWidget {
  const DogDetailsScreen({
    super.key,
    required this.walkType,
  });

  final WalkBookingType walkType;

  @override
  State<DogDetailsScreen> createState() => _DogDetailsScreenState();
}

class _DogDetailsScreenState extends State<DogDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();

  String _size = 'Medium';
  String _gender = 'Not specified';

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final dogDetails = <String, dynamic>{
      'name': _nameController.text.trim(),
      'breed': _breedController.text.trim(),
      'age': _ageController.text.trim(),
      'size': _size,
      'gender': _gender,
      'notes': _notesController.text.trim(),
    };

    // Temporary: the pickup-address screen will be connected next.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DogDetailsReviewScreen(
          walkType: widget.walkType,
          dogDetails: dogDetails,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAF5),
        title: const Text(
          'Your Dog',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const Text(
                'Tell us about your dog',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF202020),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'These details help the walker provide suitable care.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: dogDetailsOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: dogDetailsOrange,
                    size: 43,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _label('Dog’s name *'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('e.g. Bruno'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your dog’s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _label('Breed'),
              TextFormField(
                controller: _breedController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('e.g. Labrador'),
              ),
              const SizedBox(height: 18),
              _label('Age'),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: _decoration('Age in years'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;

                  final age = int.tryParse(text);
                  if (age == null || age < 0 || age > 40) {
                    return 'Enter a valid age in years';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _label('Dog size *'),
              DropdownButtonFormField<String>(
                value: _size,
                decoration: _decoration('Select size'),
                items: const [
                  DropdownMenuItem(
                    value: 'Small',
                    child: Text('Small'),
                  ),
                  DropdownMenuItem(
                    value: 'Medium',
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 'Large',
                    child: Text('Large'),
                  ),
                  DropdownMenuItem(
                    value: 'Extra Large',
                    child: Text('Extra Large'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _size = value);
                },
              ),
              const SizedBox(height: 18),
              _label('Gender'),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: _decoration('Select gender'),
                items: const [
                  DropdownMenuItem(
                    value: 'Not specified',
                    child: Text('Prefer not to specify'),
                  ),
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 18),
              _label('Special instructions (optional)'),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 300,
                decoration: _decoration(
                  'Behaviour, walking needs, or other care notes',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dogDetailsOrange,
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
                        'Continue to Pickup Address',
                        style: TextStyle(
                          fontSize: 15,
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF303030),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: dogDetailsOrange,
          width: 1.5,
        ),
      ),
    );
  }
}

// Temporary review screen so this step works before Pickup Address is built.
class DogDetailsReviewScreen extends StatelessWidget {
  const DogDetailsReviewScreen({
    super.key,
    required this.walkType,
    required this.dogDetails,
  });

  final WalkBookingType walkType;
  final Map<String, dynamic> dogDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dog Details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details added for this booking',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            ...dogDetails.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Text(
                  '${entry.key}: ${entry.value.toString().isEmpty ? "Not provided" : entry.value}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Walk type: ${walkType == WalkBookingType.regular ? "Regular Walk" : "One-Time Walk"}',
            ),
            const SizedBox(height: 16),
            const Text(
              'Next, we will connect this step to the Pickup Address screen.',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Edit Dog Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
