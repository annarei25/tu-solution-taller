import 'package:drift/drift.dart';

import '../../../core/enums/estado_orden.dart';
import '../app_database.dart';
import '../tables/ordenes.dart';
import '../tables/tecnicos.dart';

part 'tecnicos_dao.g.dart';

typedef CargaTecnico = ({Tecnico tecnico, int abiertas});

const _estadosCerrados = [EstadoOrden.entregada, EstadoOrden.cancelada];

@DriftAccessor(tables: [Tecnicos, Ordenes])
class TecnicosDao extends DatabaseAccessor<AppDatabase>
    with _$TecnicosDaoMixin {
  TecnicosDao(super.attachedDatabase);

  /// Solo técnicos activos.
  Stream<List<Tecnico>> watchTodos() {
    return (select(tecnicos)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  Future<int> contarActivos() async {
    final lista = await (select(
      tecnicos,
    )..where((t) => t.activo.equals(true))).get();
    return lista.length;
  }

  /// Carga de trabajo de cada técnico activo.
  Stream<List<CargaTecnico>> watchCarga() {
    final consulta = select(tecnicos).join([
      leftOuterJoin(
        ordenes,
        ordenes.tecnicoId.equalsExp(tecnicos.id) &
            ordenes.estado.isNotIn(
              _estadosCerrados.map((estado) => estado.name),
            ),
      ),
    ]);
    consulta.where(tecnicos.activo.equals(true));
    consulta.orderBy([OrderingTerm.asc(tecnicos.nombre)]);

    return consulta.watch().map((filas) {
      final tecnicosPorId = <int, Tecnico>{};
      final conteo = <int, int>{};

      for (final fila in filas) {
        final tecnico = fila.readTable(tecnicos);
        tecnicosPorId[tecnico.id] = tecnico;
        conteo.putIfAbsent(tecnico.id, () => 0);

        if (fila.readTableOrNull(ordenes) != null) {
          conteo[tecnico.id] = conteo[tecnico.id]! + 1;
        }
      }

      return [
        for (final tecnico in tecnicosPorId.values)
          (tecnico: tecnico, abiertas: conteo[tecnico.id]!),
      ];
    });
  }

  Future<int> crear(String nombre, {String? especialidad}) {
    return into(tecnicos).insert(
      TecnicosCompanion.insert(
        nombre: nombre,
        especialidad: Value(especialidad),
      ),
    );
  }

  Future<void> actualizar({
    required int id,
    required String nombre,
    String? especialidad,
  }) {
    return (update(tecnicos)..where((t) => t.id.equals(id))).write(
      TecnicosCompanion(
        nombre: Value(nombre),
        especialidad: Value(especialidad),
      ),
    );
  }

  /// Da de baja al técnico y registra al reemplazo en una sola transacción.
  /// Las órdenes abiertas del técnico saliente quedan sin técnico.
  /// Las órdenes cerradas conservan el vínculo para el historial.
  Future<void> reemplazar({
    required int viejoId,
    required String nombre,
    String? especialidad,
  }) {
    return transaction(() async {
      await (update(ordenes)..where(
            (o) =>
                o.tecnicoId.equals(viejoId) &
                o.estado.isNotIn(_estadosCerrados.map((estado) => estado.name)),
          ))
          .write(const OrdenesCompanion(tecnicoId: Value(null)));

      await (update(tecnicos)..where((t) => t.id.equals(viejoId))).write(
        const TecnicosCompanion(activo: Value(false)),
      );

      await into(tecnicos).insert(
        TecnicosCompanion.insert(
          nombre: nombre,
          especialidad: Value(especialidad),
        ),
      );
    });
  }
}
