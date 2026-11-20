import 'package:drift/drift.dart';

class Repuestos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 30).unique()();
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
  RealColumn get precio => real()();
  IntColumn get existencias => integer().withDefault(const Constant(0))();
  IntColumn get stockMinimo => integer().withDefault(const Constant(2))();
  TextColumn get categoria => text().withDefault(const Constant('Otros'))();
}


