import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/services/app_permission_service.dart';
import 'package:seafarer_bio_data/core/utils/app_validators.dart';
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
import 'package:seafarer_bio_data/widgets/not_found_widget.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _dobTextController = TextEditingController();
  final TextEditingController _nationalityTextController = TextEditingController();
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _fatherNameTextController = TextEditingController();

  late ProfileBloc profileBloc;
  late ProfileLoaded profileLoadedState;
  List<ProfileControllerWrapper> _docWrappers = [];
  List<ProfileCourseControllerWrapper> _certificateWrapperList = [];
  List<SeaExperienceControllerWrapper> _seaExperienceList = [];

  List<SeaExperienceControllerWrapper> get seaExperienceList => _seaExperienceList;

  late PersonalDetails personalDetails;

  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  String base64Image = "";
  Uint8List base64Decoded = Uint8List(0);

  @override
  void initState() {
    profileBloc = context.read<ProfileBloc>();
    profileLoadedState = profileBloc.state as ProfileLoaded;

    super.initState();
    bindProfileData();
  }

  @override
  void dispose() {
    _firstNameTextController.dispose();
    _lastNameTextController.dispose();
    _dobTextController.dispose();
    _nationalityTextController.dispose();
    _postTextController.dispose();
    _fatherNameTextController.dispose();
    for (final wrapper in _docWrappers) {
      wrapper.dispose();
    }
    for (final wrapper in _certificateWrapperList) {
      wrapper.dispose();
    }
    for (final wrapper in _seaExperienceList) {
      wrapper.dispose();
    }
    super.dispose();
  }

  void _calculatePeriod(SeaExperienceControllerWrapper wrapper) {
    if (wrapper.fromDateController.text.isNotEmpty &&
        wrapper.toDateController.text.isNotEmpty) {
      try {
        List<String> fromParts = wrapper.fromDateController.text.split('.');
        List<String> toParts = wrapper.toDateController.text.split('.');

        DateTime from = DateTime(
          int.parse(fromParts[2]),
          int.parse(fromParts[1]),
          int.parse(fromParts[0]),
        );
        DateTime to = DateTime(
          int.parse(toParts[2]),
          int.parse(toParts[1]),
          int.parse(toParts[0]),
        );

        if (to.isAfter(from)) {
          int months = (to.year - from.year) * 12 + (to.month - from.month);
          if (to.day < from.day) {
            months--;
          }
          wrapper.periodController.text = months < 0 ? "0" : months.toString();
        } else {
          wrapper.periodController.text = "0";
        }
        setState(() {});
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
          _pickedImagePath = pickedFile.path;
        }
      });
      log("PATH:$_pickedImagePath");
      final imageUpload = await uploadImage(userId, _pickedImagePath.toString());
      log("IMAGE UPLOAD:$imageUpload");
    } catch (e) {
      log("Pick image error: $e");
    }
  }

  Future<String> uploadImage(String userId, String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    base64Image = base64Encode(bytes);
    log("BASE64Image:$base64Image");
    return base64Image;
  }

  void bindProfileData() {
    personalDetails = profileLoadedState.profile.personalDetails;
    _firstNameTextController.text =
        profileLoadedState.profile.personalDetails.firstname;
    _lastNameTextController.text =
        profileLoadedState.profile.personalDetails.lastname;
    _dobTextController.text = profileLoadedState.profile.personalDetails.dob;
    _nationalityTextController.text =
        profileLoadedState.profile.personalDetails.nationality;
    _postTextController.text =
        profileLoadedState.profile.personalDetails.postAppliedFor;
    _fatherNameTextController.text =
        profileLoadedState.profile.personalDetails.fatherName;
    base64Image = profileLoadedState.profile.personalDetails.profilePic;
    if (base64Image.isNotEmpty) {
      try {
        base64Decoded = base64Decode(base64Image);
      } catch (_) {
        base64Decoded = Uint8List(0);
      }
    }

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

    _seaExperienceList = profileLoadedState.profile.seaExperiences.map((e) {
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
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Bio Data",
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryContainer,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFEAE6DF),
            height: 1,
          ),
        ),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppTextView(
                  title: 'Profile Updated Successfully',
                  textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 14,
                        color: AppColors.appSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                backgroundColor: AppColors.appTextColor,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                ),
              );
            }

            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }

            if (state is ProfileLoaded) {
              final profile = state.profile;
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- PERSONAL INFORMATION CARD ---
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
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppTextFormField(
                                          label: "Post Applied For",
                                          hint: "enter your post",
                                          controller: _postTextController,
                                          validator: (value) =>
                                              AppValidators.post(value),
                                        ),
                                        AppTextFormField(
                                          label: "First name",
                                          hint: "enter your first name",
                                          controller: _firstNameTextController,
                                          validator: (value) =>
                                              AppValidators.name(value),
                                        ),
                                        AppTextFormField(
                                          label: "Last name",
                                          hint: "enter your last name",
                                          controller: _lastNameTextController,
                                          validator: (value) =>
                                              AppValidators.name(value),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 14.0, top: 4),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 120,
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F3F0),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: const Color(0xFFEAE6DF)),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: _pickedImagePath != null
                                              ? Image.file(
                                                  File(_pickedImagePath!),
                                                  fit: BoxFit.cover,
                                                )
                                              : base64Decoded.isNotEmpty
                                                  ? Image.memory(
                                                      base64Decoded,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                        child: AppTextView(
                                                          title: 'No Photo',
                                                          textStyle:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'Plus Jakarta Sans',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .outline,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () async {
                                              var permissionGranted =
                                                  await AppPermissionService
                                                      .requestPhotosPermission();
                                              if (permissionGranted) {
                                                fetchImage(profile.userId);
                                              }
                                            },
                                            child: Container(
                                              height: 36,
                                              width: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFEAE6DF),
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0x1F0B1F3A),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    'assets/icons/camera-add.svg',
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              AppTextFormField(
                                label: "Father's Name",
                                hint: "enter your father's name",
                                controller: _fatherNameTextController,
                                validator: (value) => AppValidators.name(value),
                              ),
                              AppTextFormField(
                                label: "Date of Birth",
                                hint: "enter your dob",
                                controller: _dobTextController,
                                validator: (value) => AppValidators.dob(value),
                              ),
                              AppTextFormField(
                                label: "Nationality",
                                hint: "enter you nationality",
                                controller: _nationalityTextController,
                                validator: (value) =>
                                    AppValidators.nationality(value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- DOCUMENTS TABLE SECTION ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                _showAddDocumentSheet('Documents');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SvgPicture.asset(
                                  'assets/icons/add-icon.svg',
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._docWrappers.map(
                          (wrapper) => DocumentWrapperWidget(
                            wrapper: wrapper,
                            onDelete: () {
                              setState(() {
                                _docWrappers.removeAt(
                                    _docWrappers.indexOf(wrapper));
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- COURSES / CERTIFICATES SECTION ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                _showAddDocumentSheet('Courses');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SvgPicture.asset(
                                  'assets/icons/add-icon.svg',
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._certificateWrapperList.map(
                          (wrapper) => CourseWrapperWidget(
                            wrapper: wrapper,
                            onDelete: () {
                              setState(() {
                                _certificateWrapperList.removeAt(
                                    _certificateWrapperList.indexOf(wrapper));
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- WORK HISTORY SECTION ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const AppTextView(
                                  title: "Sea Experience",
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
                            InkWell(
                              onTap: () {
                                _showAddExperienceSheet(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SvgPicture.asset(
                                  'assets/icons/add-icon.svg',
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        seaExperienceList.isEmpty
                            ? const NotFoundWidget(
                                title: 'Not Found',
                                desc:
                                    'No Sea Experience, please add your experience by clicking add button',
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: seaExperienceList.length,
                                itemBuilder: (context, index) =>
                                    SeaExperienceWidget(
                                  seaExperienceControllerWrapper:
                                      seaExperienceList[index],
                                  onDelete: () {
                                    setState(() {
                                      seaExperienceList.removeAt(index);
                                    });
                                  },
                                  onEdit: () {
                                    _showAddExperienceSheet(
                                      context,
                                      existingWrapper: seaExperienceList[index],
                                    );
                                  },
                                ),
                              ),
                        const SizedBox(height: 36),
                        Align(
                          alignment: Alignment.center,
                          child: AppButton(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ProfileBloc>().add(
                                      UpdateFullProfileEvent(
                                        personalDetails: PersonalDetails(
                                          postAppliedFor:
                                              _postTextController.text,
                                          firstname:
                                              _firstNameTextController.text,
                                          lastname:
                                              _lastNameTextController.text,
                                          fatherName:
                                              _fatherNameTextController.text,
                                          dob: _dobTextController.text,
                                          nationality:
                                              _nationalityTextController.text,
                                          profilePic: base64Image,
                                        ),
                                        documents: _docWrappers
                                            .map((w) => w.toEntity())
                                            .toList(),
                                        courses: _certificateWrapperList
                                            .map((w) => w.toEntity())
                                            .toList(),
                                        seaExperiences: seaExperienceList
                                            .map((w) => w.toEntity())
                                            .toList(),
                                      ),
                                    );
                              }
                            },
                            title: "Save Changes",
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
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
          _certificateWrapperList
              .add(ProfileCourseControllerWrapper(name: name.trim()));
        });
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
                Expanded(
                  child: AppTextView(
                    title: "Add New $type Type",
                    textStyle: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryContainer,
                    ),
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

  void _showAddExperienceSheet(BuildContext context,
      {SeaExperienceControllerWrapper? existingWrapper}) {
    final isEditing = existingWrapper != null;
    final wrapper = existingWrapper ?? SeaExperienceControllerWrapper();

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
          top: 16,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
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
                  Expanded(
                    child: AppTextView(
                      title: isEditing
                          ? "Edit Sea Experience"
                          : "Add Sea Experience",
                      textStyle: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgPicture.asset('assets/icons/close-square.svg'),
                    ),
                  ),
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
                        wrapper.fromDateController.text =
                            "${date.day}.${date.month}.${date.year}";
                        _calculatePeriod(wrapper);
                        setState(() {});
                      },
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDatePicker(
                      controller: wrapper.toDateController,
                      label: "To",
                      onDateSelected: (date) {
                        wrapper.toDateController.text =
                            "${date.day}.${date.month}.${date.year}";
                        _calculatePeriod(wrapper);
                        setState(() {});
                      },
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
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
                  const AppTextView(
                    title: "Period:",
                    textStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: AppTextView(
                      title: "${wrapper.periodController.text} (in months)",
                      textStyle: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Action Button
              Align(
                alignment: Alignment.center,
                child: AppButton(
                  title: isEditing ? "Edit Sea Experience" : "Add Experience",
                  onTap: () {
                    if (!isEditing) {
                      setState(() {
                        seaExperienceList.add(wrapper);
                      });
                    } else {
                      setState(() {});
                    }
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFEAE6DF),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0B1F3A),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ship Name",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.outline,
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.edit_note,
                            color: AppColors.secondary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.delete_outline,
                            color: Color(0xFFBA1A1A),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                seaExperienceControllerWrapper.vesselNameController.text,
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Type",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          seaExperienceControllerWrapper
                              .vesselTypeController.text,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Rank",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          seaExperienceControllerWrapper.rankController.text,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "From",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          seaExperienceControllerWrapper
                              .fromDateController.text,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "To",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          seaExperienceControllerWrapper.toDateController.text,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}