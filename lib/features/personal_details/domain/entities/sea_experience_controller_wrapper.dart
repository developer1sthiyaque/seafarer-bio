import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';

class SeaExperienceControllerWrapper {
  final TextEditingController vesselNameController ;
  final TextEditingController vesselTypeController ; // Added based on your UI
  final TextEditingController rankController ;
  final TextEditingController fromDateController ;
  final TextEditingController toDateController;


  SeaExperienceControllerWrapper({
    String vesselName = '',
    String vesselType = '',
    String rank = '',
    String fromDate = '',
    String toDate = '',
  })  : vesselNameController = TextEditingController(text: vesselName),
        vesselTypeController = TextEditingController(text: vesselType),
        rankController = TextEditingController(text: rank),
        fromDateController = TextEditingController(text: fromDate),
        toDateController = TextEditingController(text: toDate);

  SeaExperience toEntity() => SeaExperience(
    vesselName: vesselNameController.text,
    vesselType: vesselTypeController.text,
    rank: rankController.text,
    from: fromDateController.text,
    to: toDateController.text,
  );

  void dispose() {
    vesselNameController.dispose();
    vesselTypeController.dispose();
    rankController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
  }
}