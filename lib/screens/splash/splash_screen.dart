import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 2),
      _checkAuth,
    );
  }

  void _checkAuth() {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    final nextScreen = user != null
        ? const HomeScreen()
        : const OnboardingScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => nextScreen,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: DojoWalkTheme.primary,
                  borderRadius:
                      BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: DojoWalkTheme.primary
                          .withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'DOJO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'DOJO WALK',
                style: TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Happy walks. Happy dogs.',
                style: TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 42),

              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: DojoWalkTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
