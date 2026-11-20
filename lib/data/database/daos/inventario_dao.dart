import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/ordenes.dart';
import '../tables/repuestos.dart';
import '../tables/repuestos_usados.dart';

part 'inventario_dao.g.dart';

/// Se lanza cuando se intenta usar más unidades de las que hay en almacén.
class StockInsuficienteException implements Exception {
  StockInsuficienteException(this.nombre, this.disponibles);

  final String nombre;
  final int disponibles;

  @override
  String toString() => 'Solo quedan $disponibles unidades de $nombre';
}

typedef UsoDeRepuesto = ({RepuestosUsado uso, Repuesto repuesto});

@DriftAccessor(tables: [Repuestos, RepuestosUsados, Ordenes])
class InventarioDao extends DatabaseAccessor<AppDatabase>
    with _$InventarioDaoMixin {
  InventarioDao(super.attachedDatabase);

  /// Repuestos que coinciden con el texto, por nombre o por código.
  /// Con texto vacío devuelve todo el inventario.
  Stream<List<Repuesto>> watchRepuestos({String busqueda = ''}) {
    final patron = '%${busqueda.trim()}%';

    return (select(repuestos)
          ..where((r) => r.nombre.like(patron) | r.codigo.like(patron))
          ..orderBy([(r) => OrderingTerm.asc(r.nombre)]))
        .watch();
  }

  /// Repuestos cuyas existencias llegaron al mínimo o están por debajo.
  Stream<List<Repuesto>> watchStockBajo() {
    return (select(repuestos)
          ..where((r) => r.existencias.isSmallerOrEqual(r.stockMinimo))
          ..orderBy([(r) => OrderingTerm.asc(r.existencias)]))
        .watch();
  }

  Future<int> crear({
    required String codigo,
    required String nombre,
    required double precio,
    String categoria = 'Otros',
    int existencias = 0,
    int stockMinimo = 2,
  }) {
    return into(repuestos).insert(
      RepuestosCompanion.insert(
        codigo: codigo,
        nombre: nombre,
        precio: precio,
        categoria: Value(categoria),
        existencias: Value(existencias),
        stockMinimo: Value(stockMinimo),
      ),
    );
  }

  /// Cambia datos del repuesto. Las existencias no se tocan aquí.
  Future<void> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    required String categoria,
    required double precio,
    required int stockMinimo,
  }) {
    return (update(repuestos)..where((r) => r.id.equals(id))).write(
      RepuestosCompanion(
        codigo: Value(codigo),
        nombre: Value(nombre),
        categoria: Value(categoria),
        precio: Value(precio),
        stockMinimo: Value(stockMinimo),
      ),
    );
  }

  /// true si ya existe un repuesto con ese código (sin contar [exceptoId]).
  Future<bool> existeCodigo(String codigo, {int? exceptoId}) async {
    final filas = await (select(repuestos)
          ..where((r) => r.codigo.equals(codigo)))
        .get();
    return filas.any((r) => r.id != exceptoId);
  }

  /// Entrada de mercadería: suma unidades al almacén.
  Future<void> registrarEntrada(int repuestoId, int cantidad) {
    return (update(repuestos)..where((r) => r.id.equals(repuestoId))).write(
      RepuestosCompanion.custom(
        existencias: repuestos.existencias + Constant(cantidad),
      ),
    );
  }

  /// Usa un repuesto en una orden. Descuenta el stock y guarda el uso
  /// en una sola transacción. Si no hay suficiente stock, lanza
  /// [StockInsuficienteException] y no cambia nada.
  Future<void> usarEnOrden({
    required int ordenId,
    required int repuestoId,
    required int cantidad,
  }) {
    return transaction(() async {
      final repuesto = await (select(
        repuestos,
      )..where((r) => r.id.equals(repuestoId))).getSingle();

      if (repuesto.existencias < cantidad) {
        throw StockInsuficienteException(repuesto.nombre, repuesto.existencias);
      }

      await (update(repuestos)..where((r) => r.id.equals(repuestoId))).write(
        RepuestosCompanion.custom(
          existencias: repuestos.existencias - Constant(cantidad),
        ),
      );

      await into(repuestosUsados).insert(
        RepuestosUsadosCompanion.insert(
          ordenId: ordenId,
          repuestoId: repuestoId,
          cantidad: cantidad,
          precioUnitario: repuesto.precio,
        ),
      );
    });
  }

  /// Quita un repuesto de una orden y devuelve las unidades al almacén.
  Future<void> quitarDeOrden(int usoId) {
    return transaction(() async {
      final uso = await (select(
        repuestosUsados,
      )..where((u) => u.id.equals(usoId))).getSingle();

      await (update(
        repuestos,
      )..where((r) => r.id.equals(uso.repuestoId))).write(
        RepuestosCompanion.custom(
          existencias: repuestos.existencias + Constant(uso.cantidad),
        ),
      );

      await (delete(repuestosUsados)..where((u) => u.id.equals(usoId))).go();
    });
  }

  /// Repuestos usados en una orden, con su nombre y código.
  Stream<List<UsoDeRepuesto>> watchUsadosDeOrden(int ordenId) {
    final consulta = select(repuestosUsados).join([
      innerJoin(repuestos, repuestos.id.equalsExp(repuestosUsados.repuestoId)),
    ]);
    consulta.where(repuestosUsados.ordenId.equals(ordenId));

    return consulta.watch().map(
      (filas) => [
        for (final fila in filas)
          (
            uso: fila.readTable(repuestosUsados),
            repuesto: fila.readTable(repuestos),
          ),
      ],
    );
  }
}
