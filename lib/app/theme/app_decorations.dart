import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppRadius {
  AppRadius._();

  static const card = BorderRadius.all(Radius.circular(16));
  static const pill = BorderRadius.all(Radius.circular(999));
  static const header = BorderRadius.vertical(bottom: Radius.circular(28));
  static const dock = BorderRadius.vertical(top: Radius.circular(28));
}

class AppShadows {
  AppShadows._();

  /// Sombra suave azulada para tarjetas (Nivel 1 de DESIGN.md).
  static const card = [
    BoxShadow(
      color: Color(0x0F0D23A0),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  /// Sombra de la barra inferior, hacia arriba.
  static const dock = [
    BoxShadow(
      color: Color(0x330D23A0),
      offset: Offset(0, -8),
      blurRadius: 24,
    ),
  ];

  /// Sombra cian del botón central.
  static const fab = [
    BoxShadow(
      color: Color(0x7339B8FD),
      offset: Offset(0, 10),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];
}