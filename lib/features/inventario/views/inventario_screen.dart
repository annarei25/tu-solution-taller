import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/avisos.dart';
import '../../../core/widgets/app_header.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/inventario_providers.dart';
import '../viewmodels/inventario_viewmodel.dart';
import '../widgets/aviso_stock_bajo.dart';
import '../widgets/dialogo_entrada.dart';
import '../widgets/dialogo_repuesto.dart';
import '../widgets/repuesto_card.dart';

class InventarioScreen extends ConsumerWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroInventarioProvider);
    final filtrados = ref.watch(repuestosFiltradosProvider);
    final todos = ref.watch(repuestosProvider).value ?? const <Repuesto>[];
    final stockBajo = todos.where((r) => r.existencias <= r.stockMinimo).length;

    return Column(
      children: [
        const AppHeader(titulo: 'Inventario'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Almacén de repuestos',
                      style: AppTextStyles.headlineLgMobile,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      '${todos.length} ítems',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSecondaryFixed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Control de stock físico y alertas de reposición',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _nuevo(context, ref),
                icon: const Icon(LucideIcons.package_plus, size: 18),
                label: const Text('Nuevo repuesto'),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (texto) => ref
                    .read(filtroInventarioProvider.notifier)
                    .setBusqueda(texto),
                decoration: const InputDecoration(
                  hintText: 'Buscar por código o nombre...',
                  prefixIcon: Icon(LucideIcons.search, size: 20),
                ),
              ),
              if (stockBajo > 0) ...[
                const SizedBox(height: 12),
                AvisoStockBajo(cantidad: stockBajo),
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final categoria in categoriasInventario)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _ChipCategoria(
                          etiqueta: categoria,
                          seleccionado: filtro.categoria == categoria,
                          alTocar: () => ref
                              .read(filtroInventarioProvider.notifier)
                              .setCategoria(categoria),
                        ),
                      ),
                  ],
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
                          'No hay repuestos con este filtro',
                          style: AppTextStyles.bodyMd,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final repuesto in lista)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RepuestoCard(
                            repuesto: repuesto,
                            alAjustar: () => _ajustar(context, ref, repuesto),
                            alEditar: () => _editar(context, ref, repuesto),
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

  Future<void> _ajustar(
    BuildContext context,
    WidgetRef ref,
    Repuesto repuesto,
  ) async {
    final cantidad = await mostrarDialogoEntrada(context, repuesto);
    if (cantidad == null || !context.mounted) return;

    await ejecutarAccion(
      context,
      () => ref
          .read(inventarioViewModelProvider)
          .registrarEntrada(repuesto.id, cantidad),
    );
  }

  Future<void> _nuevo(BuildContext context, WidgetRef ref) async {
    final datos = await mostrarDialogoRepuesto(context);
    if (datos == null || !context.mounted) return;

    final ok = await ejecutarAccion(
      context,
      () => ref.read(inventarioViewModelProvider).crear(datos),
    );
    if (ok && context.mounted) mostrarAviso(context, 'Repuesto registrado');
  }

  Future<void> _editar(BuildContext context, WidgetRef ref, Repuesto r) async {
    final datos = await mostrarDialogoRepuesto(context, inicial: r);
    if (datos == null || !context.mounted) return;

    final ok = await ejecutarAccion(
      context,
      () => ref.read(inventarioViewModelProvider).editar(r.id, datos),
    );
    if (ok && context.mounted) mostrarAviso(context, 'Repuesto actualizado');
  }
}

class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria({
    required this.etiqueta,
    required this.seleccionado,
    required this.alTocar,
  });

  final String etiqueta;
  final bool seleccionado;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.pill,
        onTap: alTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: seleccionado
                ? AppColors.secondaryContainer
                : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.pill,
          ),
          child: Text(
            etiqueta,
            style: AppTextStyles.labelMd.copyWith(
              color: seleccionado
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
