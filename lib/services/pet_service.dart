import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/pet.dart';

class PetService {
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

  CollectionReference<Map<String, dynamic>> get _pets {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('pets');
  }

  Stream<List<Pet>> watchPets() {
    return _pets
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Pet.fromFirestore)
              .toList(),
        );
  }

  Future<String> addPet({
    required String name,
    required String breed,
    required int age,
    required String gender,
  }) async {
    final doc = await _pets.add({
      'name': name.trim(),
      'breed': breed.trim(),
      'age': age,
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> updatePet({
    required String petId,
    required String name,
    required String breed,
    required int age,
    required String gender,
  }) async {
    await _pets.doc(petId).update({
      'name': name.trim(),
      'breed': breed.trim(),
      'age': age,
      'gender': gender,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePet(String petId) async {
    await _pets.doc(petId).delete();
  }
}
