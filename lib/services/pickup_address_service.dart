import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/pickup_address.dart';

class PickupAddressService {
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

  CollectionReference<Map<String, dynamic>>
      get _addresses {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('pickup_addresses');
  }

  Stream<List<PickupAddress>> watchAddresses() {
    return _addresses
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PickupAddress.fromFirestore)
              .toList(),
        );
  }

  Future<String> addAddress({
    required String label,
    required String address,
    required String city,
    required String pincode,
  }) async {
    final doc = await _addresses.add({
      'label': label.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'pincode': pincode.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> deleteAddress(String addressId) async {
    await _addresses.doc(addressId).delete();
  }
}
