import 'package:flutter/material.dart';

import '../../app/theme.dart';

class FindingWalkerScreen extends StatefulWidget {
  const FindingWalkerScreen({
    super.key,
    required this.bookingId,
    required this.immediate,
  });

  final String bookingId;
  final bool immediate;

  @override
  State<FindingWalkerScreen> createState() =>
      _FindingWalkerScreenState();
}

class _FindingWalkerScreenState
    extends State<FindingWalkerScreen> {
  @override
  void initState() {
    super.initState();

    _startSearching();
  }

  Future<void> _startSearching() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Walker assignment will be connected later.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),

                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        color: DojoWalkTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Finding a walker',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  widget.immediate
                      ? 'We are looking for a nearby walker for your dog.'
                      : 'Your walk is booked. We will assign a walker closer to the scheduled time.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: DojoWalkTheme.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: DojoWalkTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Booking ID: ${widget.bookingId}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                const Text(
                  'Please keep the app open while we find your walker.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
