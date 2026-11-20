import 'package:drift/drift.dart';

import '../../../core/enums/estado_orden.dart';
import '../app_database.dart';
import '../tables/clientes.dart';
import '../tables/equipos.dart';
import '../tables/ordenes.dart';
import '../tables/tecnicos.dart';

part 'ordenes_dao.g.dart';

/// Una orden con los datos del equipo, del cliente y del técnico.
/// La vista la usa para pintar una tarjeta completa sin hacer más consultas.
class OrdenResumen {
  const OrdenResumen({
    required this.orden,
    required this.equipo,
    required this.cliente,
    this.tecnico,
  });

  final Ordene orden;
  final Equipo equipo;
  final Cliente cliente;
  final Tecnico? tecnico;
}

const _estadosCerrados = [EstadoOrden.entregada, EstadoOrden.cancelada];

@DriftAccessor(tables: [Ordenes, Equipos, Clientes, Tecnicos])
class OrdenesDao extends DatabaseAccessor<AppDatabase> with _$OrdenesDaoMixin {
  OrdenesDao(super.attachedDatabase);

  /// Órdenes que todavía no se entregaron ni se cancelaron.
  /// Si se indica [tecnicoId], solo devuelve las de ese técnico.
  Stream<List<OrdenResumen>> watchAbiertas({int? tecnicoId}) {
    final consulta = select(ordenes).join([
      innerJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
      leftOuterJoin(tecnicos, tecnicos.id.equalsExp(ordenes.tecnicoId)),
    ]);

    consulta.where(
      ordenes.estado.isNotIn(_estadosCerrados.map((estado) => estado.name)) &
          (tecnicoId == null
              ? const Constant(true)
              : ordenes.tecnicoId.equals(tecnicoId)),
    );
    consulta.orderBy([OrderingTerm.desc(ordenes.creada)]);

    return consulta.watch().map((filas) => filas.map(_aResumen).toList());
  }

  /// Una sola orden, para la pantalla de detalle.
  Stream<OrdenResumen?> watchPorId(int ordenId) {
    final consulta = select(ordenes).join([
      innerJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
      leftOuterJoin(tecnicos, tecnicos.id.equalsExp(ordenes.tecnicoId)),
    ])..where(ordenes.id.equals(ordenId));

    return consulta.watchSingleOrNull().map(
      (fila) => fila == null ? null : _aResumen(fila),
    );
  }

  /// Crea una orden nueva en estado "recibida", sin técnico asignado.
  Future<int> crear({required int equipoId, required String falla}) {
    return into(ordenes).insert(
      OrdenesCompanion.insert(
        equipoId: equipoId,
        fallaReportada: falla,
        estado: EstadoOrden.recibida,
      ),
    );
  }

  /// Cambia el técnico de una orden, pero solo si el técnico actual
  /// coincide con [desde]. Devuelve false si la condición no se cumple,
  /// por ejemplo cuando otro técnico ya tomó la orden.
  Future<bool> cambiarTecnico({
    required int ordenId,
    required int? desde,
    required int? hacia,
  }) async {
    final filas =
        await (update(ordenes)..where(
              (o) => o.id.equals(ordenId) & o.tecnicoId.equalsNullable(desde),
            ))
            .write(OrdenesCompanion(tecnicoId: Value(hacia)));
    return filas > 0;
  }

  Future<void> cambiarEstado(int ordenId, EstadoOrden nuevo) {
    return (update(ordenes)..where((o) => o.id.equals(ordenId))).write(
      OrdenesCompanion(estado: Value(nuevo)),
    );
  }

  OrdenResumen _aResumen(TypedResult fila) {
    return OrdenResumen(
      orden: fila.readTable(ordenes),
      equipo: fila.readTable(equipos),
      cliente: fila.readTable(clientes),
      tecnico: fila.readTableOrNull(tecnicos),
    );
  }
}
