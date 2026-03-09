import 'dart:developer';

import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/app_validators.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/core/utils/string_extensions.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_course_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';
import 'package:seafarer_bio_data/widgets/app_date_picker.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';
import 'package:seafarer_bio_data/widgets/app_text_with_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:step_progress/step_progress.dart';

class ProfileCompletion extends StatefulWidget {
  const ProfileCompletion({super.key});

  @override
  State<ProfileCompletion> createState() => _ProfileCompletionState();
}

class _ProfileCompletionState extends State<ProfileCompletion> {
  final _form1Key = GlobalKey<FormState>();
  final _form2Key = GlobalKey<FormState>();
  final _form3Key = GlobalKey<FormState>();
  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _dobTextController = TextEditingController();
  final TextEditingController _nationalityTextController =
      TextEditingController();
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _fatherNameTextController =
      TextEditingController();
  //DOCUMENT

  final TextEditingController _passportTextController = TextEditingController();
  final TextEditingController _passportExpiryTextController =
      TextEditingController();
  final TextEditingController _cdcTextController = TextEditingController();
  final TextEditingController _cdcExpiryTextController =
      TextEditingController();
  final TextEditingController _visaTextController = TextEditingController();
  final TextEditingController _visaExpiryTextController =
      TextEditingController();
  //CERTIFICATE

  final PageController _controller = PageController(initialPage: 0);
  final StepProgressController _stepProgressController = StepProgressController(
    totalSteps: 3,
  );
  final ScrollController _scrollController = ScrollController();
  final FocusNode _postFocusNode = FocusNode();
// Repeat for other fields if needed
  int currentStep = 0;
  int _currentPage = 0;
  DateTime? _userVisaExpiry;
  DateTime? _userPassportExpiry;
  DateTime? _userCDCExpiry;
  Set<String> selectedLanguages = {"English"};
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

