import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';

class ResumenTaller extends StatelessWidget {
  const ResumenTaller({
    super.key,
    required this.abiertas,
    required this.enReparacion,
    required this.listas,
  });

  final int abiertas;
  final int enReparacion;
  final int listas;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.wrench,
                size: 18,
                color: AppColors.secondaryFixed,
              ),
              const SizedBox(width: 8),
              Text(
                'RESUMEN DE TALLER',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.secondaryFixed,
                ),
              ),
              const Spacer(),
              const _Sincronizado(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Estadistica(
                  valor: abiertas,
                  etiqueta: 'Abiertas',
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Estadistica(
                  valor: enReparacion,
                  etiqueta: 'En reparación',
                  color: AppColors.secondaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Estadistica(
                  valor: listas,
                  etiqueta: 'Listas entrega',
                  color: AppColors.tertiaryFixed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
        ],
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica({
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final int valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.5),
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: valor),
            duration: const Duration(milliseconds: 400),
            builder: (context, v, _) => Text(
              '$v',
              style: AppTextStyles.headlineLgMobile.copyWith(color: color),
            ),
          ),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.secondaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sincronizado extends StatelessWidget {
  const _Sincronizado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.4),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.tertiaryFixed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Sincronizado',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.secondaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}
