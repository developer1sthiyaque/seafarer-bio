// import 'dart:convert';
//
// import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
//
// class PersonalInfoModel extends PersonalDetails {
//   const PersonalInfoModel({
//     required String firstName,
//     String? middleName,
//     required String lastName,
//     required String nationality,
//     required DateTime dateOfBirth,
//     required String placeOfBirth,
//     required String permanentAddress,
//     required String presentTemporaryAddress,
//     required String postCode,
//     required String mobile,
//     required String email,
//   }) : super(
//           fatherName: firstName,
//           middleName: middleName,
//           lastName: lastName,
//           nationality: nationality,
//           dateOfBirth: dateOfBirth,
//           placeOfBirth: placeOfBirth,
//           permanentAddress: permanentAddress,
//           presentTemporaryAddress: presentTemporaryAddress,
//           postCode: postCode,
//           mobile: mobile,
//           email: email,
//         );
//
//   factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
//     return PersonalInfoModel(
//       firstName: json['firstName'],
//       middleName: json['middleName'],
//       lastName: json['lastName'],
//       nationality: json['nationality'],
//       dateOfBirth: DateTime.parse(json['dateOfBirth']),
//       placeOfBirth: json['placeOfBirth'],
//       permanentAddress: json['permanentAddress'],
//       presentTemporaryAddress: json['presentTemporaryAddress'],
//       postCode: json['postCode'],
//       mobile: json['mobile'],
//       email: json['email'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'firstName': firstName,
//       'middleName': middleName,
//       'lastName': lastName,
//       'nationality': nationality,
//       'dateOfBirth': dateOfBirth.toIso8601String(),
//       'placeOfBirth': placeOfBirth,
//       'permanentAddress': permanentAddress,
//       'presentTemporaryAddress': presentTemporaryAddress,
//       'postCode': postCode,
//       'mobile': mobile,
//       'email': email,
//     };
//   }
//
//   // A convenience method to create a PersonalInfoModel from an entity
//   factory PersonalInfoModel.fromEntity(PersonalInfoEntity entity) {
//     return PersonalInfoModel(
//       firstName: entity.firstName,
//       middleName: entity.middleName,
//       lastName: entity.lastName,
//       nationality: entity.nationality,
//       dateOfBirth: entity.dateOfBirth,
//       placeOfBirth: entity.placeOfBirth,
//       permanentAddress: entity.permanentAddress,
//       presentTemporaryAddress: entity.presentTemporaryAddress,
//       postCode: entity.postCode,
//       mobile: entity.mobile,
//       email: entity.email,
//     );
//   }
// }
