import 'package:flutter_test/flutter_test.dart';
import 'package:tu_solution/core/utils/formato.dart';

void main() {
  test('formatoFecha uses Spanish abbreviated months', () {
    expect(formatoFecha(DateTime(2024, 10, 24)), '24 oct 2024');
    expect(formatoFecha(DateTime(2025, 1, 3)), '3 ene 2025');
  });
}
