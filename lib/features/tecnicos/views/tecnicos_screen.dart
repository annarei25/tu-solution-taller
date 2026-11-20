import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/enums/estado_orden.dart';
import '../../../core/widgets/app_header.dart';
import '../../../data/database/daos/ordenes_dao.dart';
import '../../../providers/navegacion_providers.dart';
import '../../../providers/sesion_providers.dart';
import '../../ordenes/viewmodels/ordenes_viewmodel.dart';
import '../viewmodels/tecnicos_viewmodel.dart';
import '../widgets/tecnico_carga_card.dart';
import 'gestion_tecnicos_screen.dart';

class TecnicosScreen extends ConsumerWidget {
  const TecnicosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtrados = ref.watch(tecnicosFiltradosProvider);
    final todas =
        ref.watch(ordenesAbiertasProvider).value ?? const <OrdenResumen>[];
    final totalTecnicos = ref.watch(cargaTecnicosProvider).value?.length ?? 0;
    final porIniciar =
        todas.where((o) => o.orden.estado == EstadoOrden.recibida).length;
    final sinAsignar = todas.where((o) => o.tecnico == null).length;

    return Column(
      children: [
        const AppHeader(titulo: 'Técnicos'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Técnicos del taller',
                      style: AppTextStyles.headlineLgMobile,
                    ),
                  ),
                  const _EnDirecto(),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Carga de trabajo y asignaciones de banco',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GestionTecnicosScreen(),
                        ),
                      ),
                      icon: const Icon(LucideIcons.users, size: 16),
                      label: const Text('Gestionar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(tecnicoActivoProvider.notifier).cerrarSesion(),
                      icon: const Icon(LucideIcons.log_out, size: 16),
                      label: const Text('Cambiar de técnico'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Metrica(
                      valor: totalTecnicos,
                      etiqueta: 'Técnicos activos',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Metrica(
                      valor: todas.length,
                      etiqueta: 'Equipos en mesa',
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Metrica(
                      valor: porIniciar,
                      etiqueta: 'Por iniciar',
                      color: AppColors.tertiaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (texto) =>
                    ref.read(busquedaTecnicosProvider.notifier).cambiar(texto),
                decoration: const InputDecoration(
                  hintText: 'Filtrar técnico o equipo en banco...',
                  prefixIcon: Icon(LucideIcons.search, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              filtrados.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error: $error'),
                data: (lista) {
                  if (lista.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No hay técnicos con esa búsqueda',
                          style: AppTextStyles.bodyMd,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final c in lista)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TecnicoCargaCard(
                            tecnico: c.tecnico,
                            ordenes: todas
                                .where((o) => o.orden.tecnicoId == c.tecnico.id)
                                .toList(),
                            sinAsignar: sinAsignar,
                            alVerOrdenes: () =>
                                _verOrdenes(ref, c.tecnico.id),
                            alAsignarPendientes: () => _asignarPendientes(ref),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              const _ReglaTaller(),
            ],
          ),
        ),
      ],
    );
  }

  /// Abre la pestaña Órdenes filtrada por este técnico.
  void _verOrdenes(WidgetRef ref, int tecnicoId) {
    ref
        .read(filtroOrdenesProvider.notifier)
        .cambiar(FiltroOrdenes.tecnico(tecnicoId));
    ref.read(indiceTabProvider.notifier).ir(0);
  }

  /// Abre la pestaña Órdenes mostrando solo las que no tienen técnico.
  void _asignarPendientes(WidgetRef ref) {
    ref
        .read(filtroOrdenesProvider.notifier)
        .cambiar(const FiltroOrdenes.sinAsignar());
    ref.read(indiceTabProvider.notifier).ir(0);
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
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
          const SizedBox(height: 2),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnDirecto extends StatelessWidget {
  const _EnDirecto();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.5),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'En directo',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReglaTaller extends StatelessWidget {
  const _ReglaTaller();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}