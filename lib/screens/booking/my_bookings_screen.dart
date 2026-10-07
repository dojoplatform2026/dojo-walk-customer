import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to view your bookings.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where(
              'customerId',
              isEqualTo: user.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load bookings.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: DojoWalkTheme.primary,
              ),
            );
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
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final data = docs[index].data();

              return _BookingCard(
                bookingId: docs[index].id,
                data: data,
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
        return 'Booking';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return DojoWalkTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final petName =
        data['petName'] as String? ?? 'Your pet';

    final status =
        data['status'] as String? ?? '';

    final walkType =
        data['walkType'] as String? ?? '';

    final scheduledAt =
        data['scheduledAt'] as Timestamp?;

    final date = scheduledAt?.toDate();

    final address =
        data['pickupAddress'] as Map<String, dynamic>?;

    final city =
        address?['city'] as String? ?? '';

    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DojoWalkTheme.primary
                      .withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: DojoWalkTheme.primary,
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
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      walkType == 'immediate'
                          ? 'Walk Now'
                          : 'Scheduled Walk',
                      style: const TextStyle(
                        color:
                            DojoWalkTheme.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor
                      .withValues(alpha: 0.09),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  _statusText(status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (date != null)
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: DojoWalkTheme.mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${MaterialLocalizations.of(context).formatMediumDate(date)} • ${TimeOfDay.fromDateTime(date).format(context)}',
                    style: const TextStyle(
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

          if (city.isNotEmpty) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: DojoWalkTheme.mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    city,
                    style: const TextStyle(
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          Text(
            'Booking ID: $bookingId',
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: DojoWalkTheme.primary,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your DOJO WALK bookings will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
