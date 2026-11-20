import 'package:drift/drift.dart';

class Tecnicos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 60)();
  TextColumn get especialidad => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}
