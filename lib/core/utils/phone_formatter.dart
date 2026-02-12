import 'package:flutter/services.dart';

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Garde uniquement les chiffres
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limite à 9 chiffres
    final clipped = digits.length > 9 ? digits.substring(0, 9) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < clipped.length; i++) {
      buffer.write(clipped[i]);
      // Ajoute un espace après le 3ème, 5ème et 7ème chiffre
      if ((i == 2 || i == 4 || i == 6) && i != clipped.length - 1) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}