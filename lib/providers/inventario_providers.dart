import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import 'database_providers.dart';

/// Todos los repuestos del almacén, incluidos los agotados, actualizados en vivo.
final repuestosProvider = StreamProvider.autoDispose<List<Repuesto>>(
  (ref) => ref.watch(inventarioRepositoryProvider).watchRepuestos(),
);
