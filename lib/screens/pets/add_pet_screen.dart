import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/pet_service.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  final PetService _petService = PetService();

  String _gender = 'Male';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _petService.addPet(
        name: _nameController.text,
        breed: _breedController.text,
        age: int.parse(_ageController.text.trim()),
        gender: _gender,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save pet: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Add Pet'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            28,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: DojoWalkTheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: DojoWalkTheme.primary,
                      size: 44,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Tell us about your dog',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Add your pet details so we can provide a better walking experience.',
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Pet name',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Bruno',
                    prefixIcon: Icon(
                      Icons.pets_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your pet name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const Text(
                  'Breed',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _breedController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Golden Retriever',
                    prefixIcon: Icon(
                      Icons.category_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the breed';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const Text(
                  'Age',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Age in years',
                    prefixIcon: Icon(
                      Icons.cake_outlined,
                    ),
                  ),
                  validator: (value) {
                    final age = int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (age == null) {
                      return 'Please enter a valid age';
                    }

                    if (age < 0 || age > 30) {
                      return 'Please enter an age between 0 and 30';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const Text(
                  'Gender',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.pets_outlined,
                    ),
                  ),
                  items: const [
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
                    if (value == null) return;

                    setState(() {
                      _gender = value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _savePet,
                    child: _isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Pet',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Ab Add Pet → Firebase Firestore save ho jayega.

Next mein "Select Pet" screen ko real Firebase pets + Add New Pet button se connect karenge.
