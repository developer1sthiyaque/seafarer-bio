import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';

class SeaExperienceControllerWrapper {
  final TextEditingController vesselNameController ;
  final TextEditingController companyNameController ;
  final TextEditingController vesselTypeController ; // Added based on your UI
  final TextEditingController grtController ;
  final TextEditingController bhpController ;
  final TextEditingController rankController ;
  final TextEditingController fromDateController ;
  final TextEditingController toDateController;
  final TextEditingController periodController;


  SeaExperienceControllerWrapper({
    String vesselName = '',
    String company = '',
    String vesselType = '',
    String grt = '',
    String bhp = '',
    String rank = '',
    String fromDate = '',
    String toDate = '',
    String period = '',
  })  : vesselNameController = TextEditingController(text: vesselName),
        companyNameController = TextEditingController(text: company),
        vesselTypeController = TextEditingController(text: vesselType),
        grtController = TextEditingController(text: grt),
        bhpController = TextEditingController(text: bhp),
        rankController = TextEditingController(text: rank),
        fromDateController = TextEditingController(text: fromDate),
        toDateController = TextEditingController(text: toDate),
        periodController = TextEditingController(text: period);

  SeaExperience toEntity() => SeaExperience(
    vesselName: vesselNameController.text,
    companyName: vesselTypeController.text,
    vesselType: vesselTypeController.text,
    grt: vesselTypeController.text,
    bhp: vesselTypeController.text,
    rank: rankController.text,
    from: fromDateController.text,
    to: toDateController.text,
    period: toDateController.text,
  );

  void dispose() {
    vesselNameController.dispose();
    vesselTypeController.dispose();
    rankController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
  }
}