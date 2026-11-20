import 'package:drift/drift.dart';
import 'clientes.dart';

class Equipos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id)();
  TextColumn get tipo => text().withLength(min: 1, max: 30)();
  TextColumn get marca => text().withLength(min: 1, max: 40)();
  TextColumn get modelo => text().withLength(min: 1, max: 60)();
  TextColumn get numeroSerie =>
      text().withLength(min: 1, max: 60).unique()();
}
