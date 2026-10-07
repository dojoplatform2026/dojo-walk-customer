import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final TextEditingController _commentController =
      TextEditingController();

  int _rating = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _alreadyRated = false;

  String? _walkerId;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadBooking() async {
    try {
      final booking = await _firestore
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (!mounted) return;

      if (!booking.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final data = booking.data() ?? {};

      final existingRating =
          (data['rating'] as num?)?.toInt() ?? 0;

      final walkerId =
          data['walkerId'] as String?;

      final hasRating = existingRating >= 1 &&
          existingRating <= 5;

      setState(() {
        _rating = hasRating ? existingRating : 0;
        _alreadyRated = hasRating;
        _walkerId = walkerId;
        _isLoading = false;

        if (hasRating) {
          _commentController.text =
              data['review'] as String? ?? '';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('Load rating error: $e');
    }
  }

  Future<void> _submitRating() async {
    if (_rating < 1 ||
        _rating > 5 ||
        _isSubmitting ||
        _alreadyRated) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      _showMessage(
        'Please login again to submit your rating.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bookingRef = _firestore
          .collection('bookings')
          .doc(widget.bookingId);

      final booking =
          await bookingRef.get();

      if (!booking.exists) {
        throw StateError('Booking not found.');
      }

      final data = booking.data() ?? {};

      final existingRating =
          (data['rating'] as num?)?.toInt() ?? 0;

      // Extra protection against duplicate submissions.
      if (existingRating >= 1 &&
          existingRating <= 5) {
        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
          _alreadyRated = true;
          _rating = existingRating;
        });

        _showMessage(
          'This walk has already been rated.',
        );

        return;
      }

      final review =
          _commentController.text.trim();

      await bookingRef.update({
        'rating': _rating,
        'review': review,
        'ratedBy': user.uid,
        'walkerId': _walkerId ??
            data['walkerId'],
        'ratedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      // Also keep a separate review document.
      // This makes future review/rating
      // screens easier to build.
      await _firestore
          .collection('walker_reviews')
          .doc(widget.bookingId)
          .set({
        'bookingId': widget.bookingId,
        'customerId': user.uid,
        'walkerId': _walkerId ??
            data['walkerId'],
        'walkerName': widget.walkerName,
        'rating': _rating,
        'review': review,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _alreadyRated = true;
      });

      await _showThankYouDialog();

      if (!mounted) return;

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Could not submit your rating. Please try again.',
      );

      debugPrint('Rating submission error: $e');
    }
  }

  Future<void> _showThankYouDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Thank you! ⭐',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Your feedback helps us improve DOJO WALK and provide better walks.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: DojoWalkTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
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
      canPop: !_isSubmitting,
      child: Scaffold(
        backgroundColor:
            DojoWalkTheme.background,
        appBar: AppBar(
          title: const Text('Rate Your Walk'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: DojoWalkTheme.primary,
                  ),
                )
              : _alreadyRated
                  ? _AlreadyRatedView(
                      rating: _rating,
                      walkerName:
                          widget.walkerName,
                      onDone: () {
                        Navigator.of(context)
                            .popUntil(
                          (route) => route.isFirst,
                        );
                      },
                    )
                  : _RatingForm(
                      walkerName:
                          widget.walkerName,
                      rating: _rating,
                      controller:
                          _commentController,
                      isSubmitting:
                          _isSubmitting,
                      onRatingChanged: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                      onSubmit: _submitRating,
                    ),
        ),
      ),
    );
  }
}

class _RatingForm extends StatelessWidget {
  const _RatingForm({
    required this.walkerName,
    required this.rating,
    required this.controller,
    required this.isSubmitting,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final String walkerName;
  final int rating;
  final TextEditingController controller;
  final bool isSubmitting;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
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
              color: DojoWalkTheme.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'How was your experience with $walkerName?',
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
                final selected =
                    star <= rating;

                return IconButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          onRatingChanged(
                            star,
                          );
                        },
                  splashRadius: 28,
                  icon: Icon(
                    selected
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 46,
                    color: selected
                        ? DojoWalkTheme.primary
                        : const Color(
                            0xFFBDBDBD,
                          ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Text(
            rating == 0
                ? 'Tap a star to rate'
                : _ratingLabel(rating),
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 28),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your feedback',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 300,
            enabled: !isSubmitting,
            textInputAction:
                TextInputAction.newline,
            decoration:
                const InputDecoration(
              hintText:
                  'Tell us about your experience (optional)',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  rating == 0 || isSubmitting
                      ? null
                      : onSubmit,
              child: isSubmitting
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

          const SizedBox(height: 14),

          const Text(
            'Your rating is saved securely with this booking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return '1 out of 5 • Needs improvement';
      case 2:
        return '2 out of 5 • Could be better';
      case 3:
        return '3 out of 5 • Good';
      case 4:
        return '4 out of 5 • Great';
      case 5:
        return '5 out of 5 • Excellent!';
      default:
        return '';
    }
  }
}

class _AlreadyRatedView extends StatelessWidget {
  const _AlreadyRatedView({
    required this.rating,
    required this.walkerName,
    required this.onDone,
  });

  final int rating;
  final String walkerName;
  final VoidCallback onDone;

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
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: DojoWalkTheme.primary,
                size: 62,
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              'Already rated',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.text,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'You already rated $walkerName for this walk.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) {
                  return Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 36,
                    color:
                        DojoWalkTheme.primary,
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                child: const Text(
                  'Done',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
