import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/booking_watch_service.dart';

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
  final BookingWatchService _bookingWatchService =
      BookingWatchService();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<
              DocumentSnapshot<Map<String, dynamic>>>(
            stream: _bookingWatchService.watchBooking(
              widget.bookingId,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ErrorView(
                  onRetry: () {
                    setState(() {});
                  },
                );
              }

              if (!snapshot.hasData) {
                return const _LoadingView();
              }

              final booking = snapshot.data!;

              if (!booking.exists) {
                return const _BookingNotFoundView();
              }

              final data = booking.data() ?? {};
              final status =
                  data['status'] as String? ?? '';

              if (status == 'walker_assigned') {
                return _AssignedView(
                  bookingId: widget.bookingId,
                  walkerName:
                      data['walkerName'] as String?,
                );
              }

              if (status == 'cancelled') {
                return const _CancelledView();
              }

              return _FindingView(
                bookingId: widget.bookingId,
                immediate: widget.immediate,
                status: status,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FindingView extends StatelessWidget {
  const _FindingView({
    required this.bookingId,
    required this.immediate,
    required this.status,
  });

  final String bookingId;
  final bool immediate;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
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

          Text(
            immediate
                ? 'Finding a walker'
                : 'Walk booked',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            immediate
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

          if (immediate)
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
              borderRadius: BorderRadius.circular(16),
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
                    'Booking ID: $bookingId',
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

          Text(
            status == 'pending'
                ? 'We will notify you when a walker is assigned.'
                : 'Please keep the app open while we find your walker.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _AssignedView extends StatelessWidget {
  const _AssignedView({
    required this.bookingId,
    required this.walkerName,
  });

  final String bookingId;
  final String? walkerName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: DojoWalkTheme.primary,
              size: 52,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Walker assigned!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            walkerName?.isNotEmpty == true
                ? '$walkerName is assigned to your walk.'
                : 'A walker has been assigned to your walk.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: DojoWalkTheme.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your walker will arrive at the pickup address.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Next step:
                // Walker Arriving screen.
              },
              child: const Text(
                'View Walk',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: DojoWalkTheme.primary,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: DojoWalkTheme.mutedText,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load booking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.mutedText,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingNotFoundView extends StatelessWidget {
  const _BookingNotFoundView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Booking not found.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CancelledView extends StatelessWidget {
  const _CancelledView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cancel_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking cancelled',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This booking is no longer active.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
