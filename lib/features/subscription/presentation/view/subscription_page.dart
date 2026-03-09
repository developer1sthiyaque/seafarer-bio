import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                      'Successfully Subscribed to ${state.plan.name} Plan!')),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          List<SubscriptionPackage> plans = [];
          if (state is PlansLoaded) {
            plans = state.plans;
          } else if (state is SubscriptionInitial ||
              state is SubscriptionError) {
            // Because FetchPlans is called in main.dart, we might just use static fallback if not loaded
            plans = SubscriptionPackage.staticPlans;
          }

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
                  const SizedBox(height: 30),
                  ...plans
                      .map((plan) => _buildPlanCard(context, plan))
                      .toList(),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(RestorePurchase());
                    },
                    child: const Text('Restore Purchases',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPackage plan) {
    bool isMonthly = plan.id == 'monthly_plan';
    bool isYearly = plan.id == 'yearly_plan';

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
                    color: Colors.black.withOpacity(0.2),
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
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A192F),
                        ),
                      ),
                      Text(
                        plan.priceString ??
                            '${plan.currency}${plan.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.appPrimary,
                        ),
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
