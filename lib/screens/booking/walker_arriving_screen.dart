import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/booking_service.dart';
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
      backgroundColor: DojoWalkTheme.background,
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
              return _ErrorView(
                onRetry: () {},
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
                data['walkerName'] as String? ??
                    'Your walker';

            final petName =
                data['petName'] as String? ??
                    'your dog';

            final addressData =
                data['pickupAddress']
                    as Map<String, dynamic>?;

            final address =
                addressData?['address'] as String? ??
                    '';

            final city =
                addressData?['city'] as String? ?? '';

            final cancelRequest =
                data['cancelRequest'];

            final cancellationPending =
                cancelRequest is Map &&
                cancelRequest['status'] == 'pending';

            if (status == 'walker_assigned') {
              return _WalkerAssignedView(
                walkerName: walkerName,
                petName: petName,
                bookingId: bookingId,
                cancellationPending:
                    cancellationPending,
              );
            }

            if (status == 'walker_arriving') {
              return _WalkerArrivingView(
                walkerName: walkerName,
                petName: petName,
                bookingId: bookingId,
                address: address,
                city: city,
                cancellationPending:
                    cancellationPending,
              );
            }

            if (status == 'walk_started') {
              return _WalkStartedView(
                walkerName: walkerName,
                petName: petName,
                bookingId: bookingId,
              );
            }

            if (status == 'completed') {
              return _WalkCompletedView(
                walkerName: walkerName,
                bookingId: bookingId,
              );
            }

            if (status == 'cancelled') {
              return const _CancelledView();
            }

            return _WaitingView(
              status: status,
              bookingId: bookingId,
            );
          },
        ),
      ),
    );
  }
}

class _WalkerAssignedView extends StatelessWidget {
  const _WalkerAssignedView({
    required this.walkerName,
    required this.petName,
    required this.bookingId,
    required this.cancellationPending,
  });

  final String walkerName;
  final String petName;
  final String bookingId;
  final bool cancellationPending;

