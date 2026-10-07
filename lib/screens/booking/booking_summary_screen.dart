import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/pickup_address.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({
    super.key,
    required this.petName,
    required this.immediate,
    required this.walkDateTime,
    required this.address,
  });

  final String petName;
  final bool immediate;
  final DateTime walkDateTime;
  final PickupAddress address;

  String _formatDate() {
    return '${walkDateTime.day.toString().padLeft(2, '0')}/'
        '${walkDateTime.month.toString().padLeft(2, '0')}/'
        '${walkDateTime.year}';
  }

  String _formatTime() {
    return TimeOfDay.fromDateTime(
      walkDateTime,
    ).format(null);
  }

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(
      walkDateTime,
    );

    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Booking Summary'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            24,
          ),
          children: [
            const Text(
              'Review your\nwalk booking',
              style: TextStyle(
                color: DojoWalkTheme.text,
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Make sure everything looks right before confirming.',
              style: TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 26),

            _SummaryCard(
              icon: Icons.pets_rounded,
              title: 'Pet',
              child: Text(
                petName,
                style: const TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _SummaryCard(
              icon: immediate
                  ? Icons.flash_on_rounded
                  : Icons.calendar_month_rounded,
              title: 'Walk',
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    immediate
                        ? 'Immediate Walk'
                        : 'Scheduled Walk',
                    style: const TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    immediate
                        ? 'As soon as possible'
                        : '${_formatDate()} • ${time.format(context)}',
                    style: const TextStyle(
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _SummaryCard(
              icon: Icons.location_on_rounded,
              title: 'Pickup Address',
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    address.address,
                    style: const TextStyle(
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${address.city} • ${address.pincode}',
                    style: const TextStyle(
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary,
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to book',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'We will find the best available walker for you.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Booking confirmation is next.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Confirm Booking',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE7E7E7),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  DojoWalkTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: DojoWalkTheme.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color:
                        DojoWalkTheme.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
