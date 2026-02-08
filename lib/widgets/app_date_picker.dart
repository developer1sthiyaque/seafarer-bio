import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppDatePicker extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;
  final String? Function(String?)? validator;
  final double? width;

  const AppDatePicker({
    super.key,
    required this.label,
    required this.controller,
    required this.onDateSelected,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.validator,
    this.width,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {


  @override
  void initState() {
    super.initState();
    // Format initial date if it exists
    if (widget.initialDate != null) {
      widget.controller.text = _formatDate(widget.initialDate!);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}"; // Or use 'intl' package
  }

  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();

    // Define the last selectable date as 10 years in the future
    final DateTime lastDate = DateTime(today.year + 10, today.month, today.day);


    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        widget.controller.text = _formatDate(picked);
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.maxFinite,
      child: TextFormField(
        controller: widget.controller,
        readOnly: true, // Prevents keyboard from appearing
        onTap: _pickDate,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: "Select ${widget.label}",
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade200
            )
          ),
        ),
      ),
    );
  }
}