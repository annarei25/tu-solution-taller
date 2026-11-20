import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tu_solution/app/app.dart';
import 'package:tu_solution/providers/tecnico_providers.dart';
import 'package:tu_solution/providers/sesion_providers.dart';

void main() {
  testWidgets('TuSolutionApp displays its home screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          datosInicialesProvider.overrideWith((ref) async {}),
          tecnicosProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const TuSolutionApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tu Solution'), findsOneWidget);
  });
}
