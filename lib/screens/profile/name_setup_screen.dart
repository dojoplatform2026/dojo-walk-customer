import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class NameSetupScreen extends StatefulWidget {
  const NameSetupScreen({super.key});

  @override
  State<NameSetupScreen> createState() => _NameSetupScreenState();
}

class _NameSetupScreenState extends State<NameSetupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your name.');
      return;
    }

    if (name.length < 2) {
      _showMessage('Please enter a valid name.');
      return;
    }

    final age = int.tryParse(ageText);

    if (age == null) {
      _showMessage('Please enter your age.');
      return;
    }

    if (age < 18) {
      _showMessage(
        'You must be 18 or older to use DOJO WALK.',
      );
      return;
    }

    if (age > 100) {
      _showMessage('Please enter a valid age.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please login again.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final existingUser = await userRef.get();

      final data = <String, dynamic>{
        'name': name,
        'age': age,
        'phoneNumber': user.phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!existingUser.exists) {
        data['createdAt'] =
            FieldValue.serverTimestamp();
      }

      await userRef.set(
        data,
        SetOptions(merge: true),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not save your profile. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Spacer(),

              Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: DojoWalkTheme.primary,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Welcome to DOJO WALK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Let’s get to know you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 34),

              const Text(
                'Your name',
                style: TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _nameController,
                textCapitalization:
                    TextCapitalization.words,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Your age',
                style: TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                textInputAction:
                    TextInputAction.done,
                maxLength: 3,
                onSubmitted: (_) {
                  if (!_isSaving) {
                    _saveProfile();
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your age',
                  prefixIcon: Icon(
                    Icons.cake_outlined,
                  ),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'You must be 18 or older to continue.',
                style: TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 12,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
