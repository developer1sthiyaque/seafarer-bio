import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDetails extends Equatable {
  final String postAppliedFor;
  final String firstname;
  final String lastname;
  final String fatherName;
  final String dob;
  final String nationality;
  final List<String> languages;

  const PersonalDetails({
    required this.postAppliedFor,
    required this.firstname,
    required this.lastname,
    required this.fatherName,
    required this.dob,
    required this.nationality,
    this.languages = const [],
  });

  factory PersonalDetails.fromFirestore(Map<String, dynamic> data) {
    return PersonalDetails(
      postAppliedFor: data['postAppliedFor'] ?? '',
      firstname: data['firstname'] ?? '',
      lastname: data['lastname'] ?? '',
      fatherName: data['fatherName'] ?? '',
      dob: data['dob'] ?? '',
      nationality: data['nationality'] ?? '',
      languages: List<String>.from(data['languages'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postAppliedFor': postAppliedFor,
      'firstname': firstname,
      'lastname': lastname,
      'fatherName': fatherName,
      'dob': dob,
      'nationality': nationality,
      'languages': languages,
    };
  }

  @override
  List<Object?> get props => [
        postAppliedFor,
        firstname,
        lastname,
        fatherName,
        dob,
        nationality,
        languages,
      ];
}

class Document extends Equatable {
  final String name;
  final String number;
  final String issueDate;
  final String place;
  final String validity;

  const Document({
    required this.name,
    required this.number,
    required this.issueDate,
    required this.place,
    required this.validity,
  });

  factory Document.fromFirestore(Map<String, dynamic> data) {
    return Document(
      name: data['name'] ?? '',
      number: data['number'] ?? '',
      issueDate: data['issued-date'] ?? '',
      place: data['issued-place'] ?? '',
      validity: data['validity'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'number': number,
      'issued-date': number,
      'issued-place': number,
      'validity': validity,
    };
  }

  @override
  List<Object?> get props => [name, number, validity];
}

class Course extends Equatable {
  final String? id;
  final String title;
  final String number;
  final String issueDate;
  final String place;
  final String validity;

  const Course({
    this.id,
    required this.title,
    required this.number,
    required this.issueDate,
    required this.place,
    required this.validity,
  });

  factory Course.fromFirestore(Map<String, dynamic> data, {String? id}) {
    return Course(
      id: id,
      title: data['title'] ?? '',
      number: data['number'] ?? '',
      issueDate: data['issued-date'] ?? '',
      place: data['issued-place'] ?? '',
      validity: data['validity'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      'number': number,
      'issued-date': issueDate,
      'issued-place': place,
      'validity': validity,
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? number,
    String? issueDate,
    String? issuePlace,
    String? duration,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      number: number ?? this.number,
      issueDate: issueDate ?? this.issueDate,
      place: issuePlace ?? this.issueDate,
      validity: duration ?? this.validity,
    );
  }

  @override
  List<Object?> get props => [id, title, number, issueDate,place,validity];
}

class SeaExperience extends Equatable {
  final String? id;
  final String vesselName;
  final String vesselType;
  final String rank;
  final String from;
  final String to;

  const SeaExperience({
    this.id,
    required this.vesselName,
    required this.vesselType,
    required this.rank,
    required this.from,
    required this.to,
  });

  factory SeaExperience.fromFirestore(Map<String, dynamic> data, {String? id}) {
    return SeaExperience(
      id: id,
      vesselName: data['vesselName'] ?? '',
      vesselType: data['type'] ?? '',
      rank: data['rank'] ?? '',
      from: data['from'] ?? '',
      to: data['to'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "vesselName": vesselName,
      "type": vesselType,
      "rank": rank,
      "from": from,
      "to": to,
    };
  }

  SeaExperience copyWith({
    String? id,
    String? vesselName,
    String? vesselType,
    String? rank,
    String? from,
    String? to,
  }) {
    return SeaExperience(
      id: id ?? this.id,
      vesselName: vesselName ?? this.vesselName,
      vesselType: vesselType ?? this.vesselType,
      rank: rank ?? this.rank,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  List<Object?> get props => [id, vesselName,vesselType, rank, from, to];
}

class Profile extends Equatable {
  final String userId;
  final PersonalDetails personalDetails;
  final List<Document> documents;
  final List<Course> courses;
  final List<SeaExperience> seaExperiences;
  final bool isProfileCompleted;

  const Profile({
    required this.userId,
    required this.personalDetails,
    this.documents = const [],
    this.courses = const [],
    this.seaExperiences = const [],
    this.isProfileCompleted = false,
  });

  factory Profile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return Profile(
      userId: snapshot.id,
      personalDetails:
          PersonalDetails.fromFirestore(data?['personalDetails'] ?? {}),
      documents: (data?['documents'] as List<dynamic>?)
              ?.map(
                  (doc) => Document.fromFirestore(doc as Map<String, dynamic>))
              .toList() ??
          const [],
      courses: (data?['courses'] as List<dynamic>?)
              ?.map((courseData) =>
                  Course.fromFirestore(courseData as Map<String, dynamic>))
              .toList() ??
          const [],
      seaExperiences: (data?['seaExperiences'] as List<dynamic>?)
              ?.map((expData) =>
                  SeaExperience.fromFirestore(expData as Map<String, dynamic>))
              .toList() ??
          const [],
      isProfileCompleted: data?['isProfileCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'personalDetails': personalDetails.toFirestore(),
      'documents': documents.map((doc) => doc.toFirestore()).toList(),
      'courses': courses.map((course) => course.toFirestore()).toList(),
      'seaExperiences': seaExperiences.map((exp) => exp.toFirestore()).toList(),
      'isProfileCompleted': isProfileCompleted,
    };
  }

  Profile copyWith({
    PersonalDetails? personalDetails,
    List<Document>? documents,
    List<Course>? courses,
    List<SeaExperience>? seaExperiences,
    bool? isCompleted,
  }) {
    return Profile(
      userId: userId,
      personalDetails: personalDetails ?? this.personalDetails,
      documents: documents ?? this.documents,
      courses: courses ?? this.courses,
      seaExperiences: seaExperiences ?? this.seaExperiences,
      isProfileCompleted: isCompleted ?? isProfileCompleted,

    );
  }

  @override
  List<Object?> get props => [
        userId,
        personalDetails,
        documents,
        courses,
        seaExperiences,
      ];
}
