import 'dart:convert';
import 'dart:developer';

import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/pdf/profile_pdf_builder.dart';
import 'package:seafarer_bio_data/core/services/app_permission_service.dart';
import 'package:seafarer_bio_data/core/services/docx_export_service.dart';
import 'package:seafarer_bio_data/core/services/file_save_service.dart';
import 'package:seafarer_bio_data/core/services/pdf_download_service.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/edit_details.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/pdf_preview.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';
import 'package:seafarer_bio_data/widgets/app_text_with_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
        child: Text("My Bio Data")),
        actions: [
          BlocBuilder<ProfileBloc,ProfileState>(builder: (context, state) => Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
                onTap: () async{
                  if(state is ProfileLoaded){
                    await ProfilePdfBuilder.generateAndSave(profile: state.profile);
                  }

                  // if(state is ProfileLoaded){
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => PdfPreviewPage(profile: state.profile,),
                  //       ));
                  // }
                  ///DOWNLOAD PDF to device
                  ///CHECK STORAGE PERMISSION ios && android
                  ///create an common app_permission class, which will have all type of permission, storage, image, document, for both ios and android
                  /// 1. Ask permission
                  // final hasPermission =
                  //     await AppPermissionService.requestStoragePermission();
                  // print('Storage permission ${hasPermission}');
                  // if (!hasPermission) {
                  //   // Show dialog or snackbar
                  //   print('Storage permission denied');
                  //   return;
                  // }

                  /// 2. Download PDF
                  // await PdfDownloadService.downloadAndSavePdf(
                  //   url: 'https://example.com/sample.pdf',
                  //   fileName: 'invoice.pdf',
                  // );
                },
                child: SvgPicture.asset('assets/icons/pdf_icon.svg',height: 24,width: 24,)),
          ),),
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, subscriptionState) {
              return BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: () async {
                        if (profileState is ProfileLoaded) {
                          final isPremium =
                              subscriptionState is SubscriptionActive ||
                                  profileState.profile.isPremiumPaid;

                          if (isPremium) {
                            // Show loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Generating DOCX...')),
                            );

                            final bytes =
                            await DocxExportService.generateSeafarerDocx(
                                profileState.profile);
                            final fileName =
                                'Seafarer_Biodata_${profileState.profile.personalDetails.lastname}.docx';

                            await FileSaveService.saveAndOpen(
                              bytes: bytes,
                              fileName: fileName,
                            );
                          } else {
                            // Show premium message or navigate to subscription screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'DOCX Export is a Pro feature. Please subscribe to unlock.'),
                                action: SnackBarAction(
                                  label: 'Upgrade',
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.subscription);
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Icon(
                        Icons.description, // Using a generic doc icon for now
                        color: ((subscriptionState is SubscriptionActive) ||
                            (profileState is ProfileLoaded &&
                                profileState.profile.isPremiumPaid))
                            ? AppColors.appPrimary
                            : Colors.grey,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, subscriptionState) {
              return BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  final isPremium = subscriptionState is SubscriptionActive ||
                      (profileState is ProfileLoaded &&
                          profileState.profile.isPremiumPaid);
                  if (!isPremium) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: () async {
                        await RevenueCatUI.presentCustomerCenter();
                        if (context.mounted) {
                          context.read<SubscriptionBloc>().add(FetchPlans());
                        }
                      },
                      child: const Icon(Icons.workspace_premium,
                          color: Colors.amber),
                    ),
                  );
                },
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.editProfile);
                },
                child: SvgPicture.asset('assets/icons/edit.svg',colorFilter: ColorFilter.mode(AppColors.appScaffold, BlendMode.srcIn),)),
          ),
          BlocConsumer<AuthBloc,AuthState>(builder: (context, state) => Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
                onTap: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                },
                child: Icon(Icons.logout)),
          ), listener: (context, state) {
            if(state is Unauthenticated){
              Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false, // 🔥 removes Home + everything
              );
            }
          },)
        ],
      ),
      body: BlocListener<AuthBloc,AuthState>(listener: (context, state)async {
        if(state is Authenticated){
          final userId=state.user.uid;
          context.read<ProfileBloc>().add(LoadProfile(userId));

        }
      },child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) async{
          if (state is ProfileLoaded) {
            // Perform the async save here
            await PreferenceService.setProfileCompleted(state.profile.isProfileCompleted);
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileError) {
          return Center(child: Text(state.message));
        }
        if (state is ProfileLoaded) {
          final profile = state.profile;
         final decodeImage=base64Decode(profile.personalDetails.profilePic);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PERSONAL INFORMATION SECTION ---
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTextWithLabel(
                                    label: "Post Applied For",
                                    title: profile.personalDetails.postAppliedFor),
                                AppTextWithLabel(
                                    label: "First Name",
                                    title: profile.personalDetails.firstname),
                                AppTextWithLabel(
                                    label: "Last Name",
                                    title: profile.personalDetails.lastname),
                                AppTextWithLabel(
                                    label: "Father's Name", title: profile.personalDetails.fatherName),
                                AppTextWithLabel(
                                    label: "Date of Birth",
                                    title: profile.personalDetails.dob),
                              ],
                            ),
                          ),
                          // Profile Image Placeholder
                          profile.personalDetails.profilePic.isNotEmpty?Container(
                            width: 100,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              image: DecorationImage(
                                image:MemoryImage(decodeImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ):Container(
                            width: 100,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Center(child: AppTextView(title: 'No Photo', textStyle: TextStyle(
                              fontSize: 16,fontWeight: FontWeight.w600,color: AppColors.appTextColor
                            )),),
                          ),
                        ],
                      ),
                      AppTextWithLabel(
                          label: "Nationality", title: profile.personalDetails.nationality),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- DOCUMENTS TABLE SECTION ---
                  const AppTextView(title: "Documents",textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appPrimary,
                      letterSpacing: 0.5
                  ),),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        _buildTableHeader([
                          'Document',
                          'Number',
                          'Date of issue',
                          'Place of issue',
                          'Validity',
                        ]),
                        ...profile.documents.map(
                              (e) => _buildTableRow([
                            e.name,
                            e.number,
                            e.issueDate,
                            e.place,
                            e.validity,
                          ]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- COURSES / CERTIFICATES SECTION ---
                  const AppTextView(title: "Courses",textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appPrimary,
                      letterSpacing: 0.5
                  ),),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        _buildTableHeader(['Course',
                          'Number',
                          'Date of issue',
                          'Place of issue',
                          'Validity',]),
                        ...profile.courses.map((e) => _buildTableRow([e.title, e.number,e.issueDate, e.place, e.validity,]),),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- WORK HISTORY SECTION ---
                  const AppTextView(title: "Sea Experience",textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appPrimary,
                      letterSpacing: 0.5
                  ),),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        _buildTableHeader([
                          'Name of vessel',
                          'Company name',
                          'Type of vessel',
                          'G.R.T',
                          'B.H.P',
                          'Rank',
                          'From',
                          'To',
                          'Period'
                          ]),
                        ...profile.seaExperiences.map((e) => _buildTableRow([e.vesselName, e.companyName,e.vesselType, e.grt, e.bhp,e.rank, e.from, e.to, e.period,]),),
                      ],
                    ),
                  ),
                  // ListView.builder(
                  //   padding: EdgeInsets.zero,
                  //   scrollDirection: Axis.vertical,
                  //   physics: NeverScrollableScrollPhysics(),
                  //   shrinkWrap: true,
                  //   itemCount: profile.seaExperiences.length,
                  //   itemBuilder: (context, index) =>
                  //       Padding(
                  //         padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //         child: Container(
                  //           width: double.maxFinite,
                  //           decoration: BoxDecoration(
                  //             color: AppColors.appPrimary.withOpacity(0.15),
                  //             borderRadius: BorderRadius.circular(12),
                  //             // boxShadow: [
                  //             //   BoxShadow(
                  //             //     color: Colors.white24,
                  //             //     blurRadius: 0.6,
                  //             //     spreadRadius: 6.0
                  //             //   )
                  //             // ]
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(8.0),
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   "Ship Name",
                  //                   style: TextStyle(
                  //                       fontSize: 14,
                  //                       fontWeight: FontWeight.w400,
                  //                       color: Colors.grey),
                  //                 ),
                  //                 Text(
                  //                   profile.seaExperiences[index].vesselName,
                  //                   style:Theme.of(context).textTheme.titleMedium?.copyWith(
                  //                     fontWeight: FontWeight.bold,
                  //                     color: AppColors.appTextColor,
                  //                   ),),
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment
                  //                       .spaceBetween,
                  //                   children: [
                  //                     Column(
                  //                       crossAxisAlignment: CrossAxisAlignment
                  //                           .start,
                  //                       children: [
                  //                         Text(
                  //                           "Type",
                  //                           style: TextStyle(
                  //                               fontSize: 14,
                  //                               fontWeight: FontWeight.w400,
                  //                               color: Colors.grey),
                  //                         ),
                  //                         Text(
                  //                           profile.seaExperiences[index].vesselType,
                  //                           style: TextStyle(
                  //                               fontSize: 16,
                  //                               fontWeight: FontWeight.w600),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                     Column(
                  //                       crossAxisAlignment: CrossAxisAlignment
                  //                           .start,
                  //                       children: [
                  //                         Text(
                  //                           "Rank",
                  //                           style: TextStyle(
                  //                               fontSize: 14,
                  //                               fontWeight: FontWeight.w400,
                  //                               color: Colors.grey),
                  //                         ),
                  //                         Text(
                  //                           profile.seaExperiences[index].rank,
                  //                           style: TextStyle(
                  //                               fontSize: 16,
                  //                               fontWeight: FontWeight.w600),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 SizedBox(
                  //                   height: 16,
                  //                 ),
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment
                  //                       .spaceBetween,
                  //                   children: [
                  //                     Column(
                  //                       crossAxisAlignment: CrossAxisAlignment
                  //                           .start,
                  //                       children: [
                  //                         Text(
                  //                           "From",
                  //                           style: TextStyle(
                  //                               fontSize: 14,
                  //                               fontWeight: FontWeight.w400,
                  //                               color: Colors.grey),
                  //                         ),
                  //                         Text(
                  //                           profile.seaExperiences[index].from,
                  //                           style: TextStyle(
                  //                               fontSize: 16,
                  //                               fontWeight: FontWeight.w600),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                     Column(
                  //                       crossAxisAlignment: CrossAxisAlignment
                  //                           .start,
                  //                       children: [
                  //                         Text(
                  //                           "To",
                  //                           style: TextStyle(
                  //                               fontSize: 14,
                  //                               fontWeight: FontWeight.w400,
                  //                               color: Colors.grey),
                  //                         ),
                  //                         Text(
                  //                           profile.seaExperiences[index].to,
                  //                           style: TextStyle(
                  //                               fontSize: 16,
                  //                               fontWeight: FontWeight.w600),
                  //                         ),
                  //                       ],
                  //                     )
                  //                   ],
                  //                 )
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  // ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }
        return SizedBox();
      },),)),
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
}
