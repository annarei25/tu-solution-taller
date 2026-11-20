import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/clientes.dart';
import '../tables/equipos.dart';
import '../tables/ordenes.dart';
import '../tables/tecnicos.dart';

part 'historial_dao.g.dart';

typedef EquipoBusqueda = ({Equipo equipo, Cliente cliente});
typedef OrdenDeEquipo = ({Ordene orden, Tecnico? tecnico});

@DriftAccessor(tables: [Equipos, Clientes, Ordenes, Tecnicos])
class HistorialDao extends DatabaseAccessor<AppDatabase>
    with _$HistorialDaoMixin {
  HistorialDao(super.attachedDatabase);

  /// Equipos cuyo número de serie, modelo o dueño coincide con el texto.
  Stream<List<EquipoBusqueda>> buscarEquipos(String texto) {
    final patron = '%${texto.trim()}%';

    final consulta = select(equipos)
        .join([innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId))]);
    consulta.where(
      equipos.numeroSerie.like(patron) |
          equipos.modelo.like(patron) |
          clientes.nombre.like(patron),
    );

    return consulta.watch().map(
      (filas) => [
        for (final fila in filas)
          (equipo: fila.readTable(equipos), cliente: fila.readTable(clientes)),
      ],
    );
  }

  /// Todas las órdenes de un equipo, de la más reciente a la más antigua.
  Stream<List<OrdenDeEquipo>> ordenesDeEquipo(int equipoId) {
    final consulta = select(
      ordenes,
    ).join([leftOuterJoin(tecnicos, tecnicos.id.equalsExp(ordenes.tecnicoId))]);
    consulta.where(ordenes.equipoId.equals(equipoId));
    consulta.orderBy([OrderingTerm.desc(ordenes.creada)]);

    return consulta.watch().map(
      (filas) => [
        for (final fila in filas)
          (
            orden: fila.readTable(ordenes),
            tecnico: fila.readTableOrNull(tecnicos),
          ),
      ],
    );
  }
}
