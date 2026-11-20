import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/daos/historial_dao.dart';

/// Perfil del equipo: modelo, número de serie, dueño y cantidad de visitas.
class EquipoHistorialCard extends StatelessWidget {
  const EquipoHistorialCard({
    super.key,
    required this.dato,
    required this.cantidadVisitas,
  });

  final EquipoBusqueda dato;
  final int cantidadVisitas;

  @override
  Widget build(BuildContext context) {
    final equipo = dato.equipo;
    final cliente = dato.cliente;

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: AppRadius.card,
                ),
                child: const Icon(LucideIcons.smartphone, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISPOSITIVO REGISTRADO',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      equipo.modelo,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${equipo.marca} • ${equipo.tipo}',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  '$cantidadVisitas ${cantidadVisitas == 1 ? 'visita' : 'visitas'}',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Número de serie',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                      Text(
                        equipo.numeroSerie,
                        style: AppTextStyles.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Propietario',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                      Text(
                        cliente.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        cliente.telefono,
                        style: AppTextStyles.labelSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Un resultado de búsqueda. Al tocarlo, se abre la bitácora del equipo.
class ResultadoEquipoCard extends StatelessWidget {
  const ResultadoEquipoCard({
    super.key,
    required this.dato,
    required this.alTocar,
  });

  final EquipoBusqueda dato;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final equipo = dato.equipo;
    final cliente = dato.cliente;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: alTocar,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.card,
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withValues(alpha: 0.5),
                  borderRadius: AppRadius.card,
                ),
                child: const Icon(
                  LucideIcons.smartphone,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipo.modelo,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'S/N ${equipo.numeroSerie}',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${cliente.nombre} • ${cliente.telefono}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevron_right,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}