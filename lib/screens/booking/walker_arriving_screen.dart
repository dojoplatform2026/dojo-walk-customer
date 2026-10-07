import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/booking_watch_service.dart';
import 'rate_walker_screen.dart';

class WalkerArrivingScreen extends StatelessWidget {
  const WalkerArrivingScreen({
    super.key,
    required this.bookingId,
  });

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final service = BookingWatchService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Walk'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: StreamBuilder<
            DocumentSnapshot<Map<String, dynamic>>>(
          stream: service.watchBooking(bookingId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Unable to load walk details.',
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: DojoWalkTheme.primary,
                ),
              );
            }

            final booking = snapshot.data!;

            if (!booking.exists) {
              return const Center(
                child: Text('Booking not found.'),
              );
            }

            final data = booking.data() ?? {};

            final status =
                data['status'] as String? ?? '';

            final walkerName =
                data['walkerName'] as String? ??
                    'Your walker';

            if (status == 'walk_started') {
              return _WalkStartedView(
                walkerName: walkerName,
              );
            }

            if (status == 'completed') {
              return _WalkCompletedView(
                walkerName: walkerName,
                bookingId: bookingId,
              );
            }

            return _WalkerArrivingView(
              walkerName: walkerName,
              bookingId: bookingId,
            );
          },
        ),
      ),
    );
  }
}

class _WalkerArrivingView extends StatelessWidget {
  const _WalkerArrivingView({
    required this.walkerName,
    required this.bookingId,
  });

  final String walkerName;
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_walk_rounded,
                size: 90,
                color: DojoWalkTheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Your walker is arriving',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your walker is on the way to the pickup address.',
            style: TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: DojoWalkTheme.primary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Walker',
                        style: TextStyle(
                          color:
                              DojoWalkTheme.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        walkerName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.07),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: DojoWalkTheme.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pickup location confirmed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.check_circle_rounded,
                  color: DojoWalkTheme.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Booking ID: $bookingId',
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkStartedView extends StatelessWidget {
  const _WalkStartedView({
    required this.walkerName,
  });

  final String walkerName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                color: DojoWalkTheme.primary,
                size: 55,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Walk started!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '$walkerName has started the walk with your dog.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkCompletedView extends StatelessWidget {
  const _WalkCompletedView({
    required this.walkerName,
    required this.bookingId,
  });

  final String walkerName;
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: DojoWalkTheme.primary,
                size: 60,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Walk completed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '$walkerName has completed the walk.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RateWalkerScreen(
                        bookingId: bookingId,
                        walkerName: walkerName,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Rate Walker',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
