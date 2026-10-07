import 'package:cloud_firestore/cloud_firestore.dart';

class PickupAddress {
  const PickupAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.pincode,
  });

  final String id;
  final String label;
  final String address;
  final String city;
  final String pincode;

  factory PickupAddress.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};

    return PickupAddress(
      id: snapshot.id,
      label: data['label'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'address': address,
      'city': city,
      'pincode': pincode,
    };
  }
}
