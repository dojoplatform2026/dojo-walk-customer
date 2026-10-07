import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class RateWalkerScreen extends StatefulWidget {
  const RateWalkerScreen({
    super.key,
    required this.bookingId,
    required this.walkerName,
  });

  final String bookingId;
  final String walkerName;

  @override
  State<RateWalkerScreen> createState() =>
      _RateWalkerScreenState();
}

class _RateWalkerScreenState
    extends State<RateWalkerScreen> {
  int _rating = 0;
  bool _isSubmitting = false;

  final TextEditingController _commentController =
      TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0 || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'rating': _rating,
        'review': _commentController.text.trim(),
        'ratedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Thank you!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            content: const Text(
              'Your feedback helps us improve DOJO WALK.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not submit your rating. Please try again.',
          ),
        ),
      );

      debugPrint('Rating error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rate Your Walk'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_emotions_rounded,
                    color: DojoWalkTheme.primary,
                    size: 58,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'How was your walk?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'How was your experience with ${widget.walkerName}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) {
                      final star = index + 1;

                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _rating = star;
                          });
                        },
                        icon: Icon(
                          star <= _rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 46,
                          color: star <= _rating
                              ? DojoWalkTheme.primary
                              : const Color(0xFFBDBDBD),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _rating == 0
                      ? 'Tap a star to rate'
                      : '$_rating out of 5',
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    hintText:
                        'Tell us about your experience (optional)',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _rating == 0 || _isSubmitting
                            ? null
                            : _submitRating,
                    child: _isSubmitting
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
                            'Submit Rating',
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Booking ID is saved with your feedback.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 12,
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
