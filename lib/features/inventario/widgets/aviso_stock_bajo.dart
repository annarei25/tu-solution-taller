import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';

class AvisoStockBajo extends StatelessWidget {
  const AvisoStockBajo({super.key, required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bannerAmbar.withValues(alpha: 0.2),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.bannerAmbar,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.triangle_exclamation_point,
              color: Color(0xFF4A2800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cantidad repuestos por agotarse o agotados',
                  style: AppTextStyles.titleSm.copyWith(
                    color: const Color(0xFF8C5000),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'El stock baja al usar el repuesto en una orden. '
                  'Revisa la reposición.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: const Color(0xFF663C00),
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
