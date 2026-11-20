import 'package:drift/drift.dart';

import '../../../core/enums/estado_orden.dart';
import 'equipos.dart';
import 'tecnicos.dart';

class Ordenes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get equipoId => integer().references(Equipos, #id)();
  IntColumn get tecnicoId => integer().nullable().references(Tecnicos, #id)();
  TextColumn get fallaReportada => text().withLength(min: 1, max: 300)();
  TextColumn get observacion => text().nullable()();
  TextColumn get estado => textEnum<EstadoOrden>()();
  DateTimeColumn get creada => dateTime().withDefault(currentDateAndTime)();
}
