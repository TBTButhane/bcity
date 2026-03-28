import 'package:bcity_web/db/database.dart';

class ClientCodeGenerator {
  /// This class generates a unique client code.
  ///  from the doc, we format the structure as follows: [3 ALPHA][3 DIGITS] e.g. FNB001, PRO123, ITA001
  static String generate(String clientName) {
    final alpha = _extractAlpha(clientName);

    // Start at 001 and increment until unique
    for (int i = 1; i <= 999; i++) {
      final digits = i.toString().padLeft(3, '0');
      final code = '$alpha$digits';
      if (!AppDatabase.codeExists(code)) {
        return code;
      }
    }

    throw Exception('Could not generate unique code for prefix $alpha');
  }

  static String _extractAlpha(String name) {
    // Take letters only, uppercase
    final letters = name.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();

    if (letters.isEmpty) return 'CLI';

    if (letters.length >= 3) {
      // Use first 3 letters of the name
      return letters.substring(0, 3);
    }

    // Pad with A, B, C... if name is shorter than 3 chars
    var padded = letters;
    var padChar = 65; // 'A'
    while (padded.length < 3) {
      // avoid duplicating existing chars
      final candidate = String.fromCharCode(padChar);
      if (!padded.contains(candidate)) {
        padded += candidate;
      }
      padChar++;
    }
    return padded;
  }
}