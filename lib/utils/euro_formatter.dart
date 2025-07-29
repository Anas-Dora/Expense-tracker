import 'package:flutter/services.dart';

class EuroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return TextEditingValue(
        text: "0.00",
        selection: const TextSelection.collapsed(offset: 4),
      );
    }

    int value = int.parse(digits);
    String formatted = (value / 100).toStringAsFixed(2);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
