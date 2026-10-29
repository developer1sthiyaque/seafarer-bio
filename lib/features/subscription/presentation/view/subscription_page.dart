import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seafarer_bio_data/core/constants/payment_constants.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_package.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Upgrade to Pro',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryContainer,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryContainer),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            log("SUBSCRIPTION ERROR:${state.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SubscriptionActive) {
            log("SUBSCRIPTION ACTIVE:${state.plan.name}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully Subscribed to ${state.plan.name} Plan!',
                ),
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          List<SubscriptionPackage> plans = [];
          if (state is PlansLoaded) {
            plans = state.plans;
          } else if (state is SubscriptionInitial ||
              state is SubscriptionError) {
            plans = SubscriptionPackage.staticPlans;
          }

          final cancellationPlatformText = Platform.isIOS
              ? 'Cancel anytime in Apple ID > Subscriptions.'
              : 'Cancel anytime in Google Play > Subscriptions.';

          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Maritime Emblem & Badge Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.anchor, size: 16, color: AppColors.secondary),
                          SizedBox(width: 6),
                          Text(
                            'SEAFARER PRO',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unlock advanced DOCX export and premium features.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Plans stack
                  ...plans.map((plan) => _buildPlanCard(context, plan)),
                  const SizedBox(height: 12),

                  // Cancellation instructions and auto-renew disclosure
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Subscription Terms & Auto-Renewal',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: AppColors.primaryContainer,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Payment will be charged to your store account upon confirmation of purchase. '
                          'Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current billing cycle. '
                          '$cancellationPlatformText',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Restore Purchases Button
                  TextButton(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(RestorePurchase());
                    },
                    child: const Text(
                      'Restore Purchases',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Legal Links: Terms of Use (EULA) & Privacy Policy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _showLegalDialog(
                          context,
                          'Terms of Use (EULA)',
                          PaymentConstants.kTermsOfUseUrl,
                          'By subscribing to Seafarer Pro, you agree to our standard end-user license agreement and subscription terms. Subscriptions automatically renew unless cancelled.',
                        ),
                        child: const Text(
                          'Terms of Use',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: AppColors.outline,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text(
                        '•',
                        style: TextStyle(color: AppColors.outlineVariant),
                      ),
                      TextButton(
                        onPressed: () => _showLegalDialog(
                          context,
                          'Privacy Policy',
                          PaymentConstants.kPrivacyPolicyUrl,
                          'We respect your privacy. Your personal details and document data are protected and never sold.',
                        ),
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: AppColors.outline,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLegalDialog(
    BuildContext context,
    String title,
    String url,
    String description,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            color: AppColors.primaryContainer,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Link: $url',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: AppColors.secondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBillingPeriodText(String planId) {
    if (planId == 'weekly_plan') return '/ week';
    if (planId == 'monthly_plan') return '/ month';
    if (planId == 'yearly_plan') return '/ year';
    return '';
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPackage plan) {
    bool isMonthly = plan.id == 'monthly_plan';
    bool isYearly = plan.id == 'yearly_plan';
    final billingPeriod = _getBillingPeriodText(plan.id);

    return GestureDetector(
      onTap: () {
        context.read<SubscriptionBloc>().add(PurchasePlan(plan));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMonthly
                      ? AppColors.secondary
                      : isYearly
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant.withValues(alpha: 0.7),
                  width: (isMonthly || isYearly) ? 2 : 1,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan.name,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryContainer,
                                  ),
                                ),
                                if (isMonthly) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Auto-renewing subscription',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: AppColors.outline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan.priceString ??
                                '${plan.currency}${plan.price.toInt()}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          if (billingPeriod.isNotEmpty)
                            Text(
                              billingPeriod,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: AppColors.outline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.outlineVariant),
                  const SizedBox(height: 12),
                  ...plan.benefits.map(
                    (benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 7.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.secondary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              benefit,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: AppColors.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isMonthly)
              Positioned(
                top: -10,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F795916),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            if (isYearly)
              Positioned(
                top: -10,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F0B1F3A),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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
