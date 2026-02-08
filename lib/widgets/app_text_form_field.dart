import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final double? width;
  final bool obscureText;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final Widget suffixIconWidget;
  const AppTextFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
    this.onChanged,
    this.width,
    this.obscureText =  false,
    this.textInputType =  TextInputType.text,
    this.textInputAction =  TextInputAction.next,
    this.textCapitalization =  TextCapitalization.none,
    this.suffixIconWidget = const SizedBox.shrink()
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: width ?? double.maxFinite,
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.appPrimary, fontWeight: FontWeight.w600),
            hintText: hint,
            // suffixIcon: icon != null ? Icon(icon, color: AppColors.darkGreen) : null,
            fillColor: AppColors.appSurface,
            filled: true,
            suffixIcon: suffixIconWidget,
            // Border when NOT focused
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.appBorderColor),
            ),
            // Border when user is typing
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.appPrimary, width: 2),
            ),
            // Border when there is a validation error
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.appErrorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.appErrorColor, width: 2),
            ),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
