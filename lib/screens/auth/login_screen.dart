import 'package:flutter/material.dart';

import '../../app/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Firebase Phone OTP will be connected next.

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'OTP system will be connected with Firebase next.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            30,
            24,
            24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 38),

                const Text(
                  'Welcome back 👋',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Sign in with your mobile number to book a happy walk for your dog.',
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 34),

                const Text(
                  'Mobile number',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _sendOtp(),
                  decoration: const InputDecoration(
                    hintText: 'Enter your mobile number',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                    prefixText: '+91 ',
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'Please enter your mobile number';
                    }

                    final digits = phone.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );

                    if (digits.length != 10) {
                      return 'Please enter a valid 10-digit number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  'We will send a 6-digit OTP to this number.',
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _sendOtp,
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
                        : const Text('Send OTP'),
                  ),
                ),

                const SizedBox(height: 32),

                Center(
                  child: Text(
                    'By continuing, you agree to DOJO WALK Terms & Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      height: 1.5,
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
