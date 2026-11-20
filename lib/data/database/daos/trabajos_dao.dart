import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trabajos.dart';

part 'trabajos_dao.g.dart';

@DriftAccessor(tables: [Trabajos])
class TrabajosDao extends DatabaseAccessor<AppDatabase>
    with _$TrabajosDaoMixin {
  TrabajosDao(super.attachedDatabase);

  Stream<List<Trabajo>> watchDeOrden(int ordenId) {
    return (select(trabajos)
          ..where((t) => t.ordenId.equals(ordenId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  Future<int> agregar({
    required int ordenId,
    required String descripcion,
    required double costo,
  }) {
    return into(trabajos).insert(
      TrabajosCompanion.insert(
        ordenId: ordenId,
        descripcion: descripcion,
        costoManoObra: Value(costo),
      ),
    );
  }

  Future<void> eliminar(int id) {
    return (delete(trabajos)..where((t) => t.id.equals(id))).go();
  }
}
