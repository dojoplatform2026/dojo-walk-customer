import 'package:flutter/material.dart';

import '../../app/theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Firebase OTP verification will be connected next.

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'OTP verification will be connected with Firebase next.',
        ),
      ),
    );
  }

  void _resendOtp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resend will be connected next.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Verify Mobile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: DojoWalkTheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sms_outlined,
                      color: DojoWalkTheme.primary,
                      size: 38,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    'Verify your number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'We sent a 6-digit verification code to\n${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    hintText: '••••••',
                    counterText: '',
                  ),
                  validator: (value) {
                    final otp = value?.trim() ?? '';

                    if (otp.isEmpty) {
                      return 'Please enter the OTP';
                    }

                    if (otp.length != 6) {
                      return 'OTP must be 6 digits';
                    }

                    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
                      return 'Please enter a valid OTP';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) => _verifyOtp(),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    child: _isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Verify & Continue'),
                  ),
                ),

                const SizedBox(height: 22),

                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: DojoWalkTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text(
                      'Change mobile number',
                      style: TextStyle(
                        color: DojoWalkTheme.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
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
