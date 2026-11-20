import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_decorations.dart';
import '../../app/theme/app_text_styles.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.titulo, this.alRegresar});

  final String titulo;

  /// Si se indica, aparece una flecha para volver atrás.
  final VoidCallback? alRegresar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        alRegresar == null ? 16 : 8,
        MediaQuery.paddingOf(context).top + 8,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.header,
        boxShadow: [
          BoxShadow(
            color: Color(0x2E0D23A0),
            offset: Offset(0, 12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          if (alRegresar != null)
            IconButton(
              onPressed: alRegresar,
              icon: const Icon(LucideIcons.arrow_left, color: AppColors.onPrimary),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    
                    const SizedBox(width: 6),
                    
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Tu Solution - $titulo",
                  style: AppTextStyles.headlineMd.copyWith(
                    color: AppColors.onPrimary,
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