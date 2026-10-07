import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/pickup_address.dart';
import '../../services/booking_service.dart';
import 'finding_walker_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
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

  @override
  State<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState
    extends State<BookingSummaryScreen> {
  final BookingService _bookingService = BookingService();

  bool _isLoading = false;

  String _formatDate(BuildContext context) {
    return MaterialLocalizations.of(context)
        .formatMediumDate(widget.walkDateTime);
  }

  String _formatTime(BuildContext context) {
    return TimeOfDay.fromDateTime(
      widget.walkDateTime,
    ).format(context);
  }

  Future<void> _confirmBooking() async {
    if (_isLoading) return;

    if (widget.petName.trim().isEmpty) {
      _showError('Pet information is missing.');
      return;
    }

    if (widget.address.address.trim().isEmpty) {
      _showError('Pickup address is missing.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bookingId =
          await _bookingService.createBooking(
        petName: widget.petName.trim(),
        walkType:
            widget.immediate ? 'immediate' : 'scheduled',
        walkDateTime: widget.walkDateTime,
        addressId: widget.address.id,
        addressLabel: widget.address.label.trim(),
        address: widget.address.address.trim(),
        city: widget.address.city.trim(),
        pincode: widget.address.pincode.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FindingWalkerScreen(
            bookingId: bookingId,
            immediate: widget.immediate,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Booking creation error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        'Could not create booking. Please try again.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Summary'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
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
                const Text(
                  'Review your walk',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Check the details before confirming.',
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 24),

                _SectionCard(
                  title: 'Pet',
                  icon: Icons.pets_rounded,
                  child: Text(
                    widget.petName.isEmpty
                        ? 'Pet'
                        : widget.petName,
                    style: const TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _SectionCard(
                  title: 'Walk',
                  icon: Icons.directions_walk_rounded,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.immediate
                            ? 'Walk Now'
                            : 'Scheduled Walk',
                        style: const TextStyle(
                          color: DojoWalkTheme.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color:
                                DojoWalkTheme.mutedText,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              widget.immediate
                                  ? 'Starting as soon as a walker is assigned'
                                  : _formatDate(context),
                              style: const TextStyle(
                                color:
                                    DojoWalkTheme.mutedText,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (!widget.immediate) ...[
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 17,
                              color:
                                  DojoWalkTheme.mutedText,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _formatTime(context),
                              style: const TextStyle(
                                color:
                                    DojoWalkTheme.mutedText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                _SectionCard(
                  title: 'Pickup Address',
                  icon: Icons.location_on_rounded,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.address.label.isEmpty
                            ? 'Pickup Location'
                            : widget.address.label,
                        style: const TextStyle(
                          color: DojoWalkTheme.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        widget.address.address,
                        style: const TextStyle(
                          color:
                              DojoWalkTheme.mutedText,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      if (widget.address.city
                              .trim()
                              .isNotEmpty ||
                          widget.address.pincode
                              .trim()
                              .isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          [
                            widget.address.city.trim(),
                            widget.address.pincode.trim(),
                          ]
                              .where(
                                (value) =>
                                    value.isNotEmpty,
                              )
                              .join(' • '),
                          style: const TextStyle(
                            color:
                                DojoWalkTheme.mutedText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary
                        .withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: DojoWalkTheme.primary
                          .withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color:
                              DojoWalkTheme.primary,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ready to book',
                              style: TextStyle(
                                color:
                                    DojoWalkTheme.text,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your booking will be sent to DOJO WALK and you can track its status.',
                              style: TextStyle(
                                color:
                                    DojoWalkTheme.mutedText,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _confirmBooking,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm Booking',
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'You can track your walker after booking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DojoWalkTheme.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: DojoWalkTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
