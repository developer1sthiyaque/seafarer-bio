import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/utils/app_validators.dart';
import 'package:seafarer_bio_data/core/utils/string_extensions.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_controller_wrapper.dart';
import 'package:seafarer_bio_data/widgets/app_date_picker.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';

class DocumentWrapperWidget extends StatelessWidget {
  final ProfileControllerWrapper wrapper;
  final VoidCallback? onDelete;

  const DocumentWrapperWidget({
    super.key,
    required this.wrapper,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEAE6DF),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0B1F3A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppTextView(
                    title: wrapper.name.capitalize(),
                    textStyle: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 16,
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.cancel,
                      color: Color(0xFFBA1A1A),
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextFormField(
            controller: wrapper.numberController,
            width: double.infinity,
            label: "${wrapper.name.capitalize()} Number",
            hint: "Enter ${wrapper.name} number",
            validator: (value) => AppValidators.required(
                value, '${wrapper.name.capitalize()} number'),
          ),
          AppDatePicker(
            controller: wrapper.expiryController,
            width: double.infinity,
            label: "${wrapper.name.capitalize()} Validity",
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            onDateSelected: (date) {
              wrapper.expiryController.text =
                  "${date.day}/${date.month}/${date.year}";
            },
            validator: (value) =>
                AppValidators.required(value, '${wrapper.name} validity'),
          ),
          AppTextFormField(
            controller: wrapper.issuePlaceController,
            width: double.infinity,
            label: "${wrapper.name.capitalize()} Issued Place",
            hint: "Enter your ${wrapper.name} issued place",
            validator: (value) => AppValidators.required(
                value, '${wrapper.name.capitalize()} issued place'),
          ),
          AppDatePicker(
            controller: wrapper.issueDateController,
            width: double.infinity,
            label: "${wrapper.name.capitalize()} Issued Date",
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            onDateSelected: (date) {
              wrapper.issueDateController.text =
                  "${date.day}/${date.month}/${date.year}";
            },
            validator: (value) => AppValidators.required(
                value, '${wrapper.name.capitalize()} issued date'),
          ),
        ],
      ),
    );
  }
}