import 'package:flutter_test/flutter_test.dart';
import 'package:trainable_machine_test/services/labels.dart';

void main() {
  test('parses a normal labels file', () {
    expect(parseLabels('0 Mug\n1 Bottle\n'), ['Mug', 'Bottle']);
  });

  test('handles Windows line endings, blank lines and spaces in labels', () {
    expect(
      parseLabels('0 window\r\n1 me\r\n2 Car keys\r\n\r\n'),
      ['window', 'me', 'Car keys'],
    );
  });
}
