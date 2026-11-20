import 'package:drift/drift.dart';
import 'ordenes.dart';

class Trabajos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ordenId => integer().references(Ordenes, #id)();
  TextColumn get descripcion => text().withLength(min: 1, max: 120)();
  RealColumn get costoManoObra => real().withDefault(const Constant(0))();
}
