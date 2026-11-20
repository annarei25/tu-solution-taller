import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/estado_orden.dart';
import '../../../core/utils/formato.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/historial_dao.dart';
import '../../../data/database/daos/inventario_dao.dart';
import '../../ordenes/viewmodels/detalle_orden_viewmodel.dart';
import '../../ordenes/views/detalle_orden_screen.dart';
import '../../ordenes/widgets/estado_pill.dart';

/// Lista vertical de visitas unidas por una línea.
class TimelineVisitas extends StatelessWidget {
  const TimelineVisitas({super.key, required this.visitas});

  final List<OrdenDeEquipo> visitas;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < visitas.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      _Marcador(
                        estado: visitas[i].orden.estado,
                        esActual: i == 0,
                      ),
                      if (i < visitas.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VisitaCard(
                      orden: visitas[i],
                      etiqueta: _etiqueta(i, visitas.length),
                      esActual: i == 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _etiqueta(int indice, int total) {
    if (indice == 0) return 'Visita actual';
    if (indice == total - 1) return 'Visita inicial';
    return 'Visita anterior';
  }
}

class _Marcador extends StatelessWidget {
  const _Marcador({required this.estado, required this.esActual});

  final EstadoOrden estado;
  final bool esActual;

  @override
  Widget build(BuildContext context) {
    final (fondo, icono) = switch (estado) {
      EstadoOrden.entregada => (AppColors.tertiaryFixed, LucideIcons.circle_check),
      EstadoOrden.cancelada => (AppColors.errorContainer, LucideIcons.circle_x),
      _ => (
          esActual ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
          LucideIcons.wrench,
        ),
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: fondo,
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
      ),
      child: Icon(icono, size: 16, color: AppColors.primary),
    );
  }
}

class VisitaCard extends ConsumerWidget {
  const VisitaCard({
    super.key,
    required this.orden,
    required this.etiqueta,
    required this.esActual,
  });

  final OrdenDeEquipo orden;
  final String etiqueta;
  final bool esActual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = orden.orden;
    final ordenId = datos.id;

    final trabajos =
        ref.watch(trabajosDeOrdenProvider(ordenId)).value ?? const <Trabajo>[];
    final usos = ref.watch(repuestosUsadosDeOrdenProvider(ordenId)).value ??
        const <UsoDeRepuesto>[];

    final manoDeObra = trabajos.fold<double>(
      0,
      (suma, t) => suma + t.costoManoObra,
    );
    final repuestos = usos.fold<double>(
      0,
      (suma, u) => suma + u.uso.cantidad * u.uso.precioUnitario,
    );

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${etiqueta.toUpperCase()} • ${formatoFecha(datos.creada)}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: esActual ? AppColors.secondary : AppColors.outline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      codigoOrden(ordenId),
                      style: AppTextStyles.titleSm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              EstadoPill(estado: datos.estado),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.card,
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.user, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Técnico',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                      Text(
                        orden.tecnico?.nombre ?? 'Sin técnico',
                        style: AppTextStyles.titleSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Falla: ',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: datos.fallaReportada,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (trabajos.isNotEmpty || usos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.card,
              ),
              child: Column(
                children: [
                  for (final t in trabajos)
                    _Linea(texto: t.descripcion, valor: t.costoManoObra),
                  for (final u in usos)
                    _Linea(
                      texto: '${u.repuesto.nombre} x${u.uso.cantidad}',
                      valor: u.uso.cantidad * u.uso.precioUnitario,
                    ),
                ],
              ),
            ),
          ],
          if (datos.observacion != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.ambarFondo,
                borderRadius: AppRadius.card,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info, size: 16, color: AppColors.ambar),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      datos.observacion!,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.ambar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Total facturado',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const Spacer(),
              Text(
                formatoDinero(manoDeObra + repuestos),
                style: AppTextStyles.titleSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DetalleOrdenScreen(ordenId: ordenId),
                ),
              ),
              icon: const Icon(LucideIcons.arrow_right, size: 16),
              label: const Text('Ver ficha'),
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea({required this.texto, required this.valor});

  final String texto;
  final double valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
            ),
          ),
          Text(
            formatoDinero(valor),
            style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}