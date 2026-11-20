import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/enums/estado_orden.dart';
import 'daos/equipos_dao.dart';
import 'daos/historial_dao.dart';
import 'daos/inventario_dao.dart';
import 'daos/ordenes_dao.dart';
import 'daos/tecnicos_dao.dart';
import 'daos/trabajos_dao.dart';
import 'tables/clientes.dart';
import 'tables/equipos.dart';
import 'tables/tecnicos.dart';
import 'tables/ordenes.dart';
import 'tables/trabajos.dart';
import 'tables/repuestos.dart';
import 'tables/repuestos_usados.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Clientes,
    Equipos,
    Tecnicos,
    Ordenes,
    Trabajos,
    Repuestos,
    RepuestosUsados,
  ],
  daos: [
    EquiposDao,
    OrdenesDao,
    InventarioDao,
    TecnicosDao,
    TrabajosDao,
    HistorialDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'tu_solution'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.addColumn(repuestos, repuestos.categoria);
          if (from < 3) await m.addColumn(tecnicos, tecnicos.activo);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
