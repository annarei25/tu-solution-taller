import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/daos/ordenes_dao.dart';
import '../../../providers/database_providers.dart';
import '../../../providers/sesion_providers.dart';

enum TipoFiltro { todas, sinAsignar, tecnico }

class FiltroOrdenes {
  const FiltroOrdenes.todas()
      : tipo = TipoFiltro.todas,
        tecnicoId = null;

  const FiltroOrdenes.sinAsignar()
      : tipo = TipoFiltro.sinAsignar,
        tecnicoId = null;

  const FiltroOrdenes.tecnico(int id)
      : tipo = TipoFiltro.tecnico,
        tecnicoId = id;

  final TipoFiltro tipo;
  final int? tecnicoId;

  @override
  bool operator ==(Object other) =>
      other is FiltroOrdenes &&
      other.tipo == tipo &&
      other.tecnicoId == tecnicoId;

  @override
  int get hashCode => Object.hash(tipo, tecnicoId);
}

class FiltroOrdenesNotifier extends Notifier<FiltroOrdenes> {
  @override
  FiltroOrdenes build() => const FiltroOrdenes.todas();

  void cambiar(FiltroOrdenes nuevo) => state = nuevo;
}

final filtroOrdenesProvider =
    NotifierProvider<FiltroOrdenesNotifier, FiltroOrdenes>(
  FiltroOrdenesNotifier.new,
);

/// Todas las órdenes abiertas, sin filtrar.
final ordenesAbiertasProvider = StreamProvider<List<OrdenResumen>>(
  (ref) => ref.watch(ordenRepositoryProvider).watchAbiertas(),
);

/// Las órdenes abiertas, filtradas según la opción elegida.
final ordenesFiltradasProvider = Provider<AsyncValue<List<OrdenResumen>>>((ref) {
  final filtro = ref.watch(filtroOrdenesProvider);

  return ref.watch(ordenesAbiertasProvider).whenData(
        (lista) => lista.where((o) {
          return switch (filtro.tipo) {
            TipoFiltro.todas => true,
            TipoFiltro.sinAsignar => o.tecnico == null,
            TipoFiltro.tecnico => o.orden.tecnicoId == filtro.tecnicoId,
          };
        }).toList(),
      );
});

class OrdenesViewModel {
  OrdenesViewModel(this._ref);

  final Ref _ref;

  /// Toma la orden para el técnico activo. Devuelve false si otro técnico
  /// ya la tiene o si no hay técnico activo.
  Future<bool> tomar(int ordenId) {
    final tecnicoId = _ref.read(tecnicoActivoProvider);
    if (tecnicoId == null) return Future.value(false);

    return _ref.read(ordenRepositoryProvider).tomar(
          ordenId: ordenId,
          tecnicoId: tecnicoId,
        );
  }
}

final ordenesViewModelProvider = Provider<OrdenesViewModel>(
  (ref) => OrdenesViewModel(ref),
);