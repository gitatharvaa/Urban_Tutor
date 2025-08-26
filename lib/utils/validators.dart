class Validators {
  static String? requiredField(String? value, [String field = '']) =>
      (value == null || value.trim().isEmpty)
          ? 'Please enter ${field.isEmpty ? 'a value' : field}'
          : null;

  static String? email(String? value) =>
      (value == null || !value.contains('@')) ? 'Invalid email' : null;

  static String? phone(String? value) =>
      (value == null || !RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value))
          ? 'Invalid phone number'
          : null;
}
