
import 'package:flutter/material.dart';

const Color bookingOrange = Color(0xFFFF7900);
const Color bookingText = Color(0xFF202020);

enum WalkBookingType {
  oneTime,
  regular,
}

class BookingStartScreen extends StatefulWidget {
  const BookingStartScreen({
    super.key,
    this.initialType = WalkBookingType.oneTime,
  });

  final WalkBookingType initialType;

  @override
  State<BookingStartScreen> createState() =>
      _BookingStartScreenState();
}

class _BookingStartScreenState extends State<BookingStartScreen> {
  late WalkBookingType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  void _continueBooking() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Next step: connect dog details and pickup address.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOneTime = _selectedType == WalkBookingType.oneTime;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAF5),
        foregroundColor: bookingText,
        elevation: 0,
        title: const Text(
          'Book a Walk',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Let’s plan your dog’s walk.',
                    style: TextStyle(
                      fontSize: 27,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                      color: bookingText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose the walking plan that suits you.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _WalkTypeCard(
                    title: 'One-Time Walk',
                    subtitle:
                        'Book a single walk whenever your dog needs it.',
                    icon: Icons.directions_walk_rounded,
                    selected: isOneTime,
                    onTap: () {
                      setState(() {
                        _selectedType = WalkBookingType.oneTime;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _WalkTypeCard(
                    title: 'Regular Walks',
                    subtitle:
                        'Plan a consistent walking routine for your dog.',
                    icon: Icons.calendar_month_rounded,
                    selected: !isOneTime,
                    onTap: () {
                      setState(() {
                        _selectedType = WalkBookingType.regular;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: bookingOrange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isOneTime
                                ? 'Next, you’ll choose your dog, pickup address, and preferred walk time.'
                                : 'Next, you’ll provide your dog and pickup details before setting up a regular walking plan.',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFEEEEEE)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _continueBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bookingOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkTypeCard extends StatelessWidget {
  const _WalkTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? bookingOrange
                  : const Color(0xFFEAEAEA),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: selected
                      ? bookingOrange.withValues(alpha: 0.12)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: selected ? bookingOrange : Colors.black54,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: bookingText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? bookingOrange : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
