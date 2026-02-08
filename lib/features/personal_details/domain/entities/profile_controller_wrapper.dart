import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';

class ProfileControllerWrapper {
  final String name; // e.g., "Passport"
  final TextEditingController numberController;
  final TextEditingController issueDateController;
  final TextEditingController issuePlaceController;
  final TextEditingController expiryController;

  ProfileControllerWrapper({
    required this.name,
    String number = '',
    String issueDate = '',
    String issuePlace = '',
    String validity = '',
  })  : numberController = TextEditingController(text: number),
        issueDateController = TextEditingController(text: issueDate),
        issuePlaceController = TextEditingController(text: issuePlace),
        expiryController = TextEditingController(text: validity);

  // Convert UI state back to your Document Entity
  Document toEntity() => Document(
    name: name,
    number: numberController.text,
    issueDate: numberController.text,
    place: numberController.text,
    validity: expiryController.text,
  );

  void dispose() {
    numberController.dispose();
    issueDateController.dispose();
    issuePlaceController.dispose();
    expiryController.dispose();
  }
}