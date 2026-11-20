import 'estado_orden.dart';

extension EstadoOrdenTexto on EstadoOrden {
  String get etiqueta => switch (this) {
        EstadoOrden.recibida => 'Recibida',
        EstadoOrden.enReparacion => 'En reparación',
        EstadoOrden.lista => 'Lista',
        EstadoOrden.entregada => 'Entregada',
        EstadoOrden.cancelada => 'Cancelada',
      };
}