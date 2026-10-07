import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'walker_arriving_screen.dart';
import 'rate_walker_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login to view your bookings.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where(
              'customerId',
              isEqualTo: user.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _BookingErrorView();
          }

          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              !snapshot.hasData) {
            return const _LoadingView();
          }

          final docs = snapshot.data?.docs ?? [];

          docs.sort((a, b) {
            final aTime =
                a.data()['createdAt'] as Timestamp?;

            final bTime =
                b.data()['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) {
              return 0;
            }

            if (aTime == null) {
              return 1;
            }

            if (bTime == null) {
              return -1;
            }

            return bTime.compareTo(aTime);
          });

          if (docs.isEmpty) {
            return const _EmptyBookings();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              30,
            ),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final document = docs[index];

              return _BookingCard(
                bookingId: document.id,
                data: document.data(),
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.bookingId,
    required this.data,
  });

  final String bookingId;
  final Map<String, dynamic> data;

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Scheduled';

      case 'finding_walker':
        return 'Finding Walker';

      case 'walker_assigned':
        return 'Walker Assigned';

      case 'walker_arriving':
        return 'Walker Arriving';

      case 'walk_started':
        return 'Walk Started';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      default:
        return 'Processing';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'walk_started':
        return Colors.blue;

      default:
        return DojoWalkTheme.primary;
    }
  }

  bool _isActive(String status) {
    return status == 'finding_walker' ||
        status == 'walker_assigned' ||
        status == 'walker_arriving' ||
        status == 'walk_started';
  }

  bool _hasRating() {
    final rating =
        (data['rating'] as num?)?.toInt() ?? 0;

    return rating >= 1 && rating <= 5;
  }

  void _openBooking(BuildContext context) {
    final status =
        data['status'] as String? ?? '';

    if (!_isActive(status)) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalkerArrivingScreen(
          bookingId: bookingId,
        ),
      ),
    );
  }

  void _openRating(BuildContext context) {
    final walkerName =
        data['walkerName'] as String? ??
            'Your walker';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RateWalkerScreen(
          bookingId: bookingId,
          walkerName: walkerName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petName =
        data['petName'] as String? ??
            'Your pet';

    final status =
        data['status'] as String? ?? '';

    final walkType =
        data['walkType'] as String? ?? '';

    final walkerName =
        data['walkerName'] as String?;

    final scheduledAt =
        data['scheduledAt'] as Timestamp?;

    final date = scheduledAt?.toDate();

    final address =
        data['pickupAddress']
            as Map<String, dynamic>?;

    final city =
        address?['city'] as String? ?? '';

    final statusColor =
        _statusColor(status);

    final isActive = _isActive(status);

    final isCompleted =
        status == 'completed';

    final hasRating = _hasRating();

    return InkWell(
      onTap: isActive
          ? () => _openBooking(context)
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary
                        .withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color:
                        DojoWalkTheme.primary,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        petName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                              DojoWalkTheme.text,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        walkType == 'immediate'
                            ? 'Walk Now'
                            : 'Scheduled Walk',
                        style: const TextStyle(
                          color: DojoWalkTheme
                              .mutedText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor
                          .withValues(alpha: 0.09),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      _statusText(status),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            if (date != null)
              _DetailRow(
                icon: Icons.schedule_rounded,
                text:
                    '${MaterialLocalizations.of(context).formatMediumDate(date)} • ${TimeOfDay.fromDateTime(date).format(context)}',
              ),

            if (city.isNotEmpty) ...[
              const SizedBox(height: 9),
              _DetailRow(
                icon:
                    Icons.location_on_outlined,
                text: city,
              ),
            ],

            if (walkerName != null &&
                walkerName.trim().isNotEmpty) ...[
              const SizedBox(height: 9),
              _DetailRow(
                icon: Icons.person_outline_rounded,
                text: walkerName,
              ),
            ],

            const SizedBox(height: 14),

            Container(
              height: 1,
              color: const Color(0xFFF0F0F0),
            ),

            const SizedBox(height: 14),

            if (isActive)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tap to view live walk status',
                      style: TextStyle(
                        color:
                            DojoWalkTheme.primary,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color:
                        DojoWalkTheme.primary,
                  ),
                ],
              )
            else if (isCompleted &&
                !hasRating)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'How was your walk?',
                      style: TextStyle(
                        color:
                            DojoWalkTheme.primary,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _openRating(context),
                    child: const Text(
                      'Rate',
                      style: TextStyle(
                        color:
                            DojoWalkTheme.primary,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              )
            else if (isCompleted &&
                hasRating)
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color:
                        DojoWalkTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${data['rating']} / 5',
                    style: const TextStyle(
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Rated',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              )
            else if (status == 'cancelled')
              const Text(
                'This booking was cancelled.',
                style: TextStyle(
                  color:
                      DojoWalkTheme.mutedText,
                  fontSize: 12,
                ),
              )
            else
              const Text(
                'Scheduled booking',
                style: TextStyle(
                  color:
                      DojoWalkTheme.mutedText,
                  fontSize: 12,
                ),
              ),

            const SizedBox(height: 10),

            Text(
              'Booking ID: $bookingId',
              style: const TextStyle(
                color:
                    DojoWalkTheme.mutedText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: DojoWalkTheme.mutedText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color:
                  DojoWalkTheme.mutedText,
              fontSize: 13,
            ),
          ),
        ),
      ],
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

class _BookingErrorView
    extends StatelessWidget {
  const _BookingErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: DojoWalkTheme.mutedText,
            ),
            SizedBox(height: 16),
            Text(
              'Unable to load bookings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.text,
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    DojoWalkTheme.mutedText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBookings
    extends StatelessWidget {
  const _EmptyBookings();

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
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color:
                    DojoWalkTheme.primary,
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No bookings yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.text,
                fontSize: 24,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your DOJO WALK bookings will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    DojoWalkTheme.mutedText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
