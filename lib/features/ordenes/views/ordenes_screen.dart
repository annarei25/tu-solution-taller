import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/estado_orden.dart';
import '../../../core/widgets/app_header.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/tecnico_providers.dart';
import '../viewmodels/ordenes_viewmodel.dart';
import '../widgets/filtros_ordenes.dart';
import '../widgets/orden_card.dart';
import '../widgets/resumen_taller.dart';
import 'detalle_orden_screen.dart';

class OrdenesScreen extends ConsumerWidget {
  const OrdenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroOrdenesProvider);
    final todas = ref.watch(ordenesAbiertasProvider).value ?? const [];
    final filtradas = ref.watch(ordenesFiltradasProvider);
    final tecnicos = ref.watch(tecnicosProvider).value ?? const <Tecnico>[];

    final sinAsignar = todas.where((o) => o.tecnico == null).length;
    final enReparacion = todas
        .where((o) => o.orden.estado == EstadoOrden.enReparacion)
        .length;
    final listas = todas
        .where((o) => o.orden.estado == EstadoOrden.lista)
        .length;

    return Column(
      children: [
        const AppHeader(titulo: 'Órdenes'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              ResumenTaller(
                abiertas: todas.length,
                enReparacion: enReparacion,
                listas: listas,
              ),
              const SizedBox(height: 12),
              if (sinAsignar > 0) ...[
                _BannerSinAsignar(
                  cantidad: sinAsignar,
                  alTocar: () => ref
                      .read(filtroOrdenesProvider.notifier)
                      .cambiar(const FiltroOrdenes.sinAsignar()),
                ),
                const SizedBox(height: 12),
              ],
              FiltrosOrdenes(
                actual: filtro,
                ordenes: todas,
                tecnicos: tecnicos,
                alCambiar: (nuevo) =>
                    ref.read(filtroOrdenesProvider.notifier).cambiar(nuevo),
              ),
              const SizedBox(height: 16),
              filtradas.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text('Error: $error'),
                data: (lista) {
                  if (lista.isEmpty) return const _SinResultados();

                  return Column(
                    children: [
                      for (final resumen in lista)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrdenCard(
                            resumen: resumen,
                            alTomar: () =>
                                _tomar(context, ref, resumen.orden.id),
                            alVerDetalle: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DetalleOrdenScreen(
                                  ordenId: resumen.orden.id,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _tomar(BuildContext context, WidgetRef ref, int ordenId) async {
    final ok = await ref.read(ordenesViewModelProvider).tomar(ordenId);
    if (ok || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo tomar: otro técnico ya la tiene'),
      ),
    );
  }
}

class _BannerSinAsignar extends StatelessWidget {
  const _BannerSinAsignar({required this.cantidad, required this.alTocar});

  final int cantidad;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final texto = cantidad == 1
        ? '1 orden sin técnico asignado'
        : '$cantidad órdenes sin técnico asignado';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: alTocar,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.15),
            borderRadius: AppRadius.card,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.bell,
                  size: 20,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texto,
                      style: AppTextStyles.titleSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevron_right,
                size: 20,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SinResultados extends StatelessWidget {
  const _SinResultados();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(LucideIcons.inbox, size: 40, color: AppColors.outline),
          const SizedBox(height: 8),
          Text('No hay órdenes en este filtro', style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}
