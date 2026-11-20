import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/estado_orden.dart';
import '../../../core/enums/estado_orden_texto.dart';

/// Pastilla de color según el estado, con los colores de los HTML.
class EstadoPill extends StatelessWidget {
  const EstadoPill({super.key, required this.estado});

  final EstadoOrden estado;

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = switch (estado) {
      EstadoOrden.recibida => (
        AppColors.secondaryContainer,
        AppColors.onPrimary,
      ),
      EstadoOrden.enReparacion => (AppColors.ambarFondo, AppColors.ambar),
      EstadoOrden.lista => (
        AppColors.tertiaryFixed,
        AppColors.tertiaryContainer,
      ),
      EstadoOrden.entregada => (AppColors.esmeraldaFondo, AppColors.esmeralda),
      EstadoOrden.cancelada => (
        AppColors.errorContainer,
        AppColors.onErrorContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: fondo, borderRadius: AppRadius.pill),
      child: Text(
        estado.etiqueta.toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          color: texto,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
