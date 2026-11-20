import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/database/daos/ordenes_dao.dart';
import 'estado_pill.dart';

class OrdenCard extends StatelessWidget {
  const OrdenCard({
    super.key,
    required this.resumen,
    required this.alTomar,
    required this.alVerDetalle,
  });

  final OrdenResumen resumen;
  final VoidCallback alTomar;
  final VoidCallback alVerDetalle;

  @override
  Widget build(BuildContext context) {
    final orden = resumen.orden;
    final equipo = resumen.equipo;
    final cliente = resumen.cliente;
    final tecnico = resumen.tecnico;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconoEquipo(icono: _iconoPara(equipo.tipo)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _codigo(orden.id),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      equipo.modelo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EstadoPill(estado: orden.estado),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.user,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Cliente : ${cliente.nombre}",
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      cliente.telefono,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.triangle_exclamation_point,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        orden.fallaReportada,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (tecnico == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _PillSinAsignar(),
                FilledButton.icon(
                  onPressed: alTomar,
                  icon: const Icon(LucideIcons.wrench, size: 16),
                  label: const Text('Tomar orden'),
                  style: _estiloBoton(
                    fondo: AppColors.secondaryContainer,
                    texto: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.secondaryFixed,
                      child: Text(
                        tecnico.nombre.substring(0, 1).toUpperCase(),
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tomado por:',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          tecnico.nombre,
                          style: AppTextStyles.titleSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: alVerDetalle,
                  icon: const Icon(LucideIcons.arrow_right, size: 16),
                  label: const Text('Detalles'),
                  iconAlignment: IconAlignment.end,
                  style: _estiloBoton(
                    fondo: AppColors.primaryContainer,
                    texto: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _codigo(int id) => 'ORD-${id.toString().padLeft(4, '0')}';

  static ButtonStyle _estiloBoton({
    required Color fondo,
    required Color texto,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: fondo,
      foregroundColor: texto,
      minimumSize: const Size(0, 40),
      shape: const StadiumBorder(),
      textStyle: AppTextStyles.titleSm,
    );
  }
}

IconData _iconoPara(String tipo) {
  return switch (tipo.toLowerCase()) {
    'tablet' => LucideIcons.tablet,
    'laptop' || 'portátil' || 'portatil' => LucideIcons.laptop,
    _ => LucideIcons.smartphone,
  };
}

class _IconoEquipo extends StatelessWidget {
  const _IconoEquipo({required this.icono});

  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.4),
        borderRadius: AppRadius.card,
      ),
      child: Icon(icono, size: 22, color: AppColors.secondary),
    );
  }
}

class _PillSinAsignar extends StatelessWidget {
  const _PillSinAsignar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.user_x,
            size: 14,
            color: AppColors.onErrorContainer,
          ),
          const SizedBox(width: 6),
          Text(
            'Sin asignar',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onErrorContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
