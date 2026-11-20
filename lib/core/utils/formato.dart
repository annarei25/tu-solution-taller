/// Formato de dinero: 85.5 -> $85.50
String formatoDinero(double valor) => '\$${valor.toStringAsFixed(2)}';

/// Código visible de la orden: 42 -> ORD-0042
String codigoOrden(int id) => 'ORD-${id.toString().padLeft(4, '0')}';

const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// Fecha corta en español: 24 oct 2024
String formatoFecha(DateTime fecha) =>
    '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';
