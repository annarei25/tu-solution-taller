// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_decorations.dart';
import '../../app/theme/app_text_styles.dart';

class Tarjeta extends StatelessWidget {
  const Tarjeta({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion({
    super.key,
    required this.icono,
    required this.titulo,
    this.etiqueta,
  });

  final IconData icono;
  final String titulo;
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 20, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            titulo,
            style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (etiqueta != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: const BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              etiqueta!,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}