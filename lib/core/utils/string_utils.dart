class StringUtils {
  static String formatPhone(String text) {
    if (text.isEmpty) return text;
    // Nettoie les espaces existants
    var clean = text.replaceAll(' ', '');
    
    // Format 9 chiffres (ex: 6XX XX XX XX)
    if (clean.length == 9) {
      return '${clean.substring(0, 3)} ${clean.substring(3, 5)} ${clean.substring(5, 7)} ${clean.substring(7)}';
    }
    
    // Fallback: Group by 2
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
        if (i > 0 && i % 2 == 0) {
          buffer.write(' ');
        }
        buffer.write(clean[i]);
    }
    return buffer.toString();
  }
}
