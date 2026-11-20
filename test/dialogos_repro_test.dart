import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tu_solution/app/theme/app_theme.dart';
import 'package:tu_solution/data/database/app_database.dart';
import 'package:tu_solution/features/inventario/widgets/dialogo_entrada.dart';
import 'package:tu_solution/features/inventario/widgets/dialogo_repuesto.dart';

void main() {
  final repuesto = Repuesto(
    id: 1,
    codigo: 'REP-1',
    nombre: 'Pantalla',
    precio: 45,
    existencias: 5,
    stockMinimo: 2,
    categoria: 'Pantallas',
  );

  testWidgets('botones del dialogo entrada quedan separados', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => mostrarDialogoEntrada(context, repuesto),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final cancelar = tester.getRect(find.widgetWithText(FilledButton, 'Cancelar'));
    final confirmar = tester.getRect(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    final separacion = confirmar.left - cancelar.right;
    debugPrint('Separación entre botones: $separacion px');
    expect(separacion, greaterThanOrEqualTo(16));
  });

  testWidgets('dialogo entrada con tema real no lanza excepciones', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => mostrarDialogoEntrada(context, repuesto),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    // Simula el teclado abierto, como en el teléfono.
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    addTearDown(tester.view.reset);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialogo editar repuesto con tema real no lanza excepciones', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => mostrarDialogoRepuesto(context, inicial: repuesto),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    addTearDown(tester.view.reset);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
