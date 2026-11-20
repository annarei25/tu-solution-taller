import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/avisos.dart';
import '../../../core/utils/formato.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/app_database.dart';
import '../viewmodels/detalle_orden_viewmodel.dart';

typedef NuevoTrabajo = ({String descripcion, double costo});

class TrabajosCard extends ConsumerWidget {
  const TrabajosCard({
    super.key,
    required this.ordenId,
    required this.trabajos,
    required this.puedeEditar,
  });

  final int ordenId;
  final List<Trabajo> trabajos;
  final bool puedeEditar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(detalleOrdenViewModelProvider(ordenId));

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EncabezadoSeccion(
            icono: LucideIcons.hammer,
            titulo: 'Trabajos y mano de obra',
            etiqueta: '${trabajos.length} tareas',
          ),
          const SizedBox(height: 12),
          if (trabajos.isEmpty)
            Text('Sin trabajos registrados', style: AppTextStyles.bodyMd),
          for (final t in trabajos)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.card,
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.circle_check,
                      size: 18,
                      color: AppColors.onTertiaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.descripcion,
                        style: AppTextStyles.bodyLg.copyWith(fontSize: 14),
                      ),
                    ),
                    Text(
                      formatoDinero(t.costoManoObra),
                      style: AppTextStyles.titleSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (puedeEditar)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Quitar',
                        icon: const Icon(
                          LucideIcons.trash,
                          size: 18,
                          color: AppColors.error,
                        ),
                        onPressed: () => ejecutarAccion(
                          context,
                          () => vm.eliminarTrabajo(t.id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (puedeEditar) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _agregar(context, vm),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Agregar mano de obra'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _agregar(BuildContext context, DetalleOrdenViewModel vm) async {
    final nuevo = await showDialog<NuevoTrabajo>(
      context: context,
      builder: (_) => const _DialogoTrabajo(),
    );
    if (nuevo == null || !context.mounted) return;

    await ejecutarAccion(
      context,
      () => vm.agregarTrabajo(nuevo.descripcion, nuevo.costo),
    );
  }
}

class _DialogoTrabajo extends StatefulWidget {
  const _DialogoTrabajo();

  @override
  State<_DialogoTrabajo> createState() => _DialogoTrabajoState();
}

class _DialogoTrabajoState extends State<_DialogoTrabajo> {
  final _descripcion = TextEditingController();
  final _costo = TextEditingController();

  @override
  void dispose() {
    _descripcion.dispose();
    _costo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo trabajo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descripcion,
            decoration: const InputDecoration(hintText: 'Descripción'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _costo,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Costo (USD)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final costo =
                double.tryParse(_costo.text.replaceAll(',', '.')) ?? 0;
            Navigator.pop<NuevoTrabajo>(context, (
              descripcion: _descripcion.text,
              costo: costo,
            ));
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
