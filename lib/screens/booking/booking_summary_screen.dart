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
    return MaterialLocalizations.of(context).formatMediumDate(
      widget.walkDateTime,
    );
  }

  Future<void> _confirmBooking() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bookingId =
          await _bookingService.createBooking(
        petName: widget.petName,
        walkType:
            widget.immediate ? 'immediate' : 'scheduled',
        walkDateTime: widget.walkDateTime,
        addressId: widget.address.id,
        addressLabel: widget.address.label,
        address: widget.address.address,
        city: widget.address.city,
        pincode: widget.address.pincode,
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
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not create booking. Please try again.',
          ),
        ),
      );

      debugPrint('Booking error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final time =
        TimeOfDay.fromDateTime(widget.walkDateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Review your walk',
                style: TextStyle(
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
                  widget.petName,
                  style: const TextStyle(
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!widget.immediate) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_formatDate(context)} • ${time.format(context)}',
                        style: const TextStyle(
                          color:
                              DojoWalkTheme.mutedText,
                          fontSize: 14,
                        ),
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
                      widget.address.label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.address.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color:
                            DojoWalkTheme.mutedText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.address.city} • ${widget.address.pincode}',
                      style: const TextStyle(
                        fontSize: 14,
                        color:
                            DojoWalkTheme.mutedText,
                      ),
                    ),
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
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your booking will be sent to DOJO WALK.',
                            style: TextStyle(
                              color:
                                  DojoWalkTheme.mutedText,
                              fontSize: 13,
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
                  onPressed:
                      _isLoading ? null : _confirmBooking,
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
