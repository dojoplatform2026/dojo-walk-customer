import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../profile/name_setup_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  final String phoneNumber;
  final String verificationId;

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _otpController =
      TextEditingController();

  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showMessage('Please enter the 6-digit OTP.');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await _authService.verifyOtp(
        verificationId: widget.verificationId,
        otp: otp,
      );

      if (!mounted) return;

      await _handleUserProfile();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message =
          'Invalid OTP. Please try again.';

      if (e.code == 'invalid-verification-code') {
        message = 'The OTP is incorrect.';
      } else if (e.code == 'session-expired') {
        message =
            'This OTP has expired. Please request a new one.';
      } else if (e.code == 'network-request-failed') {
        message =
            'No internet connection. Please try again.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _handleUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please login again.');
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    final data = userDoc.data();

    final name = data?['name'];

    final hasName = name is String &&
        name.trim().isNotEmpty;

    if (hasName) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NameSetupScreen(),
        ),
      );

      if (!mounted) return;

      if (result != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
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
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                'Enter verification code',
                style: TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'We sent a 6-digit OTP to ${widget.phoneNumber}.',
                style: const TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textInputAction:
                    TextInputAction.done,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                ),
                onSubmitted: (_) {
                  if (!_isVerifying) {
                    _verifyOtp();
                  }
                },
                decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '',
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying
                      ? null
                      : _verifyOtp,
                  child: _isVerifying
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
                          'Verify & Continue',
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
