import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../providers/database_providers.dart';
import '../../../providers/inventario_providers.dart';

typedef DatosRepuesto = ({
  String codigo,
  String nombre,
  String categoria,
  double precio,
  int existencias,
  int stockMinimo,
});

/// Categorías que aparecen como filtros. "Todos" no filtra.
const categoriasInventario = [
  'Todos',
  'Pantallas',
  'Baterías',
  'Puertos',
  'Cámaras',
  'Otros',
];

class FiltroInventario {
  const FiltroInventario({this.categoria = 'Todos', this.busqueda = ''});

  final String categoria;
  final String busqueda;

  FiltroInventario copyWith({String? categoria, String? busqueda}) =>
      FiltroInventario(
        categoria: categoria ?? this.categoria,
        busqueda: busqueda ?? this.busqueda,
      );

  @override
  bool operator ==(Object other) =>
      other is FiltroInventario &&
      other.categoria == categoria &&
      other.busqueda == busqueda;

  @override
  int get hashCode => Object.hash(categoria, busqueda);
}

class FiltroInventarioNotifier extends Notifier<FiltroInventario> {
  @override
  FiltroInventario build() => const FiltroInventario();

  void setCategoria(String categoria) =>
      state = state.copyWith(categoria: categoria);

  void setBusqueda(String texto) => state = state.copyWith(busqueda: texto);
}

final filtroInventarioProvider =
    NotifierProvider<FiltroInventarioNotifier, FiltroInventario>(
      FiltroInventarioNotifier.new,
    );

/// Repuestos que cumplen el filtro de categoría y de texto.
final repuestosFiltradosProvider = Provider<AsyncValue<List<Repuesto>>>((ref) {
  final filtro = ref.watch(filtroInventarioProvider);
  final texto = filtro.busqueda.trim().toLowerCase();

  return ref
      .watch(repuestosProvider)
      .whenData(
        (lista) => lista.where((r) {
          final coincideCategoria =
              filtro.categoria == 'Todos' || r.categoria == filtro.categoria;
          final coincideTexto =
              texto.isEmpty ||
              r.nombre.toLowerCase().contains(texto) ||
              r.codigo.toLowerCase().contains(texto);
          return coincideCategoria && coincideTexto;
        }).toList(),
      );
});

class InventarioViewModel {
  InventarioViewModel(this._ref);

  final Ref _ref;

  Future<void> registrarEntrada(int repuestoId, int cantidad) {
    return _ref
        .read(inventarioRepositoryProvider)
        .registrarEntrada(repuestoId, cantidad);
  }

  Future<void> crear(DatosRepuesto d) =>
      _ref.read(inventarioRepositoryProvider).crear(
            codigo: d.codigo,
            nombre: d.nombre,
            categoria: d.categoria,
            precio: d.precio,
            existencias: d.existencias,
            stockMinimo: d.stockMinimo,
          );

  Future<void> editar(int id, DatosRepuesto d) =>
      _ref.read(inventarioRepositoryProvider).editar(
            id: id,
            codigo: d.codigo,
            nombre: d.nombre,
            categoria: d.categoria,
            precio: d.precio,
            stockMinimo: d.stockMinimo,
          );
}

final inventarioViewModelProvider = Provider<InventarioViewModel>(
  (ref) => InventarioViewModel(ref),
);
