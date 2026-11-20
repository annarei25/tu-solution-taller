import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/estado_orden.dart';
import '../../../core/utils/avisos.dart';
import '../../../core/utils/formato.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/inventario_dao.dart';
import '../../../providers/inventario_providers.dart';
import '../../../providers/sesion_providers.dart';
import '../../nueva_orden/views/nueva_orden_screen.dart';
import '../viewmodels/detalle_orden_viewmodel.dart';
import '../widgets/equipo_cliente_card.dart';
import '../widgets/estado_pill.dart';
import '../widgets/liquidacion_card.dart';
import '../widgets/repuestos_card.dart';
import '../widgets/tecnico_card.dart';
import '../widgets/trabajos_card.dart';

/// Un paso del flujo de estados: a qué estado va y el texto del botón.
typedef PasoEstado = ({EstadoOrden destino, String texto});

PasoEstado? _siguientePaso(EstadoOrden estado) => switch (estado) {
  EstadoOrden.recibida => (
    destino: EstadoOrden.enReparacion,
    texto: 'Iniciar reparación',
  ),
  EstadoOrden.enReparacion => (
    destino: EstadoOrden.lista,
    texto: 'Marcar como lista',
  ),
  EstadoOrden.lista => (
    destino: EstadoOrden.entregada,
    texto: 'Marcar como entregada',
  ),
  _ => null,
};

class DetalleOrdenScreen extends ConsumerWidget {
  const DetalleOrdenScreen({super.key, required this.ordenId});

  final int ordenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordenAsync = ref.watch(ordenDetalleProvider(ordenId));
    final trabajos =
        ref.watch(trabajosDeOrdenProvider(ordenId)).value ?? const <Trabajo>[];
    final usos =
        ref.watch(repuestosUsadosDeOrdenProvider(ordenId)).value ??
        const <UsoDeRepuesto>[];
    final disponibles =
        ref.watch(repuestosProvider).value ?? const <Repuesto>[];
    final activo = ref.watch(tecnicoActivoProvider);
    final vm = ref.watch(detalleOrdenViewModelProvider(ordenId));

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            titulo: 'Detalle orden',
            alRegresar: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ordenAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (resumen) {
                if (resumen == null) {
                  return const Center(child: Text('La orden no existe'));
                }

                final orden = resumen.orden;
                final esResponsable =
                    activo != null && orden.tecnicoId == activo;
                final cerrada =
                    orden.estado == EstadoOrden.entregada ||
                    orden.estado == EstadoOrden.cancelada;
                final puedeEditar = esResponsable && !cerrada;
                final paso = _siguientePaso(orden.estado);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    Tarjeta(
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ORDEN ID',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                codigoOrden(orden.id),
                                style: AppTextStyles.titleMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          EstadoPill(estado: orden.estado),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    EquipoClienteCard(resumen: resumen),
                    const SizedBox(height: 12),
                    TecnicoCard(resumen: resumen),
                    const SizedBox(height: 12),
                    _FallaCard(texto: orden.fallaReportada),
                    const SizedBox(height: 12),
                    TrabajosCard(
                      ordenId: ordenId,
                      trabajos: trabajos,
                      puedeEditar: puedeEditar,
                    ),
                    const SizedBox(height: 12),
                    RepuestosCard(
                      ordenId: ordenId,
                      usos: usos,
                      disponibles: disponibles,
                      puedeEditar: puedeEditar,
                    ),
                    const SizedBox(height: 12),
                    LiquidacionCard(trabajos: trabajos, usos: usos),
                    const SizedBox(height: 20),
                    if (puedeEditar && paso != null)
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () =>
                              _cambiarEstado(context, vm, orden.estado, paso),
                          icon: const Icon(LucideIcons.circle_check, size: 20),
                          label: Text(paso.texto),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: AppColors.onPrimary,
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    if (puedeEditar &&
                        (orden.estado == EstadoOrden.recibida ||
                            orden.estado == EstadoOrden.enReparacion)) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () =>
                              _cambiarEstado(context, vm, orden.estado, (
                                destino: EstadoOrden.cancelada,
                                texto: 'Cancelar orden',
                              )),
                          child: const Text('Cancelar orden'),
                        ),
                      ),
                    ],
                    if (cerrada) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => NuevaOrdenScreen(
                                equipoExistente: resumen.equipo,
                                clienteExistente: resumen.cliente,
                              ),
                            ),
                          ),
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text(
                            'Iniciar nueva orden para este mismo equipo',
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cambiarEstado(
    BuildContext context,
    DetalleOrdenViewModel vm,
    EstadoOrden actual,
    PasoEstado paso,
  ) async {
    final ok = await confirmar(
      context,
      '¿Confirmar: ${paso.texto.toLowerCase()}?',
    );
    if (!ok || !context.mounted) return;

    await ejecutarAccion(context, () => vm.cambiarEstado(actual, paso.destino));
  }
}

class _FallaCard extends StatelessWidget {
  const _FallaCard({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EncabezadoSeccion(
            icono: LucideIcons.triangle_exclamation_point,
            titulo: 'Falla reportada por el cliente',
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.ambarFondo,
              borderRadius: AppRadius.card,
            ),
            child: Text(texto, style: AppTextStyles.bodyLg),
          ),
        ],
      ),
    );
  }
}
