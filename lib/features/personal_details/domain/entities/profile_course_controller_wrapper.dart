import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';

class ProfileCourseControllerWrapper {
  final String name; // e.g., "Passport"
  final TextEditingController numberController;
  final TextEditingController issueDateController;
  final TextEditingController issuePlaceController;
  final TextEditingController expiryController;

  ProfileCourseControllerWrapper({
    required this.name,
    String number = '',
    String issuedDate = '',
    String issuePlace = '',
    String validity = '',
  })  : numberController = TextEditingController(text: number),
        issueDateController = TextEditingController(text: issuedDate),
        issuePlaceController = TextEditingController(text: issuePlace),
        expiryController = TextEditingController(text: validity);

  // Convert UI state back to your Document Entity
  Course toEntity() => Course(
    title: name,
    number: numberController.text,
    issueDate: issueDateController.text,
    place: issuePlaceController.text,
    validity: expiryController.text,
  );

  void dispose() {
    numberController.dispose();
    issueDateController.dispose();
    issuePlaceController.dispose();
    expiryController.dispose();
  }
}