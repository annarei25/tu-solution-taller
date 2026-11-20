import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/daos/historial_dao.dart';
import '../../../providers/database_providers.dart';

class TextoBusquedaNotifier extends Notifier<String> {
  @override
  String build() => '';

  void cambiar(String texto) => state = texto;
}

final textoBusquedaHistorialProvider =
    NotifierProvider<TextoBusquedaNotifier, String>(
  TextoBusquedaNotifier.new,
);

/// Equipo que el técnico abrió desde los resultados. Null si no hay ninguno.
class EquipoSeleccionadoNotifier extends Notifier<EquipoBusqueda?> {
  @override
  EquipoBusqueda? build() => null;

  void elegir(EquipoBusqueda equipo) => state = equipo;

  void limpiar() => state = null;
}

final equipoSeleccionadoProvider =
    NotifierProvider<EquipoSeleccionadoNotifier, EquipoBusqueda?>(
  EquipoSeleccionadoNotifier.new,
);

/// Equipos que coinciden con el texto (número de serie, modelo o dueño).
final resultadosBusquedaProvider =
    StreamProvider.autoDispose.family<List<EquipoBusqueda>, String>(
  (ref, texto) => ref.watch(databaseProvider).historialDao.buscarEquipos(texto),
);

/// Todas las órdenes de un equipo, de la más reciente a la más antigua.
final visitasDeEquipoProvider =
    StreamProvider.autoDispose.family<List<OrdenDeEquipo>, int>(
  (ref, equipoId) =>
      ref.watch(databaseProvider).historialDao.ordenesDeEquipo(equipoId),
);