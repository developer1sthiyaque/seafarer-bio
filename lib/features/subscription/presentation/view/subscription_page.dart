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
      backgroundColor: const Color(0xFF0A192F), // Navy Blue Background
      appBar: AppBar(
        title:
            const Text('Upgrade to Pro', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
              child: CircularProgressIndicator(color: Colors.white),
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
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.anchor, size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    'SEAFARER PRO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Unlock advanced DOCX export and premium features.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ...plans.map((plan) => _buildPlanCard(context, plan)),
                  const SizedBox(height: 15),

                  // Cancellation instructions and auto-renew disclosure
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Subscription Terms & Auto-Renewal',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.bold,
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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            height: 1.4,
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
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

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
                            color: Colors.white60,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text('•', style: TextStyle(color: Colors.white38)),
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
                            color: Colors.white60,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
        backgroundColor: const Color(0xFF0F223D),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Text(
              'Link: $url',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
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
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    isYearly ? Border.all(color: Colors.amber, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
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
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A192F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Auto-renewing subscription',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
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
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.appPrimary,
                            ),
                          ),
                          if (billingPeriod.isNotEmpty)
                            Text(
                              billingPeriod,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ...plan.benefits.map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.appPrimary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                benefit,
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            if (isMonthly)
              Positioned(
                top: -12,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (isYearly)
              Positioned(
                top: -12,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
