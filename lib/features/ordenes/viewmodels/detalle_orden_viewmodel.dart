import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/estado_orden.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/inventario_dao.dart';
import '../../../data/database/daos/ordenes_dao.dart';
import '../../../data/repositories/orden_repository.dart';
import '../../../providers/database_providers.dart';
import '../../../providers/sesion_providers.dart';

final ordenDetalleProvider =
    StreamProvider.autoDispose.family<OrdenResumen?, int>(
  (ref, ordenId) => ref.watch(ordenRepositoryProvider).watchOrden(ordenId),
);

final trabajosDeOrdenProvider =
    StreamProvider.autoDispose.family<List<Trabajo>, int>(
  (ref, ordenId) => ref.watch(ordenRepositoryProvider).watchTrabajos(ordenId),
);

final repuestosUsadosDeOrdenProvider =
    StreamProvider.autoDispose.family<List<UsoDeRepuesto>, int>(
  (ref, ordenId) =>
      ref.watch(ordenRepositoryProvider).watchRepuestosUsados(ordenId),
);

final detalleOrdenViewModelProvider =
    Provider.autoDispose.family<DetalleOrdenViewModel, int>(
  (ref, ordenId) => DetalleOrdenViewModel(ref, ordenId),
);

class DetalleOrdenViewModel {
  DetalleOrdenViewModel(this._ref, this._ordenId);

  final Ref _ref;
  final int _ordenId;

  OrdenRepository get _repo => _ref.read(ordenRepositoryProvider);

  /// Toma la orden para el técnico activo.
  Future<void> tomar() async {
    final tecnicoId = _ref.read(tecnicoActivoProvider);
    if (tecnicoId == null) {
      throw StateError('Elige un técnico antes de tomar una orden');
    }
    final ok = await _repo.tomar(ordenId: _ordenId, tecnicoId: tecnicoId);
    if (!ok) throw StateError('Otro técnico ya tomó esta orden');
  }

  Future<void> liberar(int tecnicoId) async {
    final ok = await _repo.liberar(ordenId: _ordenId, tecnicoId: tecnicoId);
    if (!ok) throw StateError('La orden ya no está a tu nombre');
  }

  Future<void> transferir({required int desde, required int hacia}) async {
    final ok = await _repo.transferir(
      ordenId: _ordenId,
      desdeTecnicoId: desde,
      haciaTecnicoId: hacia,
    );
    if (!ok) throw StateError('La orden ya no está a tu nombre');
  }

  Future<void> cambiarEstado(EstadoOrden actual, EstadoOrden nuevo) {
    return _repo.cambiarEstado(
      ordenId: _ordenId,
      actual: actual,
      nuevo: nuevo,
    );
  }

  Future<void> agregarTrabajo(String descripcion, double costo) async {
    await _repo.agregarTrabajo(
      ordenId: _ordenId,
      descripcion: descripcion,
      costo: costo,
    );
  }

  Future<void> eliminarTrabajo(int trabajoId) {
    return _repo.eliminarTrabajo(trabajoId);
  }

  Future<void> usarRepuesto({required int repuestoId, required int cantidad}) {
    return _repo.usarRepuesto(
      ordenId: _ordenId,
      repuestoId: repuestoId,
      cantidad: cantidad,
    );
  }

  Future<void> quitarRepuesto(int usoId) => _repo.quitarRepuesto(usoId);
}