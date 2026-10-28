// ignore_for_file: subtype_of_sealed_class
// DocumentSnapshot is sealed in cloud_firestore 5+ but required for unit test fakes without a live Firestore backend.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';

/// Minimal stand-in for the Firestore snapshot that `Profile.fromFirestore`
/// consumes, so the production deserializer can be exercised without a live
class FakeProfileSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  FakeProfileSnapshot({required this.id, required Map<String, dynamic>? data})
      : _data = data;

  @override
  final String id;

  final Map<String, dynamic>? _data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => _data != null;
}

/// Deserializes a Firestore-shaped map through the real production factory.
///
/// `userId` mirrors `snapshot.id`, which is where `Profile.fromFirestore` reads
/// the id from (the field is not part of the stored document body).
Profile profileFromFirestoreMap(
  Map<String, dynamic> data, {
  required String userId,
}) =>
    Profile.fromFirestore(
      FakeProfileSnapshot(id: userId, data: data),
      null,
    );