extension StringExtensions on String {
  bool get isValidPhone => length >= 10;

  bool get isValidEmail => contains('@') && contains('.');

  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
