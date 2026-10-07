import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class ChangeMobileScreen extends StatefulWidget {
  const ChangeMobileScreen({super.key});

  @override
  State<ChangeMobileScreen> createState() =>
      _ChangeMobileScreenState();
}

class _ChangeMobileScreenState
    extends State<ChangeMobileScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;

  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _phoneNumber {
    return '+91${_phoneController.text.trim()}';
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      _showMessage(
        'Please enter a valid 10-digit mobile number.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted:
            (PhoneAuthCredential credential) async {
          await _updatePhoneNumber(credential);
        },
        verificationFailed:
            (FirebaseAuthException error) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          _showMessage(
            _firebaseErrorMessage(error),
          );
        },
        codeSent:
            (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
          });

          _showMessage(
            'OTP sent to $_phoneNumber',
          );
        },
        codeAutoRetrievalTimeout:
            (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Could not send OTP. Please try again.',
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6 ||
        !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      _showMessage('Please enter a valid 6-digit OTP.');
      return;
    }

    if (_verificationId == null) {
      _showMessage(
        'OTP session expired. Please request a new OTP.',
      );
      return;
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    await _updatePhoneNumber(credential);
  }

  Future<void> _updatePhoneNumber(
    PhoneAuthCredential credential,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Your login session has expired. Please login again.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await user.updatePhoneNumber(credential);

      await user.reload();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Number Updated',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              'Your mobile number has been changed to $_phoneNumber.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        _firebaseErrorMessage(error),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Could not update your mobile number. Please try again.',
      );
    }
  }

  String _firebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid mobile number.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'quota-exceeded':
        return 'SMS limit reached. Please try again later.';

      case 'invalid-verification-code':
        return 'Incorrect OTP. Please check and try again.';

      case 'session-expired':
        return 'OTP expired. Please request a new OTP.';

      case 'credential-already-in-use':
        return 'This mobile number is already linked to another account.';

      case 'provider-already-linked':
        return 'This mobile number is already linked.';

      case 'requires-recent-login':
        return 'For security, please login again before changing your number.';

      case 'network-request-failed':
        return 'No internet connection. Please try again.';

      default:
        return error.message ??
            'Something went wrong. Please try again.';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

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
        title: const Text('Change Mobile Number'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    color: DojoWalkTheme.primary,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'Change your number',
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
                  'Enter your new mobile number.\nWe will send an OTP to verify it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'New mobile number',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: _phoneController,
                enabled: !_otpSent && !_isLoading,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  prefixText: '+91 ',
                  hintText: '9876543210',
                  counterText: '',
                ),
              ),

              if (_otpSent) ...[
                const SizedBox(height: 24),

                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                TextField(
                  controller: _otpController,
                  enabled: !_isLoading,
                  keyboardType:
                      TextInputType.number,
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
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _otpSent
                          ? _verifyOtp
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
                      : Text(
                          _otpSent
                              ? 'Verify & Change Number'
                              : 'Send OTP',
                        ),
                ),
              ),

              if (_otpSent) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _otpSent = false;
                              _verificationId = null;
                              _otpController.clear();
                            });
                          },
                    child: const Text(
                      'Change number',
                      style: TextStyle(
                        color: DojoWalkTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
