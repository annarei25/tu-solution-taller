import 'package:drift/drift.dart';

import '../../../core/enums/estado_orden.dart';
import '../app_database.dart';
import '../tables/clientes.dart';
import '../tables/equipos.dart';
import '../tables/ordenes.dart';

part 'equipos_dao.g.dart';

@DriftAccessor(tables: [Clientes, Equipos, Ordenes])
class EquiposDao extends DatabaseAccessor<AppDatabase>
    with _$EquiposDaoMixin {
  EquiposDao(super.attachedDatabase);

  Future<Equipo?> buscarPorSerie(String numeroSerie) {
    return (select(equipos)
          ..where((e) => e.numeroSerie.equals(numeroSerie)))
        .getSingleOrNull();
  }

  /// Registra la recepción de un equipo y devuelve el id de la orden nueva.
  /// Todo ocurre en una transacción: si algo falla, no queda nada a medias.
  Future<int> recibir({
    required String clienteNombre,
    required String telefono,
    required String tipo,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required String falla,
  }) {
    return transaction(() async {
      final existente = await buscarPorSerie(numeroSerie);

      final int equipoId;
      if (existente != null) {
        equipoId = existente.id;
      } else {
        final clienteId = await _clienteIdPara(clienteNombre, telefono);
        equipoId = await into(equipos).insert(
          EquiposCompanion.insert(
            clienteId: clienteId,
            tipo: tipo,
            marca: marca,
            modelo: modelo,
            numeroSerie: numeroSerie,
          ),
        );
      }

      return into(ordenes).insert(
        OrdenesCompanion.insert(
          equipoId: equipoId,
          fallaReportada: falla,
          estado: EstadoOrden.recibida,
        ),
      );
    });
  }

  /// Un dueño con el mismo teléfono se reutiliza. Así un cliente
  /// con varios equipos queda con un solo registro.
  Future<int> _clienteIdPara(String nombre, String telefono) async {
    final existente = await (select(clientes)
          ..where((c) => c.telefono.equals(telefono)))
        .getSingleOrNull();

    if (existente != null) return existente.id;

    return into(clientes).insert(
      ClientesCompanion.insert(nombre: nombre, telefono: telefono),
    );
  }
}
