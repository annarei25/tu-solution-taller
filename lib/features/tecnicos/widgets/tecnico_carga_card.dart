import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/estado_orden.dart';
import '../../../core/utils/formato.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/ordenes_dao.dart';

class TecnicoCargaCard extends StatelessWidget {
  const TecnicoCargaCard({
    super.key,
    required this.tecnico,
    required this.ordenes,
    required this.sinAsignar,
    required this.alVerOrdenes,
    required this.alAsignarPendientes,
  });

  final Tecnico tecnico;
  final List<OrdenResumen> ordenes;
  final int sinAsignar;
  final VoidCallback alVerOrdenes;
  final VoidCallback alAsignarPendientes;

  @override
  Widget build(BuildContext context) {
    final ocupado = ordenes.isNotEmpty;
    final enProceso =
        ordenes.where((o) => o.orden.estado == EstadoOrden.enReparacion).length;
    final porIniciar =
        ordenes.where((o) => o.orden.estado == EstadoOrden.recibida).length;

    // Botón según la situación: ver sus órdenes, o asignar pendientes.
    final Widget? accion = ocupado
        ? Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: alVerOrdenes,
              icon: const Icon(LucideIcons.arrow_right, size: 16),
              label: const Text('Ver sus órdenes'),
              iconAlignment: IconAlignment.end,
            ),
          )
        : (sinAsignar > 0
            ? SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: alAsignarPendientes,
                  icon: const Icon(LucideIcons.user_plus, size: 18),
                  label: const Text('Asignar órdenes pendientes'),
                ),
              )
            : null);

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
            children: [
              _Avatar(nombre: tecnico.nombre, ocupado: ocupado),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tecnico.nombre,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      tecnico.especialidad ?? 'Técnico',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _EstadoTecnico(ocupado: ocupado),
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
                    Icon(
                      ocupado ? LucideIcons.wrench : LucideIcons.circle_check,
                      size: 18,
                      color: ocupado ? AppColors.ambar : AppColors.esmeralda,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ocupado
                            ? '${ordenes.length} órdenes activas'
                            : 'Sin órdenes activas',
                        style: AppTextStyles.titleSm,
                      ),
                    ),
                    if (ocupado)
                      Text(
                        '$enProceso en proceso • $porIniciar por iniciar',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                    else
                      Text(
                        'Mesa libre para recibir',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.esmeralda,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (ocupado) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final o in ordenes) _ChipEquipo(orden: o),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (accion != null) ...[
            const SizedBox(height: 8),
            accion,
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.nombre, required this.ocupado});

  final String nombre;
  final bool ocupado;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.secondaryFixed,
          child: Text(
            nombre.substring(0, 1).toUpperCase(),
            style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: ocupado ? AppColors.bannerAmbar : AppColors.tertiaryFixedDim,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.surfaceContainerLowest,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EstadoTecnico extends StatelessWidget {
  const _EstadoTecnico({required this.ocupado});

  final bool ocupado;

  @override
  Widget build(BuildContext context) {
    final (fondo, texto, icono, etiqueta) = ocupado
        ? (AppColors.ambarFondo, AppColors.ambar, LucideIcons.wrench, 'Ocupado')
        : (
            AppColors.esmeraldaFondo,
            AppColors.esmeralda,
            LucideIcons.circle_check,
            'Disponible',
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: fondo, borderRadius: AppRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: texto),
          const SizedBox(width: 4),
          Text(
            etiqueta,
            style: AppTextStyles.labelSm.copyWith(
              color: texto,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipEquipo extends StatelessWidget {
  const _ChipEquipo({required this.orden});

  final OrdenResumen orden;

  @override
  Widget build(BuildContext context) {
    final enProceso = orden.orden.estado == EstadoOrden.enReparacion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.pill,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0D23A0),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: enProceso ? AppColors.bannerAmbar : AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            orden.equipo.modelo,
            style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Text(
            codigoOrden(orden.orden.id),
            style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}