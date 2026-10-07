import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
  });

  final String id;
  final String name;
  final String breed;
  final int age;
  final String gender;

  factory Pet.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};

    return Pet(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      breed: data['breed'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      gender: data['gender'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'breed': breed,
      'age': age,
      'gender': gender,
    };
  }
}