  List<ProfileControllerWrapper> _docWrappers = [];
  List<ProfileCourseControllerWrapper> _certificateWrapperList = [];
  @override
  void initState() {
    super.initState();
    _postFocusNode.addListener(() {
      if (_postFocusNode.hasFocus) {
        // Wait a tiny bit for the keyboard to fully pop up
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent, // Or a specific offset
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page!.toInt();
      });
    });
    log("CURRENT STEP ON INIT:${currentStep}");
    log("CURRENT PAGE ON INIT:${_currentPage}");

  }

  void bindData(Profile profile) {
    _firstNameTextController.text=profile.personalDetails.firstname;
    _lastNameTextController.text=profile.personalDetails.lastname;
    setState(() {

    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) async {
          if(state is CertificateUpdateSuccess){
            await PreferenceService.setProfileCompleted(true);
            if(context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false,);
              context.read<ProfileBloc>().add(
              LoadProfile(PreferenceService.userId.toString()),
            );
            }
          }
          log("LOG STATE IS :${state}");
          if (state is PersonalDetailsUpdateSuccess ||
              state is DocumentsUpdateSuccess) {
            if (_controller.hasClients) {
              _controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
              // _controller.animateToPage(
              //   nextTarget,
              //   duration: const Duration(milliseconds: 300),
              //   curve: Curves.easeIn,
              // );
            }
          }

          if(state is ProfileLoaded){
            bindData(state.profile);
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded ||
                state is DocumentsUpdateSuccess ||
                state is PersonalDetailsUpdateSuccess ||
                state is CertificateUpdateSuccess ||
                state is ProfileLoading) {
              return Stack(
                children: [
                  // Main Content (PageView) - Always stays in the tree
                  Opacity(
                    opacity: state is ProfileLoading
                        ? 0.5
                        : 1.0, // Dim while loading
                    child: IgnorePointer(
                      ignoring: state is ProfileLoading, // Prevent double taps
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.only(top: 120, bottom: 0),
                          height: MediaQuery.sizeOf(context).height,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            // color: index==0?Colors.indigo.shade200:index==1?Colors.red.shade200:Colors.green.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 70),
                            child: index == 0
                                ? Form(
                                  key: _form1Key,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      AppTextView(
                                        title: "Personal Information",textStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appPrimary,
                                          letterSpacing: 0.5
                                      ),),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      AppTextFormField(
                                        label: "First Name",
                                        hint: "enter your first name",
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        controller: _firstNameTextController,
                                        validator: (value) =>
                                            AppValidators.name(value),
                                      ),
                                      AppTextFormField(
                                        label: "Last ame",
                                        hint: "enter your last name",
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        controller: _lastNameTextController,
                                        validator: (value) =>
                                            AppValidators.name(value),
                                      ),
                                      AppTextFormField(
                                        label: "Post Applied For",
                                        hint: "enter your post",
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        controller: _postTextController,
                                        validator: (value) =>
                                            AppValidators.post(value),
                                      ),
                                      AppTextFormField(
                                        label: "Father's Name",
                                        hint: "enter your father's name",
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        controller:
                                        _fatherNameTextController,
                                        validator: (value) =>
                                            AppValidators.name(value),
                                      ),
                                      AppDatePicker(
                                        controller: _dobTextController,
                                        width: MediaQuery
                                            .sizeOf(
                                            context)
                                            .width,
                                        label:
                                        "Date of Birth",
                                        firstDate:
                                        DateTime(
                                            1900),
                                        lastDate:
                                        DateTime(
                                            2003),
                                        onDateSelected: (date) {
                                          // You can format the date to string here as needed for your entity
                                          _dobTextController
                                              .text =
                                          "${date.day}/${date.month}/${date.year}";
                                        },
                                        validator: (value) => AppValidators.dob(value),
                                      ),
                                      // AppTextFormField(
                                      //   label: "Date of Birth",
                                      //   hint: "enter your dob",
                                      //   controller: _dobTextController,
                                      //   validator: (value) =>
                                      //       AppValidators.dob(value),
                                      // ),
                                      AppTextFormField(
                                        label: "Nationality",
                                        hint: "enter you nationality",
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        controller:
                                        _nationalityTextController,
                                        validator: (value) =>
                                            AppValidators.name(value),
                                      ),
                                      /* Wrap(
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
                                            )*/
                                    ],
                                  ),
                                )
                                : index == 1
                                ? Form(
                                  key: _form2Key,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppTextView(
                                            title: "Documents",textStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.appPrimary,
                                              letterSpacing: 0.5
                                          ),),
                                          Padding(
                                            padding:
                                            const EdgeInsets.all(
                                                4.0),
                                            child: InkWell(
                                              onTap: () =>
                                                  _showAddDocumentSheet(
                                                      "Documents"),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                        8.0),
                                                    child: AppTextView(
                                                      title:
                                                      "Add Documents",textStyle: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.appPrimary,
                                                        letterSpacing: 0.5
                                                    ),),
                                                  ),
                                                  SvgPicture.asset(
                                                      'assets/icons/add-icon.svg'),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      ..._docWrappers
                                          .map((wrapper) => Padding(
                                        padding:
                                        const EdgeInsets
                                            .only(
                                            bottom: 16.0),
                                        child: DocumentWrapperWidget(wrapper: wrapper),
                                      )),
                                    ],
                                  ),
                                )
                                : Form(
                              key: _form3Key,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      AppTextView(
                                        title: "Courses",textStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appPrimary,
                                          letterSpacing: 0.5
                                      ),),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            4.0),
                                        child: InkWell(
                                          onTap: () => _showAddDocumentSheet(
                                              "Courses"),

                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    horizontal:
                                                    8.0),
                                                child: AppTextView(
                                                  title:
                                                  "Add Courses",textStyle: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.appPrimary,
                                                    letterSpacing: 0.5
                                                ),),
                                              ),
                                              SvgPicture.asset(
                                                  'assets/icons/add-icon.svg'),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  _certificateWrapperList.isEmpty?Center(child: Text("No Courses Found"),): ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: _certificateWrapperList.length,
                                    itemBuilder:
                                        (context, index) =>
                                        // Padding(
                                        //   padding:
                                        //   const EdgeInsets.only(
                                        //       top: 8.0,
                                        //       bottom: 0),
                                        //   child: Container(
                                        //     width: 240,
                                        //     decoration: BoxDecoration(
                                        //         borderRadius:
                                        //         BorderRadius
                                        //             .circular(8)),
                                        //     child: Padding(
                                        //       padding:
                                        //       const EdgeInsets
                                        //           .only(
                                        //           bottom: 16.0),
                                        //       child: Row(
                                        //         mainAxisAlignment:
                                        //         MainAxisAlignment
                                        //             .spaceBetween,
                                        //         children: [
                                        //           AppTextFormField(
                                        //             controller: _certificateWrapperList[index]
                                        //                 .numberController,
                                        //             width: MediaQuery
                                        //                 .sizeOf(
                                        //                 context)
                                        //                 .width *
                                        //                 0.43,
                                        //             label:
                                        //             _certificateWrapperList[index].name,
                                        //             hint:
                                        //             "Enter ${_certificateWrapperList[index].name} number",
                                        //           ),
                                        //           AppDatePicker(
                                        //             controller: _certificateWrapperList[index]
                                        //                 .expiryController,
                                        //             width: MediaQuery
                                        //                 .sizeOf(
                                        //                 context)
                                        //                 .width *
                                        //                 0.43,
                                        //             label:
                                        //             "${_certificateWrapperList[index].name} Expiry",
                                        //             firstDate:
                                        //             DateTime(
                                        //                 1900),
                                        //             lastDate:
                                        //             DateTime(
                                        //                 2100),
                                        //             onDateSelected:
                                        //                 (date) {
                                        //               // You can format the date to string here as needed for your entity
                                        //               _certificateWrapperList[index].expiryController
                                        //                   .text =
                                        //               "${date.day}/${date.month}/${date.year}";
                                        //             },
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        CourseWrapperWidget(wrapper: _certificateWrapperList[index],),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Positioned Stepper and Buttons
                  Positioned(
                    top: 60,
                    right: 0,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: kToolbarHeight,
                      child: StepProgress(
                        totalSteps: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        controller: _stepProgressController,
                        onStepChanged: (currentIndex) {
                          setState(() {
                            currentStep = currentIndex;
                          });
                        },
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 40,
                      left: 16,
                      right: 16,
                      child: AppButton(
                        onTap: () {
                          log("ON TAP NEXT BUTTON");
                          log("CURRENT STEP:${currentStep}");
                          log("CURRENT PAGE:${_currentPage}");
                          //page change function
                          switch (_currentPage) {
                            case 0:
                              if (_form1Key.currentState!.validate()) {
                                context.read<ProfileBloc>().add(
                                    UpdatePersonalDetailsEvent(
                                        PersonalDetails(
                                          firstname: _firstNameTextController.text,
                                          lastname: _lastNameTextController.text,
                                          dob: _dobTextController.text,
                                          nationality:
                                          _nationalityTextController.text,
                                          profilePic: '',
                                          postAppliedFor: _postTextController.text,
                                          fatherName:
                                          _fatherNameTextController.text,
                                        )));
                                setState(_stepProgressController.nextStep);
                              }
                            case 1:
                              if (_form2Key.currentState!.validate()) {
                                List<Document> documentsToSave = _docWrappers
                                    .map((w) => w.toEntity())
                                    .toList();
                                log("LOG STATE IS :${state}");
                                // Trigger your BLoC event
                                context.read<ProfileBloc>().add(
                                  UpdateDocumentsEvent(documentsToSave),
                                );
                                setState(_stepProgressController.nextStep);
                              }
                            case 2:
                              if (_form3Key.currentState!.validate()) {
                                List<Course> course = _certificateWrapperList
                                    .map((w) => w.toEntity())
                                    .toList();
                                context.read<ProfileBloc>().add(
                                  UpdateCoursesEvent(course),
                                );
                              }
                          }
                        },
                          title: _currentPage == 2 ? "Done" : "Next")),

                  // Loading Indicator Overlay
                  if (state is ProfileLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
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
                // if (nameCtrl.text.isNotEmpty) {
                //   switch (type) {
                //     case "Documents":
                //       setState(() {
                //         _docWrappers.add(
                //           ProfileControllerWrapper(name: nameCtrl.text),
                //         );
                //       });
                //       break;
                //     case "Certificate":
                //       setState(() {
                //         _certificateWrapperList.add(
                //           ProfileControllerWrapper(name: nameCtrl.text),
                //         );
                //       });
                //   }
                //   Navigator.pop(context);
                // }
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
}

class DocumentWrapperWidget extends StatelessWidget {
  final ProfileControllerWrapper wrapper;
  const DocumentWrapperWidget({
    super.key,
    required this.wrapper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: AppTextView(title: wrapper.name.capitalize(), textStyle:  const TextStyle(fontSize: 16,color: AppColors.appPrimary, fontWeight: FontWeight.w600),),
        ),
        AppTextFormField(
          controller: wrapper
              .numberController,
          width: MediaQuery
                      .sizeOf(
                          context)
                  .width,
          label:
              "${wrapper.name.capitalize()} Number",
          hint:
              "Enter ${wrapper.name} number",
          validator: (value) => AppValidators.required(value,'${wrapper.name.capitalize()} number'),
        ),
        AppDatePicker(
          controller: wrapper
              .expiryController,
          width: MediaQuery
                      .sizeOf(
                          context)
                  .width,
          label:
              "${wrapper.name.capitalize()} Validity",
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
          validator: (value) => AppValidators.required(value,'${wrapper.name} validity'),
        ),
        AppTextFormField(
          controller: wrapper
              .issuePlaceController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Issued Place",
          hint:
          "Enter your ${wrapper.name} issued place",
          validator: (value) => AppValidators.required(value,'${wrapper.name.capitalize()} issued place'),
        ),
        AppDatePicker(
          controller: wrapper
              .issueDateController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Issued Date",
          firstDate:
          DateTime(
              1900),
          lastDate:
          DateTime(
              2100),
          onDateSelected:
              (date) {
            // You can format the date to string here as needed for your entity
            wrapper.issueDateController
                .text =
            "${date.day}/${date.month}/${date.year}";
          },
          validator: (value) => AppValidators.required(value,'${wrapper.name.capitalize()} issued date'),
        ),
        SizedBox(height: 16,),
      ],
    );
  }
}

