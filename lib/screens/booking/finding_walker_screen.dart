import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/booking_watch_service.dart';
import 'walker_arriving_screen.dart';

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
        backgroundColor: DojoWalkTheme.background,
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

              if (snapshot.connectionState ==
                      ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const _LoadingView();
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

              final walkerName =
                  data['walkerName'] as String?;

              // Walker has been assigned.
              if (status == 'walker_assigned') {
                return _AssignedView(
                  bookingId: widget.bookingId,
                  walkerName: walkerName,
                  onViewWalk: () {
                    _openWalkerArriving(
                      context,
                      status: status,
                    );
                  },
                );
              }

              // Walker is on the way.
              if (status == 'walker_arriving') {
                return _AssignedView(
                  bookingId: widget.bookingId,
                  walkerName: walkerName,
                  title: 'Walker is on the way',
                  message: walkerName?.isNotEmpty == true
                      ? '$walkerName is coming to the pickup location.'
                      : 'Your walker is coming to the pickup location.',
                  buttonText: 'Track Walker',
                  onViewWalk: () {
                    _openWalkerArriving(
                      context,
                      status: status,
                    );
                  },
                );
              }

              // Walk has started.
              if (status == 'walk_started') {
                return _AssignedView(
                  bookingId: widget.bookingId,
                  walkerName: walkerName,
                  title: 'Walk in progress',
                  message:
                      'Your dog is now out for a walk.',
                  buttonText: 'View Walk',
                  onViewWalk: () {
                    _openWalkerArriving(
                      context,
                      status: status,
                    );
                  },
                );
              }

              // Walk completed.
              if (status == 'completed') {
                return _CompletedView(
                  bookingId: widget.bookingId,
                  walkerName: walkerName,
                );
              }

              // Cancelled booking.
              if (status == 'cancelled') {
                return const _CancelledView();
              }

              // Pending / finding walker.
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

  void _openWalkerArriving(
    BuildContext context, {
    required String status,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalkerArrivingScreen(
          bookingId: widget.bookingId,
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
    final isPending = status == 'pending';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        18,
      ),
      child: Column(
        children: [
          const Spacer(),

          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: DojoWalkTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 42,
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
              color: DojoWalkTheme.text,
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
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: DojoWalkTheme.primary,
              ),
            )
          else
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: DojoWalkTheme.primary,
                size: 30,
              ),
            ),

          const SizedBox(height: 28),

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
                    'Booking ID: $bookingId',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DojoWalkTheme.text,
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
            isPending
                ? 'We will assign a walker closer to your scheduled walk.'
                : 'Please keep the app open while we find your walker.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedView extends StatelessWidget {
  const _AssignedView({
    required this.bookingId,
    required this.walkerName,
    required this.onViewWalk,
    this.title = 'Walker assigned!',
    this.message,
    this.buttonText = 'View Walk',
  });

  final String bookingId;
  final String? walkerName;
  final VoidCallback onViewWalk;
  final String title;
  final String? message;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    final defaultMessage =
        walkerName?.isNotEmpty == true
            ? '$walkerName is assigned to your walk.'
            : 'A walker has been assigned to your walk.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        20,
      ),
      child: Column(
        children: [
          const Spacer(),

          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: DojoWalkTheme.primary,
              size: 54,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DojoWalkTheme.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            message ?? defaultMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary
                        .withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: DojoWalkTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your walker will arrive at the pickup address.',
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Booking ID: $bookingId',
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 11,
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewWalk,
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedView extends StatelessWidget {
  const _CompletedView({
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
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: DojoWalkTheme.primary,
              size: 54,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Walk completed!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DojoWalkTheme.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            walkerName?.isNotEmpty == true
                ? 'Thanks for choosing DOJO WALK. ${walkerName!} completed the walk.'
                : 'Thanks for choosing DOJO WALK. Your walk has been completed.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Booking ID: $bookingId',
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 12,
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              },
              child: const Text(
                'Back to Home',
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
                color: DojoWalkTheme.text,
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

class _BookingNotFoundView
    extends StatelessWidget {
  const _BookingNotFoundView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Booking not found.',
          style: TextStyle(
            color: DojoWalkTheme.text,
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
                color: DojoWalkTheme.text,
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
