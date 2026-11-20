import '../../core/enums/estado_orden.dart';
import '../database/app_database.dart';
import '../database/daos/inventario_dao.dart';
import '../database/daos/ordenes_dao.dart';

/// Reglas de las órdenes. Las pantallas llaman estos métodos
/// y nunca escriben directamente en la base de datos.
class OrdenRepository {
  OrdenRepository(this._db);

  final AppDatabase _db;

  /// Estados a los que puede pasar una orden desde cada estado.
  static const Map<EstadoOrden, Set<EstadoOrden>> _transiciones = {
    EstadoOrden.recibida: {EstadoOrden.enReparacion, EstadoOrden.cancelada},
    EstadoOrden.enReparacion: {EstadoOrden.lista, EstadoOrden.cancelada},
    EstadoOrden.lista: {EstadoOrden.entregada},
    EstadoOrden.entregada: <EstadoOrden>{},
    EstadoOrden.cancelada: <EstadoOrden>{},
  };

  Stream<List<OrdenResumen>> watchAbiertas({int? tecnicoId}) =>
      _db.ordenesDao.watchAbiertas(tecnicoId: tecnicoId);

  Stream<OrdenResumen?> watchOrden(int ordenId) =>
      _db.ordenesDao.watchPorId(ordenId);

  Future<int> recibirEquipo({
    required String clienteNombre,
    required String telefono,
    required String tipo,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required String falla,
  }) {
    if (numeroSerie.trim().isEmpty) {
      throw ArgumentError('El número de serie es obligatorio');
    }
    return _db.equiposDao.recibir(
      clienteNombre: clienteNombre.trim(),
      telefono: telefono.trim(),
      tipo: tipo,
      marca: marca.trim(),
      modelo: modelo.trim(),
      numeroSerie: numeroSerie.trim(),
      falla: falla.trim(),
    );
  }

  /// Devuelve false si la orden ya tiene técnico (otro la tomó antes).
  Future<bool> tomar({required int ordenId, required int tecnicoId}) {
    return _db.ordenesDao.cambiarTecnico(
      ordenId: ordenId,
      desde: null,
      hacia: tecnicoId,
    );
  }

  Future<bool> liberar({required int ordenId, required int tecnicoId}) {
    return _db.ordenesDao.cambiarTecnico(
      ordenId: ordenId,
      desde: tecnicoId,
      hacia: null,
    );
  }

  Future<bool> transferir({
    required int ordenId,
    required int desdeTecnicoId,
    required int haciaTecnicoId,
  }) {
    return _db.ordenesDao.cambiarTecnico(
      ordenId: ordenId,
      desde: desdeTecnicoId,
      hacia: haciaTecnicoId,
    );
  }

  /// Lanza [StateError] si el cambio no está permitido.
  Future<void> cambiarEstado({
    required int ordenId,
    required EstadoOrden actual,
    required EstadoOrden nuevo,
  }) {
    final permitidos = _transiciones[actual] ?? const <EstadoOrden>{};
    if (!permitidos.contains(nuevo)) {
      throw StateError('No se puede pasar de ${actual.name} a ${nuevo.name}');
    }
    return _db.ordenesDao.cambiarEstado(ordenId, nuevo);
  }

  Stream<List<Trabajo>> watchTrabajos(int ordenId) =>
      _db.trabajosDao.watchDeOrden(ordenId);

  Future<int> agregarTrabajo({
    required int ordenId,
    required String descripcion,
    required double costo,
  }) {
    final texto = descripcion.trim();
    if (texto.isEmpty) {
      throw ArgumentError('La descripción del trabajo es obligatoria');
    }
    if (costo < 0) {
      throw ArgumentError.value(costo, 'costo', 'No puede ser negativo');
    }
    return _db.trabajosDao.agregar(
      ordenId: ordenId,
      descripcion: texto,
      costo: costo,
    );
  }

  Future<void> eliminarTrabajo(int trabajoId) =>
      _db.trabajosDao.eliminar(trabajoId);

  Stream<List<UsoDeRepuesto>> watchRepuestosUsados(int ordenId) =>
      _db.inventarioDao.watchUsadosDeOrden(ordenId);

  Future<void> usarRepuesto({
    required int ordenId,
    required int repuestoId,
    required int cantidad,
  }) {
    if (cantidad <= 0) {
      throw ArgumentError.value(
        cantidad,
        'cantidad',
        'Debe ser mayor que cero',
      );
    }
    return _db.inventarioDao.usarEnOrden(
      ordenId: ordenId,
      repuestoId: repuestoId,
      cantidad: cantidad,
    );
  }

  Future<void> quitarRepuesto(int usoId) =>
      _db.inventarioDao.quitarDeOrden(usoId);

  /// Mano de obra más repuestos, con los datos actuales de la orden.
  Future<double> calcularTotal(int ordenId) async {
    final trabajos = await _db.trabajosDao.watchDeOrden(ordenId).first;
    final usados = await _db.inventarioDao.watchUsadosDeOrden(ordenId).first;

    final manoDeObra = trabajos.fold<double>(
      0,
      (suma, t) => suma + t.costoManoObra,
    );
    final repuestos = usados.fold<double>(
      0,
      (suma, r) => suma + r.uso.cantidad * r.uso.precioUnitario,
    );

    return manoDeObra + repuestos;
  }
}
