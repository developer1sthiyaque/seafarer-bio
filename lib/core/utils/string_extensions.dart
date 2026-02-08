extension StringExtensions on String {
  // Method to capitalize the first letter
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }

  // Getter to check for a valid email (simple regex example)
  bool get isValidEmail {
    // A simple regex for demonstration purposes
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }
}