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
}
