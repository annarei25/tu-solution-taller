import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/daos/ordenes_dao.dart';

class EquipoClienteCard extends StatelessWidget {
  const EquipoClienteCard({super.key, required this.resumen});

  final OrdenResumen resumen;

  @override
  Widget build(BuildContext context) {
    final equipo = resumen.equipo;
    final cliente = resumen.cliente;

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: AppRadius.card,
                ),
                child: const Icon(
                  LucideIcons.smartphone,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipo.modelo,
                      style: AppTextStyles.headlineMd.copyWith(fontSize: 17),
                    ),
                    Text(
                      '${equipo.marca} • S/N: ${equipo.numeroSerie}',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
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
                const Icon(
                  LucideIcons.user,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(cliente.nombre, style: AppTextStyles.titleSm),
                ),
                Text(
                  cliente.telefono,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
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
