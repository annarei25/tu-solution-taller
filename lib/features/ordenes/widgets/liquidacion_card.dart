import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formato.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/inventario_dao.dart';

class LiquidacionCard extends StatelessWidget {
  const LiquidacionCard({
    super.key,
    required this.trabajos,
    required this.usos,
  });

  final List<Trabajo> trabajos;
  final List<UsoDeRepuesto> usos;

  @override
  Widget build(BuildContext context) {
    final manoDeObra = trabajos.fold<double>(
      0,
      (suma, t) => suma + t.costoManoObra,
    );
    final repuestos = usos.fold<double>(
      0,
      (suma, u) => suma + u.uso.cantidad * u.uso.precioUnitario,
    );
    final total = manoDeObra + repuestos;

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EncabezadoSeccion(
            icono: LucideIcons.receipt,
            titulo: 'Resumen de liquidación',
            etiqueta: 'USD',
          ),
          const SizedBox(height: 12),
          _Linea(etiqueta: 'Mano de obra (${trabajos.length})', valor: manoDeObra),
          const SizedBox(height: 6),
          _Linea(etiqueta: 'Repuestos (${usos.length})', valor: repuestos),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total de la orden', style: AppTextStyles.titleMd),
                  Text(
                    'Mano de obra + repuestos',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                formatoDinero(total),
                style: AppTextStyles.headlineLgMobile.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea({required this.etiqueta, required this.valor});

  final String etiqueta;
  final double valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta, style: AppTextStyles.bodyMd),
        Text(formatoDinero(valor), style: AppTextStyles.titleSm),
      ],
    );
  }
}