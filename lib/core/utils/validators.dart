class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }
}
