import 'package:flutter_svg/flutter_svg.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/app_validators.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _signUpFormKey = GlobalKey<FormState>();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _signUpFormKey.currentState?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is SignUpSuccess) {
              context.read<ProfileBloc>().add(
                LoadProfile(state.user.uid),
              );
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.profileCompletion,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isObscure = state is AuthPasswordObscuredState
                  ? state.isPasswordObscured
                  : true;

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
                        title: "Create Account",
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
                        title: "Join us to manage your sea career effectively",
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
                          key: _signUpFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Name fields
                              AppTextFormField(
                                controller: firstnameController,
                                textInputType: TextInputType.name,
                                label: 'First name',
                                hint: 'Enter your first name',
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                validator: (value) => AppValidators.name(value),
                              ),
                              const SizedBox(height: 4),
                              AppTextFormField(
                                controller: lastnameController,
                                textInputType: TextInputType.name,
                                label: 'Last name',
                                hint: 'Enter your last name',
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                validator: (value) => AppValidators.name(value),
                              ),
                              const SizedBox(height: 4),

                              // Email
                              AppTextFormField(
                                controller: emailController,
                                textInputType: TextInputType.emailAddress,
                                label: 'Email',
                                hint: 'Enter your email',
                                textInputAction: TextInputAction.next,
                                validator: (value) => AppValidators.email(value),
                              ),
                              const SizedBox(height: 4),

                              // Password
                              AppTextFormField(
                                controller: passwordController,
                                textInputType: TextInputType.visiblePassword,
                                label: 'Password',
                                hint: 'Enter your password',
                                textInputAction: TextInputAction.next,
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
                              const SizedBox(height: 4),

                              // Confirm Password
                              AppTextFormField(
                                controller: confirmPasswordController,
                                textInputType: TextInputType.visiblePassword,
                                label: 'Confirm Password',
                                hint: 'Confirm your password',
                                textInputAction: TextInputAction.done,
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
                                    AppValidators.confirmPassword(
                                  value,
                                  passwordController.text,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Sign Up Button
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is AuthLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return AppButton(
                                    title: 'Sign Up',
                                    onTap: () {
                                      if (_signUpFormKey.currentState!
                                          .validate()) {
                                        final firstname =
                                            firstnameController.text.trim();
                                        final lastname =
                                            lastnameController.text.trim();
                                        final email =
                                            emailController.text.trim();
                                        final password =
                                            passwordController.text.trim();
                                        final confirmPassword =
                                            confirmPasswordController.text
                                                .trim();

                                        if (firstname.isEmpty ||
                                            lastname.isEmpty ||
                                            email.isEmpty ||
                                            password.isEmpty ||
                                            confirmPassword.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'All fields are required',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        if (password != confirmPassword) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Passwords do not match',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        context.read<AuthBloc>().add(
                                          SignUpEvent(
                                            firstname: firstname,
                                            lastname: lastname,
                                            email: email,
                                            password: password,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Navigate to Login Footer
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            },
                            child: const Text(
                              'Login',
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
