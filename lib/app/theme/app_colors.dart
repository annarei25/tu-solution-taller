import 'package:flutter/material.dart';

/// Colores tomados de la configuración de Tailwind de las pantallas HTML.
class AppColors {
  AppColors._();

  // Azul principal: encabezados, barra inferior y botones.
  static const primary = Color(0xFF001071);
  static const primaryFixed = Color(0xFFDFE0FF);
  static const primaryContainer = Color(0xFF0D23A0);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF8A98FF);

  // Cian: botón central, filtros activos y acciones secundarias.
  static const secondary = Color(0xFF006591);
  static const secondaryContainer = Color(0xFF39B8FD);
  static const onSecondaryContainer = Color(0xFF004666);
  static const secondaryFixed = Color(0xFFC9E6FF);
  static const onSecondaryFixed = Color(0xFF001E2F);

  // Verde: listo, entregado, con stock.
  static const tertiaryContainer = Color(0xFF00402A);
  static const tertiaryFixed = Color(0xFF6FFBBE);
  static const tertiaryFixedDim = Color(0xFF4EDEA3);
  static const onTertiaryContainer = Color(0xFF06B77F);

  // Fondos y superficies.
  static const background = Color(0xFFF6F9FE);
  static const surface = background;
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF1F4F9);
  static const surfaceContainer = Color(0xFFEBEEF3);
  static const surfaceContainerHigh = Color(0xFFE5E8ED);

  // Textos y bordes.
  static const onSurface = Color(0xFF181C20);
  static const onSurfaceVariant = Color(0xFF454653);
  static const outline = Color(0xFF757685);
  static const outlineVariant = Color(0xFFC5C5D6);

  // Error y alertas.
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Estados de la orden y avisos de stock (de los HTML).
  static const ambar = Color(0xFFB45309);
  static const ambarFondo = Color(0xFFFEF3C7);
  static const bannerAmbar = Color(0xFFFFB74D);
  static const esmeralda = Color(0xFF047857);
  static const esmeraldaFondo = Color(0xFFD1FAE5);
}
