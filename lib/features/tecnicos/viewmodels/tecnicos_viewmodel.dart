import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/daos/tecnicos_dao.dart';
import '../../../providers/database_providers.dart';
import '../../ordenes/viewmodels/ordenes_viewmodel.dart';

class BusquedaTecnicosNotifier extends Notifier<String> {
  @override
  String build() => '';

  void cambiar(String texto) => state = texto;
}

final busquedaTecnicosProvider =
    NotifierProvider<BusquedaTecnicosNotifier, String>(
  BusquedaTecnicosNotifier.new,
);

/// Carga de trabajo de cada técnico, actualizada en vivo.
final cargaTecnicosProvider = StreamProvider<List<CargaTecnico>>(
  (ref) => ref.watch(tecnicoRepositoryProvider).watchCarga(),
);

/// Técnicos que coinciden con la búsqueda, por nombre o por equipo en banco.
final tecnicosFiltradosProvider =
    Provider<AsyncValue<List<CargaTecnico>>>((ref) {
  final texto = ref.watch(busquedaTecnicosProvider).trim().toLowerCase();
  final ordenes = ref.watch(ordenesAbiertasProvider).value ?? const [];

  return ref.watch(cargaTecnicosProvider).whenData((lista) {
    if (texto.isEmpty) return lista;

    return lista.where((c) {
      final porNombre = c.tecnico.nombre.toLowerCase().contains(texto);
      final porEquipo = ordenes.any(
        (o) =>
            o.orden.tecnicoId == c.tecnico.id &&
            o.equipo.modelo.toLowerCase().contains(texto),
      );
      return porNombre || porEquipo;
    }).toList();
  });
});