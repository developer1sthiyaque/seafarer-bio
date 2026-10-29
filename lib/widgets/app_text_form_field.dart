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
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;

  const AppTextFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
    this.onChanged,
    this.width,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIconWidget = const SizedBox.shrink(),
    this.focusNode,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: width ?? double.maxFinite,
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          focusNode: focusNode,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: label,
            labelStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: AppColors.outline,
              fontSize: 14,
            ),
            fillColor: AppColors.surfaceContainerLow,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIconWidget,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
