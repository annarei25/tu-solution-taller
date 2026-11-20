import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tu_solution/data/database/app_database.dart';
import 'package:tu_solution/features/nueva_orden/views/nueva_orden_screen.dart';

void main() {
  testWidgets('prefills a new order from an existing equipment and client', (
    tester,
  ) async {
    const equipo = Equipo(
      id: 1,
      clienteId: 2,
      tipo: 'Portátil',
      marca: 'Apple',
      modelo: 'MacBook Air M1',
      numeroSerie: 'SERIE-123',
    );
    const cliente = Cliente(
      id: 2,
      nombre: 'Lucía Ferrer',
      telefono: '555-8832',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NuevaOrdenScreen(
            equipoExistente: equipo,
            clienteExistente: cliente,
          ),
        ),
      ),
    );

    final campos = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(campos.map((campo) => campo.controller?.text).take(5), [
      'Lucía Ferrer',
      '555-8832',
      'Apple',
      'MacBook Air M1',
      'SERIE-123',
    ]);
    expect(find.text('Portátil'), findsOneWidget);
  });
}
