import 'package:flutter_svg/flutter_svg.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/app_validators.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is Authenticated) {
              context.read<ProfileBloc>().add(LoadProfile(PreferenceService.userId.toString()));

              if (PreferenceService.isProfileCompleted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                      (route) => false, // removes ALL previous routes
                );
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.profileCompletion,
                      (route) => false, // removes ALL previous routes
                );
              }
              // Navigate to HomePage or dashboard
              // For now, it will just pop if there's any screen below

            }

          },
          builder: (context, state) {
            final isObscure = state is AuthPasswordObscuredState
                ? state.isPasswordObscured
                : true; // default

            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(

              child: Form(
                key: _formLoginKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // --- LOGO SECTION ---
                    Image(image: AssetImage('assets/images/app_logo.png'),fit: BoxFit.cover,height: 240,width: 240,),
                    const SizedBox(height: 20),

                    // --- HEADER SECTION ---
                    AppTextView(title: "Welcome Seafarer",
                      textStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.appPrimary,
                      ),
                    ),
                    AppTextView(title: "Sign in to your account to continue building your professional maritime profile.",
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: AppColors.appPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppTextFormField(label: 'Email', controller: _emailController, hint: 'Enter your email',textInputAction: TextInputAction.next,textInputType: TextInputType.emailAddress,validator: (value) {
                      return AppValidators.email(value);
                    },),
                    SizedBox(height: 8,),
                    AppTextFormField(label: 'Password', controller: _passwordController, hint: 'Enter your password',textInputAction: TextInputAction.done,textInputType: TextInputType.visiblePassword,
                      obscureText: isObscure,
                      suffixIconWidget: InkWell(
                        onTap: (){
                          context.read<AuthBloc>().add(TogglePasswordVisibility());
                        },
                          child: SvgPicture.asset(isObscure?'assets/icons/eye_off.svg':'assets/icons/eye.svg',height: 24,width: 24,fit: BoxFit.scaleDown,)),
                      validator: (value) {
                      return AppValidators.password(value);
                    },),
                    const SizedBox(height: 20),
                    AppButton(title: 'Sign In', onTap: () {
                      if(_formLoginKey.currentState!.validate()){
                        context.read<AuthBloc>().add(SignInEvent(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ));
                      }

                    },),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.signup,
                        );
                      },
                      child: const Text("Don't have an account? Sign Up"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}