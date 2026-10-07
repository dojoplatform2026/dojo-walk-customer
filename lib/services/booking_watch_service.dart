import 'package:cloud_firestore/cloud_firestore.dart';

class BookingWatchService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      watchBooking(String bookingId) {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .snapshots();
  }
}
