import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formato.dart';
import '../../../data/database/app_database.dart';

class RepuestoCard extends StatelessWidget {
  const RepuestoCard({
    super.key,
    required this.repuesto,
    required this.alAjustar,
    required this.alEditar,
  });

  final Repuesto repuesto;
  final VoidCallback alAjustar;
  final VoidCallback alEditar;

  @override
  Widget build(BuildContext context) {
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
              _Icono(categoria: repuesto.categoria),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repuesto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        repuesto.codigo,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _EstadoStock(
                existencias: repuesto.existencias,
                minimo: repuesto.stockMinimo,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.surfaceContainer),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Costo taller / pieza',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      formatoDinero(repuesto.precio),
                      style: AppTextStyles.titleSm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Editar',
                  onPressed: alEditar,
                  icon: const Icon(LucideIcons.pencil, size: 18),
                ),
                OutlinedButton.icon(
                  onPressed: alAjustar,
                  icon: const Icon(LucideIcons.circle_plus, size: 16),
                  label: const Text('Ajustar'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    shape: const StadiumBorder(),
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

class _Icono extends StatelessWidget {
  const _Icono({required this.categoria});

  final String categoria;

  @override
  Widget build(BuildContext context) {
    final icono = switch (categoria) {
      'Pantallas' => LucideIcons.smartphone,
      'Baterías' => LucideIcons.battery_full,
      'Puertos' => LucideIcons.plug,
      'Cámaras' => LucideIcons.camera,
      _ => LucideIcons.package,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.5),
        borderRadius: AppRadius.card,
      ),
      child: Icon(icono, color: AppColors.secondary, size: 22),
    );
  }
}

class _EstadoStock extends StatelessWidget {
  const _EstadoStock({required this.existencias, required this.minimo});

  final int existencias;
  final int minimo;

  @override
  Widget build(BuildContext context) {
    final (fondo, texto, etiqueta) = switch (existencias) {
      0 => (AppColors.errorContainer, AppColors.onErrorContainer, 'Agotado'),
      final n when n <= minimo => (
        AppColors.ambarFondo,
        AppColors.ambar,
        'Solo $n disp.',
      ),
      final n => (
        AppColors.esmeraldaFondo,
        AppColors.esmeralda,
        '$n disponibles',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: fondo, borderRadius: AppRadius.pill),
      child: Text(
        etiqueta,
        style: AppTextStyles.labelSm.copyWith(
          color: texto,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
