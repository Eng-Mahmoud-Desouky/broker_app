import 'package:flutter_test/flutter_test.dart';
import 'package:broker_app/features/cart/data/platform_selectors.dart';

void main() {
  group('PlatformSelectors', () {
    test('should generate valid JS for Amazon with multi-table support', () {
      final script = PlatformSelectors.generateExtractionScript('amazon');
      expect(
        script,
        contains('document.querySelectorAll(containerSel.trim())'),
      );
      expect(script, contains('for (const container of containers)'));
    });

    test('should include updated robust dimensions regex structure', () {
      final script = PlatformSelectors.generateExtractionScript('amazon');
      expect(script, contains(r'DdLl'));
      expect(script, contains(r'Ww'));
      expect(script, contains(r'Hh'));
    });

    test('should support capital X in dimensions regex (Alibaba fix)', () {
      final script = PlatformSelectors.generateExtractionScript('alibaba');
      // Check for [xX×] pattern which supports 35X30X1
      // We escape the check to match the Dart string representation of the JS code
      expect(script, contains(r'[xX×]'));

      // Check for text cleaning logic
      expect(script, contains('dimensionText.replace'));
      expect(script, contains(r"/\s+/g, ' '"));
    });

    test('should include robust selectors for Alibaba', () {
      final script = PlatformSelectors.generateExtractionScript('alibaba');
      // Check for body fallback in container
      expect(script, contains('body'));
      // Check for specific row selector
      expect(script, contains('module-attribute-row'));
      // Check for updated keywords
      expect(script, contains('Gross weight'));
      expect(script, contains('Package size'));
    });
  });
}
