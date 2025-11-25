import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final int maxSize;

  CurrencyInputFormatter({this.maxSize = 15});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (newText.length > maxSize) {
      newText = newText.substring(0, maxSize);
    }

    if (newText.isEmpty) return newValue.copyWith(text: '');

    double value = double.parse(newText) / 100;

    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String newString = formatter.format(value);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }

  static double parseToDouble(String formattedValue) {
    if (formattedValue.isEmpty) return 0.0;
    String clean = formattedValue.replaceAll(RegExp('[^0-9]'), '');
    if (clean.isEmpty) return 0.0;
    return double.parse(clean) / 100;
  }
}
