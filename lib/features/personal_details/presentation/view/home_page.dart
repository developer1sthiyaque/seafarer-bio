import 'dart:convert';
import 'dart:developer';

import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/pdf/profile_pdf_builder.dart';
import 'package:seafarer_bio_data/core/services/docx_export_service.dart';
import 'package:seafarer_bio_data/core/services/file_save_service.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/core/di/injection_container.dart';
import 'package:seafarer_bio_data/core/services/revenuecat_service.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';
import 'package:seafarer_bio_data/widgets/app_text_with_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/widgets/profile_subscription_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "My Bio Data",
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryContainer,
            ),
          ),
        ),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () async {
                  if (state is ProfileLoaded) {
                    await ProfilePdfBuilder.generateAndSave(
                      profile: state.profile,
                    );
                  }
                },
                child: SvgPicture.asset(
                  'assets/icons/pdf_icon.svg',
                  height: 20,
                  width: 20,
                ),
              ),
            ),
          ),
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, subscriptionState) {
              return BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: () async {
                        if (profileState is ProfileLoaded) {
                          bool isPremium =
                              subscriptionState is SubscriptionActive;

                          // Directly check active entitlements via RevenueCat SDK
                          if (!isPremium &&
                              sl.isRegistered<RevenueCatService>()) {
                            try {
                              final rcService = sl<RevenueCatService>();
                              final customerInfo =
                                  await rcService.getCustomerInfo();
                              if (rcService.isProSubscriber(customerInfo)) {
                                isPremium = true;
                                if (context.mounted && customerInfo != null) {
                                  context.read<SubscriptionBloc>().add(
                                        CustomerInfoUpdated(customerInfo),
                                      );
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                  'Error checking RevenueCat entitlements directly: $e');
                            }
                          }

                          if (isPremium) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Generating DOCX...'),
                              ),
                            );

                            try {
                              final bytes =
                                  await DocxExportService.generateSeafarerDocx(
                                profileState.profile,
                                isSubscribed: isPremium,
                              );
                              final fileName =
                                  'Seafarer_Biodata_${profileState.profile.personalDetails.lastname}.docx';

                              await FileSaveService.saveAndOpen(
                                bytes: bytes,
                                fileName: fileName,
                              );
                            } on PremiumRequiredException {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'DOCX Export is a Pro feature. Please subscribe to unlock.',
                                  ),
                                  action: SnackBarAction(
                                    label: 'Upgrade',
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.subscription,
                                      );
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Export failed: $e'),
                                ),
                              );
                            }
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'DOCX Export is a Pro feature. Please subscribe to unlock.',
                                ),
                                action: SnackBarAction(
                                  label: 'Upgrade',
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.subscription,
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: SvgPicture.asset(
                        'assets/icons/file_doc.svg',
                        colorFilter: ColorFilter.mode(
                          (subscriptionState is SubscriptionActive)
                              ? AppColors.primary
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, subscriptionState) {
              final isPremium = subscriptionState is SubscriptionActive;
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
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppColors.secondary,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              child: SvgPicture.asset(
                'assets/icons/edit.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          BlocConsumer<AuthBloc, AuthState>(
            builder: (context, state) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                },
                child: const Icon(
                  Icons.logout,
                  color: AppColors.primary,
                ),
              ),
            ),
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is Authenticated) {
            final userId = state.user.uid;
            log("USER ID:$userId");
            context.read<ProfileBloc>().add(LoadProfile(userId));
          }
        },
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) async {
            if (state is ProfileLoaded) {
              await PreferenceService.setProfileCompleted(
                state.profile.isProfileCompleted,
              );
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
                final decodeImage =
                    base64Decode(profile.personalDetails.profilePic);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PERSONAL INFORMATION SECTION (Hero Folio Card) ---
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A0B1F3A),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppTextWithLabel(
                                        label: "Post Applied For",
                                        title: profile
                                            .personalDetails.postAppliedFor,
                                      ),
                                      AppTextWithLabel(
                                        label: "First Name",
                                        title: profile
                                            .personalDetails.firstname,
                                      ),
                                      AppTextWithLabel(
                                        label: "Last Name",
                                        title:
                                            profile.personalDetails.lastname,
                                      ),
                                      AppTextWithLabel(
                                        label: "Father's Name",
                                        title:
                                            profile.personalDetails.fatherName,
                                      ),
                                      AppTextWithLabel(
                                        label: "Date of Birth",
                                        title: profile.personalDetails.dob,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Profile Image / Placeholder
                                profile.personalDetails.profilePic.isNotEmpty
                                    ? Container(
                                        width: 100,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppColors.outlineVariant,
                                          ),
                                          image: DecorationImage(
                                            image: MemoryImage(decodeImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 100,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppColors.outlineVariant,
                                          ),
                                          color: AppColors.surfaceContainerLow,
                                        ),
                                        child: Center(
                                          child: AppTextView(
                                            title: 'No Photo',
                                            textStyle: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            AppTextWithLabel(
                              label: "Nationality",
                              title: profile.personalDetails.nationality,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- DOCUMENTS TABLE SECTION ---
                      Row(
                        children: [
                          Container(
                            width: 3.5,
                            height: 16,
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
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            border: TableBorder.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.4),
                            ),
                            defaultColumnWidth:
                                const IntrinsicColumnWidth(),
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
                      ),

                      const SizedBox(height: 20),

                      // --- COURSES / CERTIFICATES SECTION ---
                      Row(
                        children: [
                          Container(
                            width: 3.5,
                            height: 16,
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
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            border: TableBorder.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.4),
                            ),
                            defaultColumnWidth:
                                const IntrinsicColumnWidth(),
                            children: [
                              _buildTableHeader([
                                'Course',
                                'Number',
                                'Date of issue',
                                'Place of issue',
                                'Validity',
                              ]),
                              ...profile.courses.map(
                                (e) => _buildTableRow([
                                  e.title,
                                  e.number,
                                  e.issueDate,
                                  e.place,
                                  e.validity,
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- WORK HISTORY SECTION ---
                      Row(
                        children: [
                          Container(
                            width: 3.5,
                            height: 16,
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
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            border: TableBorder.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.4),
                            ),
                            defaultColumnWidth:
                                const IntrinsicColumnWidth(),
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
                                'Period',
                              ]),
                              ...profile.seaExperiences.map(
                                (e) => _buildTableRow([
                                  e.vesselName,
                                  e.companyName,
                                  e.vesselType,
                                  e.grt,
                                  e.bhp,
                                  e.rank,
                                  e.from,
                                  e.to,
                                  e.period,
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- SUBSCRIPTION & ACCOUNT DETAILS ---
                      ProfileSubscriptionCard(profile: profile),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // Helper method for Table Headers
  TableRow _buildTableHeader(List<String> labels) {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.surfaceContainerLow),
      children: labels
          .map((label) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ))
          .toList(),
    );
  }

  // Helper method for Table Rows
  TableRow _buildTableRow(List<String> values) {
    return TableRow(
      children: values
          .map((val) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                child: Text(
                  val,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
