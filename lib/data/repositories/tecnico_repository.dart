import '../database/app_database.dart';
import '../database/daos/tecnicos_dao.dart';

class TecnicoRepository {
  TecnicoRepository(this._db);

  final AppDatabase _db;

  /// Número exacto de técnicos activos que debe tener el taller.
  static const cupoTecnicos = 3;

  Stream<List<Tecnico>> watchTodos() => _db.tecnicosDao.watchTodos();

  Stream<List<CargaTecnico>> watchCarga() => _db.tecnicosDao.watchCarga();

  Future<void> editar({
    required int id,
    required String nombre,
    String? especialidad,
  }) {
    return _db.tecnicosDao.actualizar(
      id: id,
      nombre: _nombreValido(nombre),
      especialidad: _limpiar(especialidad),
    );
  }

  /// Reemplaza un técnico. Solo se permite si el taller tiene exactamente 3.
  Future<void> reemplazar({
    required int viejoId,
    required String nombre,
    String? especialidad,
  }) async {
    final activos = await _db.tecnicosDao.contarActivos();
    if (activos != cupoTecnicos) {
      throw StateError(
        'El taller debe tener $cupoTecnicos técnicos activos (hay $activos)',
      );
    }
    await _db.tecnicosDao.reemplazar(
      viejoId: viejoId,
      nombre: _nombreValido(nombre),
      especialidad: _limpiar(especialidad),
    );
  }

  String _nombreValido(String nombre) {
    final limpio = nombre.trim();
    if (limpio.isEmpty) throw ArgumentError('El nombre es obligatorio');
    return limpio;
  }

  String? _limpiar(String? texto) {
    final limpio = texto?.trim();
    return (limpio == null || limpio.isEmpty) ? null : limpio;
  }
}