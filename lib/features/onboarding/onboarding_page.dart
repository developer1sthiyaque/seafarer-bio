import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/onboarding/onboarding_content.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<OnboardingContent> contents = [
    OnboardingContent(
      title: "Professional Profile",
      description:
      "Keep your personal information and essential travel documents organized in one secure place.",
      image: 'assets/images/onboard1.png',
    ),
    OnboardingContent(
      title: "Certification Tracker",
      description:
      "Manage your professional courses and mandatory training records with ease.",
      image: 'assets/images/onboard2.png',
    ),
    OnboardingContent(
      title: "Service History",
      description:
      "Maintain a detailed log of your sea experience and vessel history after every voyage.",
      image: 'assets/images/onboard3.png',
    ),
    OnboardingContent(
      title: "Export & Share",
      description:
      "Generate professional bio-data reports in PDF or spreadsheet formats to share with agencies.",
      image: 'assets/images/onboard4.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  PreferenceService.setOnboardingCompleted(true);
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text("Skip"),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (_, index) {
                  return _OnboardingCard(content: contents[index]);
                },
              ),
            ),

            _DotsIndicator(
              length: contents.length,
              currentIndex: _currentIndex,
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (_currentIndex == contents.length - 1) {
                      // Navigate to Login/Home
                      PreferenceService.setOnboardingCompleted(true);
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: AppTextView(
                    title:
                    _currentIndex == contents.length - 1
                        ? "Get Started"
                        : "Next",
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16,color: AppColors.appTextColor,fontWeight: FontWeight.w600),


                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

}

class _OnboardingCard extends StatelessWidget {
  final OnboardingContent content;

  const _OnboardingCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Soft Icon Bubble (Like reference illustration)
            Image.asset(
              content.image,
              height: 420,width: 420,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20),

            Text(
              content.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.appPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                content.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.appSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int length;
  final int currentIndex;

  const _DotsIndicator({
    required this.length,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 20 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.appAccent
                : AppColors.appSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}


