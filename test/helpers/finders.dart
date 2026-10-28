import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/widgets/app_date_picker.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';

/// Finds an `SvgPicture.asset(...)` by its asset path — the app's AppBar action
/// icons have no keys, so this is the stable way to target them.
Finder svgAsset(String assetName) => find.byWidgetPredicate(
      (widget) =>
          widget is SvgPicture &&
          widget.bytesLoader is SvgAssetLoader &&
          (widget.bytesLoader as SvgAssetLoader).assetName == assetName,
      description: 'SvgPicture.asset("$assetName")',
    );

/// Finds the tappable wrapper around an SVG icon.
Finder svgAssetTapTarget(String assetName) => find.ancestor(
      of: svgAsset(assetName),
      matching: find.byType(InkWell),
    );

/// Finds the app's labelled text field by its label text.
Finder appTextField(String label) => find.byWidgetPredicate(
      (widget) => widget is AppTextFormField && widget.label == label,
      description: 'AppTextFormField(label: "$label")',
    );

/// Reads the current text of the app's labelled text field.
String appTextFieldValue(WidgetTester tester, String label) =>
    tester.widget<AppTextFormField>(appTextField(label)).controller.text;

/// Finds the app's read-only date field by its label text.
Finder appDatePicker(String label) => find.byWidgetPredicate(
      (widget) => widget is AppDatePicker && widget.label == label,
      description: 'AppDatePicker(label: "$label")',
    );

/// Reads the current text of the app's labelled date field.
String appDatePickerValue(WidgetTester tester, String label) =>
    tester.widget<AppDatePicker>(appDatePicker(label)).controller.text;
