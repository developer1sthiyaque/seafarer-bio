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
      body: BlocListener<AuthBloc, AuthState>(
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
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          final isObscure = state is AuthPasswordObscuredState
              ? state.isPasswordObscured
              : true; // default
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _signUpFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // --- LOGO SECTION ---
                      Image(image: AssetImage('assets/images/app_logo.png'),fit: BoxFit.cover,height: 240,width: 240,),
                      const SizedBox(height: 16),


                      AppTextView(title: "Create Account",
                        textStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appPrimary,
                        ),
                      ),
                      AppTextView(title: "Join us to manage your sea career effectively",
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                          fontSize: 15,
                          color: AppColors.appPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      //name
                      AppTextFormField(
                        controller: firstnameController,
                        textInputType: TextInputType.name,
                        label: 'First name',
                        hint: 'Enter your first name',
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          return AppValidators.name(value);
                        },
                      ),
                      AppTextFormField(
                        controller: lastnameController,
                        textInputType: TextInputType.name,
                        label: 'Last name',
                        hint: 'Enter your last name',
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          return AppValidators.name(value);
                        },
                      ),

                      /// Email
                      AppTextFormField(
                        controller: emailController,
                        textInputType: TextInputType.emailAddress,
                        label: 'Email',
                        hint: 'Enter your email',
                        validator: (value) {
                          return AppValidators.email(value);
                        },
                      ),

                      /// Password
                      AppTextFormField(
                        controller: passwordController,
                        textInputType: TextInputType.visiblePassword,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: isObscure,
                        suffixIconWidget: InkWell(
                            onTap: (){
                              context.read<AuthBloc>().add(TogglePasswordVisibility());
                            },
                            child: SvgPicture.asset(isObscure?'assets/icons/eye_off.svg':'assets/icons/eye.svg',height: 24,width: 24,fit: BoxFit.scaleDown,)),
                        validator: (value) {
                          return AppValidators.password(value);
                        },
                      ),

                      /// Confirm Password
                      AppTextFormField(
                        controller: confirmPasswordController,
                        textInputType: TextInputType.visiblePassword,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        obscureText: isObscure,
                        suffixIconWidget: InkWell(
                            onTap: (){
                              context.read<AuthBloc>().add(TogglePasswordVisibility());
                            },
                            child: SvgPicture.asset(isObscure?'assets/icons/eye_off.svg':'assets/icons/eye.svg',height: 24,width: 24,fit: BoxFit.scaleDown,)),
                        validator: (value) {
                          return AppValidators.confirmPassword(value, passwordController.text);
                        },
                      ),

                      const SizedBox(height: 24),
                      /// Sign Up Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return AppButton(title: 'Sign Up', onTap: () {
                            if(_signUpFormKey.currentState!.validate()){
                              final firstname = firstnameController.text.trim();
                              final lastname = lastnameController.text.trim();
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();
                              final confirmPassword =
                              confirmPasswordController.text.trim();

                              if (firstname.isEmpty||
                                  lastname.isEmpty||
                                  email.isEmpty ||
                                  password.isEmpty ||
                                  confirmPassword.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All fields are required'),
                                  ),
                                );
                                return;
                              }

                              if (password != confirmPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Passwords do not match'),
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
                          },);
                        },
                      ),

                      const SizedBox(height: 16),

                      /// Navigate to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },),
      ),
    );
  }
}
