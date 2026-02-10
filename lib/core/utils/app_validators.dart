class AppValidators {
  // Private constructor to prevent instantiation
  AppValidators._();

  // Name Validator
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? post(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Post is required';
    }
    if (value.length < 2) {
      return 'Post must be at least 2 characters';
    }
    return null;
  }

  // Email Validator
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Password Validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length <= 8) {
      return 'Password must be at least 8 characters';
    }
    // Optional: Add regex for complexity (uppercase, numbers, etc.)
    // final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if(password!=value){
      return 'Password does not match';
    }
    // Optional: Add regex for complexity (uppercase, numbers, etc.)
    // final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    return null;
  }

  // DOB Validator (Usually checks if the string from the picker is empty)
  static String? dob(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }
    return null;
  }

  // Name Validator
  static String? nationality(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nationality is required';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  // Custom Regex Validator (for flexibility)
  static String? matchPattern(String? value, String pattern, String errorMsg) {
    if (value == null || !RegExp(pattern).hasMatch(value)) {
      return errorMsg;
    }
    return null;
  }
}