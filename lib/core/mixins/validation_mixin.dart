mixin ValidationMixin {
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    return null;
  }

  String? validateRequired(String? value, [String field = 'This field']) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }
}
