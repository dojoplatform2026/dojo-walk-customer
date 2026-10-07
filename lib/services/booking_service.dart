import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Customer is not logged in.');
    }

    return user.uid;
  }

  Future<String> createBooking({
    required String petName,
    required String walkType,
    required DateTime walkDateTime,
    required String addressId,
    required String addressLabel,
    required String address,
    required String city,
    required String pincode,
  }) async {
    final bookingRef = _firestore.collection('bookings').doc();

    final status = walkType == 'immediate'
        ? 'finding_walker'
        : 'pending';

    await bookingRef.set({
      'bookingId': bookingRef.id,

      'customerId': _uid,

      'petName': petName,

      'walkType': walkType,

      'scheduledAt': Timestamp.fromDate(walkDateTime),

      'pickupAddressId': addressId,

      'pickupAddress': {
        'label': addressLabel,
        'address': address,
        'city': city,
        'pincode': pincode,
      },

      'status': status,

      'walkerId': null,
      'walkerName': null,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return bookingRef.id;
  }

  /// Cancels a booking belonging to the currently logged-in customer.
  ///
  /// Cancellation is allowed only before the walk has started.
  Future<void> cancelBooking({
    required String bookingId,
  }) async {
    final uid = _uid;

    final bookingRef =
        _firestore.collection('bookings').doc(bookingId);

    final bookingSnapshot = await bookingRef.get();

    if (!bookingSnapshot.exists) {
      throw StateError('Booking not found.');
    }

    final data = bookingSnapshot.data();

    if (data == null) {
      throw StateError('Booking data is unavailable.');
    }

    // Security check:
    // Customer can cancel only their own booking.
    final customerId = data['customerId'] as String?;

    if (customerId != uid) {
      throw StateError(
        'You are not allowed to cancel this booking.',
      );
    }

    final currentStatus =
        data['status'] as String? ?? 'unknown';

    // Cancellation is allowed only before the walk starts.
    const cancellableStatuses = {
      'pending',
      'finding_walker',
      'walker_assigned',
      'walker_arriving',
    };

    if (!cancellableStatuses.contains(currentStatus)) {
      if (currentStatus == 'walk_started') {
        throw StateError(
          'This booking cannot be cancelled because the walk has already started.',
        );
      }

      if (currentStatus == 'completed') {
        throw StateError(
          'This booking is already completed.',
        );
      }

      if (currentStatus == 'cancelled') {
        throw StateError(
          'This booking is already cancelled.',
        );
      }

      throw StateError(
        'This booking cannot be cancelled now.',
      );
    }

    await bookingRef.update({
      'status': 'cancelled',
      'cancelledBy': 'customer',
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