  @override
  Widget build(BuildContext context) {
    return _BaseWalkLayout(
      icon: Icons.person_rounded,
      title: 'Walker assigned!',
      message:
          '$walkerName is assigned to walk $petName.',
      child: Column(
        children: [
          _InfoCard(
            icon: Icons.person_rounded,
            title: 'Your walker',
            value: walkerName,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.pets_rounded,
            title: 'Your dog',
            value: petName,
          ),
          const SizedBox(height: 18),
          const _StatusBanner(
            icon: Icons.schedule_rounded,
            text:
                'Your walker will start heading to the pickup location soon.',
          ),
          const SizedBox(height: 22),
          if (cancellationPending)
            const _CancellationPendingBanner()
          else
            _CancelRequestButton(
              bookingId: bookingId,
            ),
          const SizedBox(height: 18),
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

class _WalkerArrivingView extends StatelessWidget {
  const _WalkerArrivingView({
    required this.walkerName,
    required this.petName,
    required this.bookingId,
    required this.address,
    required this.city,
    required this.cancellationPending,
  });

  final String walkerName;
  final String petName;
  final String bookingId;
  final String address;
  final String city;
  final bool cancellationPending;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_walk_rounded,
                size: 86,
                color: DojoWalkTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your walker is arriving',
            style: TextStyle(
              color: DojoWalkTheme.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$walkerName is on the way to pick up $petName.',
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _InfoCard(
            icon: Icons.person_rounded,
            title: 'Walker',
            value: walkerName,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.pets_rounded,
            title: 'Dog',
            value: petName,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.location_on_rounded,
            title: 'Pickup location',
            value: [
              address,
              city,
            ]
                .where(
                  (value) => value.trim().isNotEmpty,
                )
                .join(', '),
          ),
          const SizedBox(height: 16),
          const _StatusBanner(
            icon: Icons.directions_walk_rounded,
            text:
                'Your walker is on the way. Please be ready at the pickup location.',
          ),
          const SizedBox(height: 22),
          if (cancellationPending)
            const _CancellationPendingBanner()
          else
            _CancelRequestButton(
              bookingId: bookingId,
            ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Booking ID: $bookingId',
              style: const TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 12,
              ),
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
    required this.petName,
    required this.bookingId,
  });

  final String walkerName;
  final String petName;
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return _BaseWalkLayout(
      icon: Icons.directions_walk_rounded,
      title: 'Walk started!',
      message:
          '$walkerName has started the walk with $petName.',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: DojoWalkTheme.primary,
                  size: 30,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The walk is currently in progress.',
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
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
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: DojoWalkTheme.primary,
                size: 62,
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
              '$walkerName has completed your dog’s walk.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Booking ID: $bookingId',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(
                  Icons.star_rounded,
                ),
                label: const Text(
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

class _WaitingView extends StatelessWidget {
  const _WaitingView({
    required this.status,
    required this.bookingId,
  });

  final String status;
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: DojoWalkTheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preparing your walk',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.text,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'We are waiting for the next booking update.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: $status',
              style: const TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Booking ID: $bookingId',
              style: const TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelRequestButton extends StatelessWidget {
  const _CancelRequestButton({
    required this.bookingId,
  });

  final String bookingId;

  Future<void> _showCancellationDialog(
    BuildContext context,
  ) async {
    String? selectedReason;

    const reasons = [
      'Changed my plans',
      'Walker is taking too long',
      'I no longer need the walk',
      'Booked by mistake',
      'Other',
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setState,
          ) {
            return AlertDialog(
              title: const Text(
                'Request cancellation',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please select a reason for your cancellation request.',
                      style: TextStyle(
                        color:
                            DojoWalkTheme.mutedText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...reasons.map(
                      (reason) {
                        return RadioListTile<String>(
                          value: reason,
                          groupValue:
                              selectedReason,
                          contentPadding:
                              EdgeInsets.zero,
                          activeColor:
                              DojoWalkTheme.primary,
                          title: Text(
                            reason,
                            style:
                                const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedReason =
                                  value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Keep Booking',
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      selectedReason == null
                          ? null
                          : () async {
                              Navigator.pop(
                                dialogContext,
                              );

                              await _sendRequest(
                                context,
                                selectedReason!,
                              );
                            },
                  child: const Text(
                    'Send Request',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendRequest(
    BuildContext context,
    String reason,
  ) async {
    if (!context.mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(
                  color: DojoWalkTheme.primary,
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    'Sending request...',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await BookingService()
          .requestCancellation(
        bookingId: bookingId,
        reason: reason,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Cancellation request sent.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);

      final message =
          error is StateError
              ? error.message
              : 'Unable to send cancellation request. Please try again.';

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _showCancellationDialog(
            context,
          );
        },
        icon: const Icon(
          Icons.close_rounded,
        ),
        label: const Text(
          'Request Cancellation',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(
            color: Color(0xFFFFD0D0),
          ),
          minimumSize: const Size(
            double.infinity,
            52,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CancellationPendingBanner
    extends StatelessWidget {
  const _CancellationPendingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DojoWalkTheme.primary
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DojoWalkTheme.primary
              .withValues(alpha: 0.18),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            color: DojoWalkTheme.primary,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancellation request pending',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your request has been sent. We will update you once it is reviewed.',
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DojoWalkTheme.primary
            .withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: DojoWalkTheme.primary,
            size: 22,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: DojoWalkTheme.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.09),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: DojoWalkTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty
                      ? 'Not available'
                      : value,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseWalkLayout extends StatelessWidget {
  const _BaseWalkLayout({
    required this.icon,
    required this.title,
    required this.message,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        30,
        20,
        30,
      ),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: DojoWalkTheme.primary,
              size: 55,
            ),
          ),
          const SizedBox(height: 26),
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
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),
          child,
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
              'Unable to load walk',
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
