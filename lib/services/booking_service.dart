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
    final bookingRef =
        _firestore.collection('bookings').doc();

    final status = walkType == 'immediate'
        ? 'finding_walker'
        : 'pending';

    await bookingRef.set({
      'bookingId': bookingRef.id,

      'customerId': _uid,

      'petName': petName,

      'walkType': walkType,

      'scheduledAt':
          Timestamp.fromDate(walkDateTime),

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

      'cancelRequest': null,

      'createdAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    return bookingRef.id;
  }

  /// Sends a cancellation request for a booking.
  ///
  /// The booking itself is NOT cancelled here.
  /// Walker/admin must approve the request before
  /// the booking status becomes "cancelled".
  Future<void> requestCancellation({
    required String bookingId,
    String? reason,
  }) async {
    final uid = _uid;

    final bookingRef =
        _firestore.collection('bookings').doc(bookingId);

    final bookingSnapshot =
        await bookingRef.get();

    if (!bookingSnapshot.exists) {
      throw StateError(
        'Booking not found.',
      );
    }

    final data =
        bookingSnapshot.data();

    if (data == null) {
      throw StateError(
        'Booking data is unavailable.',
      );
    }

    // Customer ownership check.
    final customerId =
        data['customerId'] as String?;

    if (customerId != uid) {
      throw StateError(
        'You are not allowed to request cancellation for this booking.',
      );
    }

    final status =
        data['status'] as String? ?? '';

    // Cancellation request is not allowed
    // once the walk has started or finished.
    const allowedStatuses = {
      'pending',
      'finding_walker',
      'walker_assigned',
      'walker_arriving',
    };

    if (!allowedStatuses.contains(status)) {
      if (status == 'walk_started') {
        throw StateError(
          'Cancellation is not available because the walk has already started.',
        );
      }

      if (status == 'completed') {
        throw StateError(
          'This walk has already been completed.',
        );
      }

      if (status == 'cancelled') {
        throw StateError(
          'This booking is already cancelled.',
        );
      }

      throw StateError(
        'Cancellation request cannot be sent at this stage.',
      );
    }

    // Check if a request already exists.
    final existingRequest =
        data['cancelRequest'];

    if (existingRequest is Map) {
      final existingStatus =
          existingRequest['status']
              as String?;

      if (existingStatus == 'pending') {
        throw StateError(
          'A cancellation request is already pending.',
        );
      }

      if (existingStatus == 'approved') {
        throw StateError(
          'This cancellation request has already been approved.',
        );
      }
    }

    await bookingRef.update({
      'cancelRequest': {
        'status': 'pending',
        'requestedBy': 'customer',
        'customerId': uid,
        'reason': reason?.trim().isEmpty == true
            ? null
            : reason?.trim(),
        'requestedAt':
            FieldValue.serverTimestamp(),
      },
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }
}
