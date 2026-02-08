// presentation/bloc/profile_event.dart

import '../../domain/entities/profile_entity.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String userId;
  LoadProfile(this.userId);
}

class SaveProfileEvent extends ProfileEvent {
  final Profile profile;
  SaveProfileEvent(this.profile);
}

class UpdatePersonalDetailsEvent extends ProfileEvent {
  final PersonalDetails personalDetails;
  UpdatePersonalDetailsEvent(this.personalDetails);
}

class UpdateDocumentsEvent extends ProfileEvent {
  final List<Document> documents;
  UpdateDocumentsEvent(this.documents);
}

class UpdateCoursesEvent extends ProfileEvent {
  final List<Course> courses;
  UpdateCoursesEvent(this.courses);
}

class UpdateSeaExperienceEvent extends ProfileEvent {
  final List<SeaExperience> seaExperiences;
  UpdateSeaExperienceEvent(this.seaExperiences);
}


class UpdateFullProfileEvent extends ProfileEvent {
  final PersonalDetails? personalDetails;
  final List<Document>? documents;
  final List<Course>? courses;
  final List<SeaExperience>? seaExperiences;

  UpdateFullProfileEvent({
    this.personalDetails,
    this.documents,
    this.courses,
    this.seaExperiences,
  });
}