class CourseWrapperWidget extends StatelessWidget {
  final ProfileCourseControllerWrapper wrapper;
  const CourseWrapperWidget({
    super.key,
    required this.wrapper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: AppTextView(title: wrapper.name.capitalize(), textStyle:  const TextStyle(fontSize: 16,color: AppColors.appPrimary, fontWeight: FontWeight.w600),),
        ),
        AppTextFormField(
          controller: wrapper
              .numberController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Number",
          hint:
          "Enter ${wrapper.name} number",
          textInputType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          validator: (value) => AppValidators.required(value,wrapper.name),
        ),
        AppDatePicker(
          controller: wrapper
              .expiryController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Validity",
          validator: (value) => AppValidators.required(value,'${wrapper.name.capitalize()} validity'),
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
        AppTextFormField(
          controller: wrapper
              .issuePlaceController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Issued Place",
          hint:
          "Enter your ${wrapper.name} issued place",
          validator: (value) => AppValidators.required(value,'${wrapper.name} issued Place'),
        ),
        AppDatePicker(
          controller: wrapper
              .issueDateController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Issued Date",
          validator: (value) => AppValidators.required(value,'${wrapper.name.capitalize()} issued date'),
          firstDate:
          DateTime(
              1900),
          lastDate:
          DateTime(
              2100),
          onDateSelected:
              (date) {
            // You can format the date to string here as needed for your entity
            wrapper.issueDateController
                .text =
            "${date.day}/${date.month}/${date.year}";
          },
        ),
        SizedBox(height: 16,),
      ],
    );
  }
}
