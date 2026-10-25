import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Speech & Input Sanitization Utilities', () {
    test('Phone number sanitization strips non-numeric characters and spaces', () {
      String sanitizePhone(String input) {
        String sanitized = input.replaceAll(RegExp(r"[^0-9 ]"), "");
        return sanitized.replaceAll(" ", "");
      }

      expect(sanitizePhone("+91 98765-43210"), equals("919876543210"));
      expect(sanitizePhone("call me at 123 456 7890!"), equals("1234567890"));
      expect(sanitizePhone("9876543210"), equals("9876543210"));
      expect(sanitizePhone(""), equals(""));
      expect(sanitizePhone("no digits here"), equals(""));
    });

    test('Name capitalization correctly formats multi-word titles and names', () {
      String capitalize(String input) {
        if (input.isEmpty) return input;
        List<String> words = input.toLowerCase().split(" ");
        for (int i = 0; i < words.length; i++) {
          if (words[i].isNotEmpty) {
            words[i] = words[i][0].toUpperCase() + words[i].substring(1);
          }
        }
        return words.join(" ");
      }

      expect(capitalize("john doe"), equals("John Doe"));
      expect(capitalize("ALICE SMITH"), equals("Alice Smith"));
      expect(capitalize("tanishq"), equals("Tanishq"));
      expect(capitalize(""), equals(""));
      expect(capitalize("synergy visitor log system"), equals("Synergy Visitor Log System"));
    });

    test('Enrollment steps serialization and parsing', () {
      final steps = <int>[1, 2, 3];
      final stepsStringList = steps.map((s) => s.toString()).toList();
      expect(stepsStringList, equals(['1', '2', '3']));

      final parsedSteps = stepsStringList.map((s) => int.parse(s)).toList();
      expect(parsedSteps, equals([1, 2, 3]));
    });
  });
}
