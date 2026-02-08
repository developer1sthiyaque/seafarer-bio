import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_course_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/sea_experience_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';
import 'package:seafarer_bio_data/widgets/app_date_picker.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';
import 'package:seafarer_bio_data/widgets/app_text_with_label.dart';
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

  List<String> languageList = [
    "English",
    "Hindi",
    "Malayalam",
    "Tamil",
    "Telugu",
    "Kannada",
    "Punjabi",
    "Marathi",
    "Bengali",
    "Odia",
    "Urdu",
    "Spanish",
    "Japanese",
    "Chinese",
    "Arabic",
    "Portuguese",
    "Russian",
    "Korean"
  ];
  Set<String> selectedLanguages = {"English"};
  late ProfileBloc profileBloc;
  late ProfileLoaded profileLoadedState;
  List<ProfileControllerWrapper> _docWrappers = [];
  List<ProfileCourseControllerWrapper> _certificateWrapperList = [];
  List<SeaExperienceControllerWrapper> _seaExperienceList=[];

  List<SeaExperienceControllerWrapper> get seaExperienceList => _seaExperienceList;

  late PersonalDetails personalDetails;


  @override
  void initState() {
    profileBloc=context.read<ProfileBloc>();
    profileLoadedState=profileBloc.state as ProfileLoaded;

    super.initState();

    bindProfileData();
  }

  void bindProfileData() {
    personalDetails=profileLoadedState.profile.personalDetails;
    _firstNameTextController.text=profileLoadedState.profile.personalDetails.firstname;
     _lastNameTextController.text=profileLoadedState.profile.personalDetails.lastname;
     _dobTextController.text=profileLoadedState.profile.personalDetails.dob;
     _nationalityTextController.text=profileLoadedState.profile.personalDetails.nationality;
     _postTextController.text=profileLoadedState.profile.personalDetails.postAppliedFor;
     _fatherNameTextController.text=profileLoadedState.profile.personalDetails.fatherName;
     selectedLanguages.clear();
     selectedLanguages.addAll(profileLoadedState.profile.personalDetails.languages);
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
         vesselType: e.vesselType,
         rank: e.rank,
         fromDate: e.from,
         toDate: e.to,
       );
     },).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Slight background for contrast
      appBar: AppBar(
        title: Text("My Bio Data"),
      ),
      body: BlocListener<ProfileBloc,ProfileState>(listener: (context, state) {

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
                        child: Container(
                          width: 100,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            image: const DecorationImage(
                              image: AssetImage(
                                  'assets/images/passport.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
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
                  Wrap(
                children: languageList
                    .map((String lang) {
                  return Padding(
                    padding:
                    const EdgeInsets.all(4.0),
                    child: ChoiceChip(
                      label: Text(
                          lang), // Wrap the string in a Text widget
                      selected: selectedLanguages
                          .contains(
                          lang), // Check if this specific chip is selected
                      onSelected:
                          (bool selected) {
                        setState(() {
                          if (selected) {
                            selectedLanguages.add(
                                lang); // Add to set
                          } else {
                            selectedLanguages.remove(
                                lang); // Remove from set
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
                            ), // CHIPS TO MULTIPLE LANGUAGE PICK
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
                      SvgPicture.asset('assets/icons/add-icon.svg')
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
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        AppTextFormField(
                          controller: wrapper
                              .numberController,
                          width: MediaQuery
                              .sizeOf(
                              context)
                              .width *
                              0.43,
                          label:
                          wrapper.name,
                          hint:
                          "Enter ${wrapper.name} number",
                        ),
                        AppDatePicker(
                          controller: wrapper
                              .expiryController,
                          width: MediaQuery
                              .sizeOf(
                              context)
                              .width *
                              0.43,
                          label:
                          "${wrapper.name} Expiry",
                          firstDate:
                          DateTime(
                              1900),
                          lastDate:
                          DateTime(
                              2100),
                          onDateSelected:
                              (date) {
                            // You can format the date to string here as needed for your entity
                            wrapper.expiryController
                                .text =
                            "${date.day}/${date.month}/${date.year}";
                          },
                        ),
                      ],
                    ),
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
                      SvgPicture.asset('assets/icons/add-icon.svg')
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  ..._certificateWrapperList
                      .map((wrapper) => Padding(
                    padding:
                    const EdgeInsets
                        .only(
                        bottom: 16.0),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        AppTextFormField(
                          controller: wrapper
                              .numberController,
                          width: MediaQuery
                              .sizeOf(
                              context)
                              .width *
                              0.43,
                          label:
                          wrapper.name,
                          hint:
                          "Enter ${wrapper.name} number",
                        ),
                        AppDatePicker(
                          controller: wrapper
                              .expiryController,
                          width: MediaQuery
                              .sizeOf(
                              context)
                              .width *
                              0.43,
                          label:
                          "${wrapper.name} Expiry",
                          firstDate:
                          DateTime(
                              1900),
                          lastDate:
                          DateTime(
                              2100),
                          onDateSelected:
                              (date) {
                            // You can format the date to string here as needed for your entity
                            wrapper.expiryController
                                .text =
                            "${date.day}/${date.month}/${date.year}";
                          },
                        ),
                      ],
                    ),
                  ))
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
                  seaExperienceList.isEmpty?NotFoundWidget(title: 'Not Found', desc: 'No Sea Experience, please add your experience by clicking add button'):ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: seaExperienceList.length,
                    itemBuilder: (context, index) => SeaExperienceWidget(seaExperienceControllerWrapper:seaExperienceList[index]),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: AppButton(
                      onTap: () {
                        context.read<ProfileBloc>().add(
                          UpdateFullProfileEvent(
                            personalDetails: PersonalDetails(
                                postAppliedFor: _postTextController.text,
                                firstname: _firstNameTextController.text,
                                lastname: _lastNameTextController.text,
                                fatherName: _fatherNameTextController.text,
                                dob: _dobTextController.text,
                                nationality: _nationalityTextController.text,
                                languages: selectedLanguages.toList()
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

  void _showAddExperienceSheet(BuildContext context,) {
    final wrapper = SeaExperienceControllerWrapper();

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
                  AppTextView(title: "Add Sea Experience",textStyle: TextStyle(
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
                hint: "e.g. MV Jupiter LI",
              ),
              const SizedBox(height: 16),

              // Type & Rank Row
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      controller: wrapper.vesselTypeController,
                      label: "Type",
                      hint: "e.g. Bulk",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextFormField(
                      controller: wrapper.rankController,
                      label: "Rank",
                      hint: "e.g. Oiler",
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
              const SizedBox(height: 32),

              // Action Button
              Align(
                alignment: Alignment.center,
                child: AppButton(
                  title: "Add Experience", onTap: () {
                  final newExp = SeaExperience(
                    vesselName: wrapper.vesselNameController.text,
                    vesselType: wrapper.vesselTypeController.text,
                    rank: wrapper.rankController.text,
                    from: wrapper.fromDateController.text,
                    to: wrapper.toDateController.text,
                  );


                  seaExperienceList.add(
                      SeaExperienceControllerWrapper(
                        vesselName: newExp.vesselName,
                        vesselType: newExp.vesselType,
                        rank: newExp.rank,
                        fromDate: newExp.from,
                        toDate: newExp.to,
                      )
                  );
                  setState(() {

                  });
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
  const SeaExperienceWidget({
    super.key,
    required this.seaExperienceControllerWrapper,
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
              Text(
                "Ship Name",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey),
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