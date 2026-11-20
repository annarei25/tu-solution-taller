import 'package:drift/drift.dart';
import 'ordenes.dart';
import 'repuestos.dart';

class RepuestosUsados extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ordenId => integer().references(Ordenes, #id)();
  IntColumn get repuestoId => integer().references(Repuestos, #id)();
  IntColumn get cantidad => integer()();
  RealColumn get precioUnitario => real()();
}
