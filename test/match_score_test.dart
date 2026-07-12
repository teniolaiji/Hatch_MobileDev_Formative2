// test/match_score_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hatch/utils/matching.dart';

void main() {
  group('matchPercent', () {
    test('100 when the role requires no skills', () {
      expect(matchPercent({'Flutter'}, []), 100);
    });
    test('100 when the student has every required skill', () {
      expect(matchPercent({'Flutter', 'Dart', 'Firebase'},
          ['Flutter', 'Dart', 'Firebase']), 100);
    });
    test('67 for two of three required skills', () {
      expect(matchPercent({'Flutter', 'Dart'},
          ['Flutter', 'Dart', 'Firebase']), 67);
    });
    test('0 when the student has none of the required skills', () {
      expect(matchPercent({'Python'}, ['Flutter', 'Dart']), 0);
    });
    test('ignores extra skills the student has', () {
      expect(matchPercent({'Flutter', 'Dart', 'Figma'},
          ['Flutter', 'Dart']), 100);
    });
    test('case-insensitive matching', () {
      expect(matchPercent({'flutter', 'dart'}, ['Flutter', 'Dart']), 100);
    });
  });
}
