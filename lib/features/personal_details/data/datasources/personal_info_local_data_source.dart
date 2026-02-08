import 'package:seafarer_bio_data/features/personal_details/data/models/personal_info_model.dart';

// data/datasources/profile_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileRemoteDataSource {
  Stream<Profile?> getProfile(String userId);
  Future<void> saveProfile(Profile profile);
  Future<void> updateProfile(Profile profile);
  Future<void> createProfile(Profile profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSourceImpl(this.firestore);

  @override
  Stream<Profile?> getProfile(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(null);
    }
    return firestore
        .collection('profiles')
        .doc(userId)
        .withConverter<Profile>(
      fromFirestore: Profile.fromFirestore,
      toFirestore: (profile, _) => profile.toFirestore(),
    )
        .snapshots()
        .map((doc) => doc.data());
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    await firestore
        .collection('profiles')
        .doc(profile.userId)
        .set(profile.toFirestore());
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await firestore
        .collection('profiles')
        .doc(profile.userId)
        .update(profile.toFirestore());
  }

  @override
  Future<void> createProfile(Profile profile) async {
    await firestore
        .collection('profiles')
        .doc(profile.userId)
        .set(profile.toFirestore());
  }
}

