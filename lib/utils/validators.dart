class Validators {
  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+$",
  );

  static final RegExp _indiaPhone = RegExp(r'^\d{10}\$');

  // Example CA reg: typically alphanumeric, 6-8 chars — adjust if needed
  static final RegExp _caReg = RegExp(r'^[A-Z0-9]{5,12}\$');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailRegExp.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (!_indiaPhone.hasMatch(digits)) return 'Enter a 10-digit Indian phone number';
    return null;
  }

  static String? validateCAReg(String? value) {
    if (value == null || value.trim().isEmpty) return 'CA Registration number is required';
    if (!_caReg.hasMatch(value.trim().toUpperCase())) return 'Enter a valid CA registration number';
    return null;
  }

  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
