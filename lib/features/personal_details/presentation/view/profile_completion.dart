import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/app_validators.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_course_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/widgets/course_wrapper_widget.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/widgets/document_wrapper_widget.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';
import 'package:seafarer_bio_data/widgets/app_date_picker.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';
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
  final TextEditingController _nationalityTextController = TextEditingController();
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _fatherNameTextController = TextEditingController();

  final PageController _controller = PageController(initialPage: 0);
  final StepProgressController _stepProgressController = StepProgressController(
    totalSteps: 3,
  );
  final ScrollController _scrollController = ScrollController();
  final FocusNode _postFocusNode = FocusNode();

  int currentStep = 0;
  int _currentPage = 0;

  final List<ProfileControllerWrapper> _docWrappers = [];
  final List<ProfileCourseControllerWrapper> _certificateWrapperList = [];

  static const List<String> _stepNames = [
    'Personal Information',
    'Documents',
    'Courses',
  ];

  @override
  void initState() {
    super.initState();
    _postFocusNode.addListener(() {
      if (_postFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _currentPage && mounted) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameTextController.dispose();
    _lastNameTextController.dispose();
    _dobTextController.dispose();
    _nationalityTextController.dispose();
    _postTextController.dispose();
    _fatherNameTextController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _postFocusNode.dispose();
    for (final wrapper in _docWrappers) {
      wrapper.dispose();
    }
    for (final wrapper in _certificateWrapperList) {
      wrapper.dispose();
    }
    super.dispose();
  }

  void bindData(Profile profile) {
    _firstNameTextController.text = profile.personalDetails.firstname;
    _lastNameTextController.text = profile.personalDetails.lastname;
    if (mounted) {
      setState(() {});
    }
  }

  void _addNewDocument(String title, String name) {
    if (name.trim().isEmpty) return;
    switch (title) {
      case "Documents":
        setState(() {
          _docWrappers.add(ProfileControllerWrapper(name: name.trim()));
        });
        break;
      case "Courses":
        setState(() {
          _certificateWrapperList.add(ProfileCourseControllerWrapper(name: name.trim()));
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) async {
            if (state is CertificateUpdateSuccess) {
              await PreferenceService.setProfileCompleted(true);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (_) => false,
                );
                context.read<ProfileBloc>().add(
                      LoadProfile(PreferenceService.userId.toString()),
                    );
              }
            }

            if (state is PersonalDetailsUpdateSuccess ||
                state is DocumentsUpdateSuccess) {
              if (_controller.hasClients) {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            }

            if (state is ProfileLoaded) {
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
                    Column(
                      children: [
                        // --- Header Area ---
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'OFFICER DOSSIER ENROLLMENT',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Step ${_currentPage + 1} of 3',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _stepNames[_currentPage],
                                style: const TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: StepProgress(
                                  totalSteps: 3,
                                  padding: EdgeInsets.zero,
                                  controller: _stepProgressController,
                                  onStepChanged: (currentIndex) {
                                    setState(() {
                                      currentStep = currentIndex;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- PageView Content ---
                        Expanded(
                          child: Opacity(
                            opacity: state is ProfileLoading ? 0.5 : 1.0,
                            child: IgnorePointer(
                              ignoring: state is ProfileLoading,
                              child: PageView.builder(
                                controller: _controller,
                                itemCount: 3,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return SingleChildScrollView(
                                    controller:
                                        index == 0 ? _scrollController : null,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 8, 16, 96),
                                    child: index == 0
                                        ? _buildPersonalDetailsStep()
                                        : index == 1
                                            ? _buildDocumentsStep()
                                            : _buildCoursesStep(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- Sticky Bottom Action Bar ---
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: AppButton(
                          onTap: _onNextTapped,
                          title: _currentPage == 2 ? "Done" : "Next",
                        ),
                      ),
                    ),

                    // --- Loading Indicator Overlay ---
                    if (state is ProfileLoading)
                      Container(
                        color: Colors.black.withValues(alpha: 0.15),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsStep() {
    return Form(
      key: _form1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEAE6DF),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A0B1F3A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const AppTextView(
                      title: "Personal Information",
                      textStyle: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your official maritime biographical identity',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.5,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextFormField(
                  label: "First Name",
                  hint: "enter your first name",
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  controller: _firstNameTextController,
                  validator: (value) => AppValidators.name(value),
                ),
                AppTextFormField(
                  label: "Last Name",
                  hint: "enter your last name",
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  controller: _lastNameTextController,
                  validator: (value) => AppValidators.name(value),
                ),
                AppTextFormField(
                  label: "Post Applied For",
                  hint: "enter your post",
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  controller: _postTextController,
                  validator: (value) => AppValidators.post(value),
                ),
                AppTextFormField(
                  label: "Father's Name",
                  hint: "enter your father's name",
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  controller: _fatherNameTextController,
                  validator: (value) => AppValidators.name(value),
                ),
                AppDatePicker(
                  controller: _dobTextController,
                  width: double.infinity,
                  label: "Date of Birth",
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2003),
                  onDateSelected: (date) {
                    _dobTextController.text =
                        "${date.day}/${date.month}/${date.year}";
                  },
                  validator: (value) => AppValidators.dob(value),
                ),
                AppTextFormField(
                  label: "Nationality",
                  hint: "enter you nationality",
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  controller: _nationalityTextController,
                  validator: (value) => AppValidators.name(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return Form(
      key: _form2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppTextView(
                title: "Documents",
                textStyle: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryContainer,
                  letterSpacing: 0.3,
                ),
              ),
              InkWell(
                onTap: () => _showAddDocumentSheet("Documents"),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      const AppTextView(
                        title: "Add Documents",
                        textStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        'assets/icons/add-icon.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_docWrappers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEAE6DF),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 40,
                    color: AppColors.outline,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No Documents Added',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap "+ Add Documents" to register Passport, CDC, or Visas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._docWrappers.map(
              (wrapper) => DocumentWrapperWidget(
                wrapper: wrapper,
                onDelete: () {
                  setState(() {
                    _docWrappers.remove(wrapper);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoursesStep() {
    return Form(
      key: _form3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppTextView(
                title: "Courses",
                textStyle: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryContainer,
                  letterSpacing: 0.3,
                ),
              ),
              InkWell(
                onTap: () => _showAddDocumentSheet("Courses"),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      const AppTextView(
                        title: "Add Courses",
                        textStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        'assets/icons/add-icon.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_certificateWrapperList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEAE6DF),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  "No Courses Found",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: AppColors.outline,
                  ),
                ),
              ),
            )
          else
            ..._certificateWrapperList.map(
              (wrapper) => CourseWrapperWidget(
                wrapper: wrapper,
                onDelete: () {
                  setState(() {
                    _certificateWrapperList.remove(wrapper);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  void _onNextTapped() {
    log("ON TAP NEXT BUTTON - Step: $currentStep, Page: $_currentPage");
    switch (_currentPage) {
      case 0:
        if (_form1Key.currentState!.validate()) {
          context.read<ProfileBloc>().add(
                UpdatePersonalDetailsEvent(
                  PersonalDetails(
                    firstname: _firstNameTextController.text,
                    lastname: _lastNameTextController.text,
                    dob: _dobTextController.text,
                    nationality: _nationalityTextController.text,
                    profilePic: '',
                    postAppliedFor: _postTextController.text,
                    fatherName: _fatherNameTextController.text,
                  ),
                ),
              );
          setState(_stepProgressController.nextStep);
        }
        break;
      case 1:
        if (_form2Key.currentState!.validate()) {
          final documentsToSave =
              _docWrappers.map((w) => w.toEntity()).toList();
          context.read<ProfileBloc>().add(
                UpdateDocumentsEvent(documentsToSave),
              );
          setState(_stepProgressController.nextStep);
        }
        break;
      case 2:
        if (_form3Key.currentState!.validate()) {
          final courses =
              _certificateWrapperList.map((w) => w.toEntity()).toList();
          context.read<ProfileBloc>().add(
                UpdateCoursesEvent(courses),
              );
        }
        break;
    }
  }

  void _showAddDocumentSheet(String type) {
    final TextEditingController nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 20,
          right: 20,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D4CC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppTextView(
                  title: "Add New $type Type",
                  textStyle: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryContainer,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.outline),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: nameCtrl,
              label: "$type Name",
              hint: "Enter your document name",
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  _addNewDocument(type, nameCtrl.text);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Add to List",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
