import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/ordenes_dao.dart';
import '../viewmodels/ordenes_viewmodel.dart';

class FiltrosOrdenes extends StatelessWidget {
  const FiltrosOrdenes({
    super.key,
    required this.actual,
    required this.ordenes,
    required this.tecnicos,
    required this.alCambiar,
  });

  final FiltroOrdenes actual;
  final List<OrdenResumen> ordenes;
  final List<Tecnico> tecnicos;
  final ValueChanged<FiltroOrdenes> alCambiar;

  @override
  Widget build(BuildContext context) {
    final sinAsignar = ordenes.where((o) => o.tecnico == null).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            etiqueta: 'Todas',
            cantidad: ordenes.length,
            seleccionado: actual == const FiltroOrdenes.todas(),
            alTocar: () => alCambiar(const FiltroOrdenes.todas()),
          ),
          const SizedBox(width: 8),
          _Chip(
            etiqueta: 'Sin asignar',
            cantidad: sinAsignar,
            seleccionado: actual == const FiltroOrdenes.sinAsignar(),
            alTocar: () => alCambiar(const FiltroOrdenes.sinAsignar()),
          ),
          for (final tecnico in tecnicos) ...[
            const SizedBox(width: 8),
            _Chip(
              etiqueta: tecnico.nombre,
              cantidad: ordenes
                  .where((o) => o.orden.tecnicoId == tecnico.id)
                  .length,
              seleccionado: actual == FiltroOrdenes.tecnico(tecnico.id),
              alTocar: () => alCambiar(FiltroOrdenes.tecnico(tecnico.id)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.etiqueta,
    required this.cantidad,
    required this.seleccionado,
    required this.alTocar,
  });

  final String etiqueta;
  final int cantidad;
  final bool seleccionado;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final colorTexto = seleccionado
        ? AppColors.onSecondaryContainer
        : AppColors.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.pill,
        onTap: alTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: seleccionado
                ? AppColors.secondaryContainer
                : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.pill,
            boxShadow: seleccionado
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0F0D23A0),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                etiqueta,
                style: AppTextStyles.labelMd.copyWith(
                  color: colorTexto,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '($cantidad)',
                style: AppTextStyles.labelSm.copyWith(color: colorTexto),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
