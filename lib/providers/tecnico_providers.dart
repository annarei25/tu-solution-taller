import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import 'database_providers.dart';

/// Lista de técnicos que se actualiza sola cuando cambia la tabla.
final tecnicosProvider = StreamProvider.autoDispose<List<Tecnico>>(
  (ref) => ref.watch(tecnicoRepositoryProvider).watchTodos(),
);