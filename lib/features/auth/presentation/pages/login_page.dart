import 'package:flutter_svg/flutter_svg.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/app_validators.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formLoginKey=GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is Authenticated) {
                  PreferenceService.setLoggedIn(true);
                  context.read<ProfileBloc>().add(
                    LoadProfile(PreferenceService.userId.toString()),
                  );
                }
              },
            ),
            BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileLoaded) {
                  if (PreferenceService.isProfileCompleted ||
                      state.profile.isProfileCompleted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.profileCompletion,
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isObscure = state is AuthPasswordObscuredState
                  ? state.isPasswordObscured
                  : true;

              if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Maritime Heritage Emblem Frame
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainer,
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D0B1F3A),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Editorial Typography Block
                      AppTextView(
                        title: "Welcome Seafarer",
                        textStyle: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextView(
                        title:
                            "Sign in to your account to continue building your professional maritime profile.",
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Form Envelope Card
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 22.0,
                        ),
                        child: Form(
                          key: _formLoginKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextFormField(
                                label: 'Email',
                                controller: _emailController,
                                hint: 'Enter your email',
                                textInputAction: TextInputAction.next,
                                textInputType: TextInputType.emailAddress,
                                validator: (value) => AppValidators.email(value),
                              ),
                              const SizedBox(height: 4),
                              AppTextFormField(
                                label: 'Password',
                                controller: _passwordController,
                                hint: 'Enter your password',
                                textInputAction: TextInputAction.done,
                                textInputType: TextInputType.visiblePassword,
                                obscureText: isObscure,
                                suffixIconWidget: InkWell(
                                  onTap: () {
                                    context
                                        .read<AuthBloc>()
                                        .add(TogglePasswordVisibility());
                                  },
                                  child: SvgPicture.asset(
                                    isObscure
                                        ? 'assets/icons/eye_off.svg'
                                        : 'assets/icons/eye.svg',
                                    height: 22,
                                    width: 22,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                                validator: (value) =>
                                    AppValidators.password(value),
                              ),
                              const SizedBox(height: 20),
                              AppButton(
                                title: 'Sign In',
                                onTap: () {
                                  if (_formLoginKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      SignInEvent(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Navigation Footer
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.signup,
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}