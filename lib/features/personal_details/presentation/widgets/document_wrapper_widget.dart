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
    return Column(
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 8.0),
        //   child: AppTextView(title: wrapper.name.capitalize(), textStyle:  const TextStyle(fontSize: 16,color: AppColors.appPrimary, fontWeight: FontWeight.w600),),
        // ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppTextView(
                title: wrapper.name.capitalize(),
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.appPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.cancel, // or Icons.close
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
        AppTextFormField(
          controller: wrapper
              .numberController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Number",
          hint:
          "Enter ${wrapper.name} number",
          validator: (value) => AppValidators.required(value,'${wrapper.name.capitalize()} number'),
        ),
        AppDatePicker(
          controller: wrapper
              .expiryController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Validity",
          firstDate:
          DateTime(
              1900),
          lastDate:
          DateTime(
              2100),
          onDateSelected:
              (date) {
            // You can format the date to string here as needed for your entity
            wrapper.expiryController
                .text =
            "${date.day}/${date.month}/${date.year}";

          },
          validator: (value) => AppValidators.required(value,'${wrapper.name} validity'),
        ),
        AppTextFormField(
          controller: wrapper
              .issuePlaceController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Issued Place",
          hint:
          "Enter your ${wrapper.name} issued place",
          validator: (value) => AppValidators.required(value,'${wrapper.name.capitalize()} issued place'),
        ),
        AppDatePicker(
          controller: wrapper
              .issueDateController,
          width: MediaQuery
              .sizeOf(
              context)
              .width,
          label:
          "${wrapper.name.capitalize()} Issued Date",
          firstDate:
          DateTime(
              1900),
          lastDate:
          DateTime(
              2100),
          onDateSelected:
              (date) {
            // You can format the date to string here as needed for your entity
            wrapper.issueDateController
                .text =
            "${date.day}/${date.month}/${date.year}";
          },
          validator: (value) => AppValidators.required(value,'${wrapper.name.capitalize()} issued date'),
        ),
        SizedBox(height: 16,),
      ],
    );
  }
}