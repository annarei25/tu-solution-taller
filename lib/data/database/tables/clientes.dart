import 'package:drift/drift.dart';

class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
  TextColumn get telefono => text().withLength(min: 1, max: 20)();
}
