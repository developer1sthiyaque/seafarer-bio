
import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/onboarding/onboarding_content.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Nautical Branding & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F0B1F3A),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "SEAFARER",
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          Text(
                            "MARITIME DOSSIER",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      PreferenceService.setOnboardingCompleted(true);
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Slide Viewport
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (_, index) {
                  return _OnboardingCard(
                    content: contents[index],
                    slideIndex: index,
                    totalSlides: contents.length,
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Maritime Dots Indicator
            _DotsIndicator(
              length: contents.length,
              currentIndex: _currentIndex,
            ),

            const SizedBox(height: 20),

            // Primary Navigation CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppButton(
                title: _currentIndex == contents.length - 1
                    ? "Get Started"
                    : "Next",
                trailingIcon: Icon(
                  _currentIndex == contents.length - 1
                      ? Icons.anchor
                      : Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                onTap: () {
                  if (_currentIndex == contents.length - 1) {
                    PreferenceService.setOnboardingCompleted(true);
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
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
  final int slideIndex;
  final int totalSlides;

  const _OnboardingCard({
    required this.content,
    required this.slideIndex,
    required this.totalSlides,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0B1F3A),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Micro step pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                "STAGE ${slideIndex + 1} OF $totalSlides",
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.secondary,
                ),
              ),
            ),

            const Spacer(),

            // Illustration Container
            Flexible(
              flex: 6,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Image.asset(
                  content.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const Spacer(),

            // Title
            Text(
              content.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: AppColors.primaryContainer,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                content.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 8),
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
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 7,
          width: isActive ? 24 : 7,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.secondary
                : AppColors.outlineVariant.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}


