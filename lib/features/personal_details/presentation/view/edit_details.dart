import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/services/app_permission_service.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_course_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/sea_experience_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/widgets/course_wrapper_widget.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/widgets/document_wrapper_widget.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';
import 'package:seafarer_bio_data/widgets/app_date_picker.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';
import 'package:seafarer_bio_data/widgets/app_text_with_label.dart';
import 'package:seafarer_bio_data/widgets/bottomsheet/bottom_sheet_upload_image.dart';
import 'package:seafarer_bio_data/widgets/not_found_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {

  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _dobTextController = TextEditingController();
  final TextEditingController _nationalityTextController =
  TextEditingController();
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _fatherNameTextController =
  TextEditingController();


  final TextEditingController _passportTextController = TextEditingController();
  final TextEditingController _passportExpiryTextController =
  TextEditingController();
  final TextEditingController _cdcTextController = TextEditingController();
  final TextEditingController _cdcExpiryTextController =
  TextEditingController();
  final TextEditingController _visaTextController = TextEditingController();
  final TextEditingController _visaExpiryTextController =
  TextEditingController();


  late ProfileBloc profileBloc;
  late ProfileLoaded profileLoadedState;
  List<ProfileControllerWrapper> _docWrappers = [];
  List<ProfileCourseControllerWrapper> _certificateWrapperList = [];
  List<SeaExperienceControllerWrapper> _seaExperienceList=[];

  List<SeaExperienceControllerWrapper> get seaExperienceList => _seaExperienceList;

  late PersonalDetails personalDetails;
  bool _isUpdatingProfile = false;

  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;
  String? _pickedImagePath;
  String base64Image="";
  Uint8List base64Decoded=Uint8List(0);


  @override
  void initState() {
    profileBloc=context.read<ProfileBloc>();
    profileLoadedState=profileBloc.state as ProfileLoaded;

    super.initState();

    bindProfileData();
  }

  void _calculatePeriod(SeaExperienceControllerWrapper wrapper) {
    if (wrapper.fromDateController.text.isNotEmpty && wrapper.toDateController.text.isNotEmpty) {
      try {
        // Parsing the dd.mm.yyyy format used in your date picker
        List<String> fromParts = wrapper.fromDateController.text.split('.');
        List<String> toParts = wrapper.toDateController.text.split('.');

        DateTime from = DateTime(int.parse(fromParts[2]), int.parse(fromParts[1]), int.parse(fromParts[0]));
        DateTime to = DateTime(int.parse(toParts[2]), int.parse(toParts[1]), int.parse(toParts[0]));

        if (to.isAfter(from)) {
          int months = (to.year - from.year) * 12 + (to.month - from.month);

          // If the end day is earlier than the start day, the last month isn't fully completed
          if (to.day < from.day) {
            months--;
          }

          // Ensure we don't show negative numbers
          wrapper.periodController.text = months < 0 ? "0" : months.toString();
        } else {
          wrapper.periodController.text = "0";
        }
        setState(() {

        });
      } catch (e) {
        log("Date parsing error: $e");
      }
    }
  }

  void fetchImage(String userId) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      setState(() {
        log("IMAGE PICKED:$pickedFile");
        if (pickedFile != null) {
          _pickedImagePath=pickedFile.path;
        }
      });
      log("PATH:${_pickedImagePath}");
      final imageUpload= await uploadImage(userId,_pickedImagePath.toString());
      log("IMAGE UPLOAD:${imageUpload.toString()}");
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future<String> uploadImage(String userId,String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    base64Image = base64Encode(bytes);
    log("BASE64Image:$base64Image");
    return base64Image;

  }

  void bindProfileData() {
    personalDetails=profileLoadedState.profile.personalDetails;
    _firstNameTextController.text=profileLoadedState.profile.personalDetails.firstname;
     _lastNameTextController.text=profileLoadedState.profile.personalDetails.lastname;
     _dobTextController.text=profileLoadedState.profile.personalDetails.dob;
     _nationalityTextController.text=profileLoadedState.profile.personalDetails.nationality;
     _postTextController.text=profileLoadedState.profile.personalDetails.postAppliedFor;
     _fatherNameTextController.text=profileLoadedState.profile.personalDetails.fatherName;
      base64Image=profileLoadedState.profile.personalDetails.profilePic;
      base64Decoded=base64Decode(profileLoadedState.profile.personalDetails.profilePic);

     _docWrappers = profileLoadedState.profile.documents.map((doc) {
       return ProfileControllerWrapper(
         name: doc.name,
         number: doc.number,
         issueDate: doc.issueDate,
         issuePlace: doc.place,
         validity: doc.validity,
       );
     }).toList();
     _certificateWrapperList = profileLoadedState.profile.courses.map((course) {
       return ProfileCourseControllerWrapper(
         name: course.title,
         number: course.number,
         issuedDate: course.issueDate,
         issuePlace: course.place,
         validity: course.validity,
       );
     }).toList();
     _seaExperienceList=profileLoadedState.profile.seaExperiences.map((e) {
       return SeaExperienceControllerWrapper(
         vesselName: e.vesselName,
         company: e.companyName,
         vesselType: e.vesselType,
         grt: e.grt,
         bhp: e.bhp,
         rank: e.rank,
         fromDate: e.from,
         toDate: e.to,
         period: e.period,
       );
     },).toList();

     setState(() {

     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Slight background for contrast
      appBar: AppBar(
        title: Text("My Bio Data"),
      ),
      body: BlocListener<ProfileBloc,ProfileState>(listener: (context, state) {
        if(state is ProfileLoaded){
          // Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: AppTextView(
              title: 'Profile Updated Successfully',
              textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14,color: AppColors.appSurface),
              textAlign: TextAlign.center,

            ),backgroundColor: AppColors.appTextColor,)
          );
        }

      },child:BlocBuilder<ProfileBloc,ProfileState>(builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileError) {
          return Center(child: Text(state.message));
        }

        if(state is ProfileLoaded){
          final profile = state.profile;
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // --- PERSONAL INFORMATION SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextFormField(
                              label: "Post Applied For",
                              hint: "enter your post",
                              controller: _postTextController,
                            ),
                            AppTextFormField(
                              label: "First name",
                              hint: "enter your first name",
                              controller: _firstNameTextController,
                            ),
                            AppTextFormField(
                              label: "Last name",
                              hint: "enter your last name",
                              controller: _lastNameTextController,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0,top: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 120,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: _pickedImagePath != null
                                  ? Image.file(File(_pickedImagePath!), fit: BoxFit.cover)
                                  : base64Decoded.isNotEmpty
                                  ? Image.memory(base64Decoded, fit: BoxFit.cover)
                                  : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: AppTextView(title: 'No Photo', textStyle: TextStyle(
                                        fontWeight: FontWeight.w600,fontSize: 16,color: AppColors.appTextColor
                                      )),
                                    ),
                                  ),
                            ),
                            Positioned(
                              top: 0,right: 0,
                              child: InkWell(
                                  onTap: () async {
                                    var permissionGranted=  await AppPermissionService.requestPhotosPermission();

                                    if(permissionGranted) fetchImage(profile.userId);
                                  },
                                  child: Container(
                                      height: 36,
                                      width: 36,
                                      decoration: BoxDecoration(
                                          color: AppColors.appSurface,
                                          borderRadius: BorderRadius.circular(36)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Center(child: SvgPicture.asset('assets/icons/camera-add.svg',fit: BoxFit.scaleDown,)),
                                      ))),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppTextFormField(
                    label: "Father's Name",
                    hint: "enter your father's name",
                    controller: _fatherNameTextController,
                  ),
                  AppTextFormField(
                    label: "Date of Birth",
                    hint: "enter your dob",
                    controller:_dobTextController,
                  ), // Profile Image Placeholder
                  AppTextFormField(
                    label: "Nationality",
                    hint: "enter you nationality",
                    controller:_nationalityTextController,
                  ),
                  const SizedBox(height: 16),

                  // --- DOCUMENTS TABLE SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppTextView(title: "Documents",textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.appPrimary,
                        letterSpacing: 0.5
                      ),),
                      InkWell(onTap: (){
                        _showAddDocumentSheet('Documents');
                      },child: SvgPicture.asset('assets/icons/add-icon.svg'))
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  ..._docWrappers
                      .map((wrapper) => Padding(
                    padding:
                    const EdgeInsets
                        .only(
                        bottom: 16.0),
                    child: DocumentWrapperWidget(wrapper: wrapper,onDelete: () {
                      setState(() {
                        _docWrappers.removeAt(_docWrappers.indexOf(wrapper));
                      });
                    },),
                  ))
                      .toList(),
                  // const SizedBox(height: 8),

                  // --- COURSES / CERTIFICATES SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppTextView(title: "Courses",textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appPrimary,
                          letterSpacing: 0.5
                      ),),
                      InkWell(onTap: (){
                        _showAddDocumentSheet('Courses');
                      },child: SvgPicture.asset('assets/icons/add-icon.svg'))
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  ..._certificateWrapperList
                      .map((wrapper) => CourseWrapperWidget(wrapper: wrapper,onDelete: () {
                    setState(() {
                      _certificateWrapperList.removeAt(_certificateWrapperList.indexOf(wrapper));
                    });

                      },))
                      .toList(),
                  const SizedBox(height: 16),

                  // --- WORK HISTORY SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppTextView(title: "Sea Experience", textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appPrimary,
                          letterSpacing: 0.5
                      ),),
                      InkWell(
                        onTap:  (){
                          _showAddExperienceSheet(context);
                        },
                          child: SvgPicture.asset('assets/icons/add-icon.svg'))
                    ],
                  ),
                  seaExperienceList.isEmpty?NotFoundWidget(title: 'Not Found', desc: 'No Sea Experience, please add your experience by clicking add button'):
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: seaExperienceList.length,
                    itemBuilder: (context, index) => SeaExperienceWidget(seaExperienceControllerWrapper:seaExperienceList[index],onDelete: (){
                      setState(() {
                        seaExperienceList.removeAt(index);
                      });
                    },onEdit: () {
                      _showAddExperienceSheet(context, existingWrapper: seaExperienceList[index]);
                    },),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: AppButton(
                      onTap: () {
                        setState(() {
                          _isUpdatingProfile=true;
                        });
                        context.read<ProfileBloc>().add(
                          UpdateFullProfileEvent(
                            personalDetails: PersonalDetails(
                                postAppliedFor: _postTextController.text,
                                firstname: _firstNameTextController.text,
                                lastname: _lastNameTextController.text,
                                fatherName: _fatherNameTextController.text,
                                dob: _dobTextController.text,
                                nationality: _nationalityTextController.text,
                                profilePic: base64Image,

                            ),
                            documents: _docWrappers.map((w) => w.toEntity()).toList(),
                            courses: _certificateWrapperList.map((w) => w.toEntity()).toList(),
                            seaExperiences: seaExperienceList.map((w) => w.toEntity()).toList(), // Your local list from the UI
                          ),
                        );
                      },

                      title: "Save Changes",
                    ),
                  )
                ]),
              ));
        }

        return SizedBox();
      },),),
    );
  }

  // Helper method for Table Headers
  TableRow _buildTableHeader(List<String> labels) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[100]),
      children: labels
          .map((label) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ))
          .toList(),
    );
  }

  // Helper method for Table Rows
  TableRow _buildTableRow(List<String> values) {
    return TableRow(
      children: values
          .map((val) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(val, style: const TextStyle(fontSize: 12)),
              ))
          .toList(),
    );
  }

  void _addNewDocument(String title, String name) {
    switch (title) {
      case "Documents":
        setState(() {
          _docWrappers.add(ProfileControllerWrapper(name: name));
        });
        break;
      case "Courses":
        setState(() {
          _certificateWrapperList.add(ProfileCourseControllerWrapper(name: name));
        });
        break;
    }
  }

  void _showAddDocumentSheet(String type) {
    final TextEditingController nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Moves sheet above keyboard
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextView(title: "Add New $type Type",textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.appPrimary,
                letterSpacing: 0.5
            ),),
            const SizedBox(height: 10),
            AppTextFormField(
              controller: nameCtrl,
              label: "$type Name",
              hint: "Enter your document name",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addNewDocument(type, nameCtrl.text);
                Navigator.pop(context);
              },
              child: const Text("Add to List"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddExperienceSheet(BuildContext context, {SeaExperienceControllerWrapper? existingWrapper}) {
    final isEditing = existingWrapper != null;
    final wrapper = existingWrapper ?? SeaExperienceControllerWrapper();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important to allow sheet to move up with keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24, left: 20, right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24, // Keyboard padding
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppTextView(title:isEditing ? "Edit Sea Experience" : "Add Sea Experience",textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appPrimary,
                      letterSpacing: 0.5
                  ),),
                  InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset('assets/icons/close-square.svg'))
                ],
              ),
              const SizedBox(height: 20),

              // Ship Name
              AppTextFormField(
                controller: wrapper.vesselNameController,
                label: "Ship Name",
                hint: "Enter your ship/vessel name",
              ),
              AppTextFormField(
                controller: wrapper.companyNameController,
                label: "Company Name",
                hint: "Enter your company name",
              ),
              const SizedBox(height: 16),

              // Type & Rank Row
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: wrapper.vesselTypeController,
                      label: "Type",
                      hint: "vessel type",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextFormField(
                      controller: wrapper.rankController,
                      label: "Rank",
                      hint: "your rank",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date From & To Row
              Row(
                children: [
                  Expanded(
                    child: AppDatePicker(
                      controller: wrapper.fromDateController,
                      label: "From",
                      onDateSelected: (date) {
                        wrapper.fromDateController.text = "${date.day}.${date.month}.${date.year}";
                        _calculatePeriod(wrapper);
                        setState(() {});
                      },
                      firstDate:
                      DateTime(
                          1900),
                      lastDate:
                      DateTime(
                          2100),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDatePicker(
                      controller: wrapper.toDateController,
                      label: "To",
                      onDateSelected: (date) {
                        wrapper.toDateController.text = "${date.day}.${date.month}.${date.year}";
                        _calculatePeriod(wrapper);
                        setState(() {});
                      },
                      firstDate:
                      DateTime(
                          1900),
                      lastDate:
                      DateTime(
                          2100),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: wrapper.grtController,
                      label: "GRT",
                      hint: "Your ship's Gross Register Tonnage",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextFormField(
                      controller: wrapper.bhpController,
                      label: "BHP",
                      hint: "Your ship's Brake Horsepower",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AppTextView(title: "Period:", textStyle: TextStyle()),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: AppTextView(title: "${wrapper.periodController.text} (in months)", textStyle: TextStyle()),
                  ),//to date minus from date will get period served in month
                ],
              ),

              const SizedBox(height: 32),

              // Action Button
              Align(
                alignment: Alignment.center,
                child: AppButton(
                  title: isEditing ? "Edit Sea Experience" : "Add Experience", onTap: () {
                  if (!isEditing) {
                    // Only add to list if we are creating a NEW one
                    setState(() {
                      seaExperienceList.add(wrapper);
                    });
                  } else {
                    // If editing, the controllers are already linked to the list item,
                    // so we just need to refresh the UI.
                    setState(() {});

                  }


                  // final newExp = SeaExperience(
                  //   vesselName: wrapper.vesselNameController.text,
                  //   companyName: wrapper.companyNameController.text,
                  //   vesselType: wrapper.vesselTypeController.text,
                  //   grt: wrapper.grtController.text,
                  //   bhp: wrapper.bhpController.text,
                  //   rank: wrapper.rankController.text,
                  //   from: wrapper.fromDateController.text,
                  //   to: wrapper.toDateController.text,
                  //   period: wrapper.periodController.text,
                  // );
                  //
                  //
                  // seaExperienceList.add(
                  //     SeaExperienceControllerWrapper(
                  //       vesselName: newExp.vesselName,
                  //       company: newExp.companyName,
                  //       vesselType: newExp.vesselType,
                  //       grt: newExp.grt,
                  //       bhp: newExp.bhp,
                  //       rank: newExp.rank,
                  //       fromDate: newExp.from,
                  //       toDate: newExp.to,
                  //       period: newExp.period,
                  //     )
                  // );
                  // setState(() {
                  //
                  // });
                  Navigator.pop(context);
                },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SeaExperienceWidget extends StatelessWidget {
  final SeaExperienceControllerWrapper seaExperienceControllerWrapper;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const SeaExperienceWidget({
    super.key,
    required this.seaExperienceControllerWrapper,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.white24,
          //     blurRadius: 0.6,
          //     spreadRadius: 6.0
          //   )
          // ]
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ship Name",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: onEdit,
                        child: Icon(Icons.edit_note, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: onDelete,
                        child: Icon(Icons.delete_outline, color: Colors.red, size: 24),
                      ),
                    ],
                  )
                ],
              ),
              Text(
                seaExperienceControllerWrapper.vesselNameController.text,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Type",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      Text(
                        seaExperienceControllerWrapper.vesselTypeController.text,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rank",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      Text(
                        seaExperienceControllerWrapper.rankController.text,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      Text(
                        seaExperienceControllerWrapper.fromDateController.text,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "To",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      Text(
                        seaExperienceControllerWrapper.toDateController.text,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}