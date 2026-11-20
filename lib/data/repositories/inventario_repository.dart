import '../database/app_database.dart';

class InventarioRepository {
  InventarioRepository(this._db);

  final AppDatabase _db;

  Stream<List<Repuesto>> watchRepuestos({String busqueda = ''}) =>
      _db.inventarioDao.watchRepuestos(busqueda: busqueda);

  Stream<List<Repuesto>> watchStockBajo() =>
      _db.inventarioDao.watchStockBajo();

  Future<int> crear({
    required String codigo,
    required String nombre,
    required String categoria,
    required double precio,
    int existencias = 0,
    int stockMinimo = 2,
  }) async {
    final cod = _codigoValido(codigo);
    await _verificarCodigoLibre(cod, null);

    return _db.inventarioDao.crear(
      codigo: cod,
      nombre: _nombreValido(nombre),
      categoria: categoria,
      precio: _precioValido(precio),
      existencias: existencias < 0 ? 0 : existencias,
      stockMinimo: _minimoValido(stockMinimo),
    );
  }

  /// Cambia datos del repuesto. Las existencias no se editan aquí:
  /// cambian solo con entradas o con el uso en órdenes.
  Future<void> editar({
    required int id,
    required String codigo,
    required String nombre,
    required String categoria,
    required double precio,
    required int stockMinimo,
  }) async {
    final cod = _codigoValido(codigo);
    await _verificarCodigoLibre(cod, id);

    return _db.inventarioDao.actualizar(
      id: id,
      codigo: cod,
      nombre: _nombreValido(nombre),
      categoria: categoria,
      precio: _precioValido(precio),
      stockMinimo: _minimoValido(stockMinimo),
    );
  }

  Future<void> registrarEntrada(int repuestoId, int cantidad) {
    if (cantidad <= 0) {
      throw ArgumentError.value(cantidad, 'cantidad', 'Debe ser mayor que cero');
    }
    return _db.inventarioDao.registrarEntrada(repuestoId, cantidad);
  }

  String _codigoValido(String codigo) {
    final limpio = codigo.trim().toUpperCase();
    if (limpio.isEmpty) throw ArgumentError('El código es obligatorio');
    return limpio;
  }

  String _nombreValido(String nombre) {
    final limpio = nombre.trim();
    if (limpio.isEmpty) throw ArgumentError('El nombre es obligatorio');
    return limpio;
  }

  double _precioValido(double precio) {
    if (precio < 0) {
      throw ArgumentError.value(precio, 'precio', 'No puede ser negativo');
    }
    return precio;
  }

  int _minimoValido(int minimo) {
    if (minimo < 0) {
      throw ArgumentError.value(minimo, 'stockMinimo', 'No puede ser negativo');
    }
    return minimo;
  }

  /// Evita un error técnico de SQLite: avisa con un mensaje claro.
  Future<void> _verificarCodigoLibre(String codigo, int? exceptoId) async {
    if (await _db.inventarioDao.existeCodigo(codigo, exceptoId: exceptoId)) {
      throw StateError('Ya existe un repuesto con el código $codigo');
    }
  }
}
