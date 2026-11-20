import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/repositories/inventario_repository.dart';
import '../data/repositories/orden_repository.dart';
import '../data/repositories/tecnico_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final ordenRepositoryProvider = Provider<OrdenRepository>(
  (ref) => OrdenRepository(ref.watch(databaseProvider)),
);

final inventarioRepositoryProvider = Provider<InventarioRepository>(
  (ref) => InventarioRepository(ref.watch(databaseProvider)),
);

final tecnicoRepositoryProvider = Provider<TecnicoRepository>(
  (ref) => TecnicoRepository(ref.watch(databaseProvider)),
);
