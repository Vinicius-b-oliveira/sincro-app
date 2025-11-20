import 'package:flutter/widgets.dart';

class AppValidators {
  static FormFieldValidator<String> required(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<String> email(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<String> minLength(int min, String message) {
    return (value) {
      if (value == null || value.length < min) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<String> match(
    TextEditingController controller,
    String message,
  ) {
    return (value) {
      if (value != controller.text) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<String> compose(
    List<FormFieldValidator<String>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
