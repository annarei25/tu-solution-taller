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
import '../../../data/database/daos/inventario_dao.dart';
import '../viewmodels/detalle_orden_viewmodel.dart';

typedef NuevoUso = ({int repuestoId, int cantidad});

class RepuestosCard extends ConsumerWidget {
  const RepuestosCard({
    super.key,
    required this.ordenId,
    required this.usos,
    required this.disponibles,
    required this.puedeEditar,
  });

  final int ordenId;
  final List<UsoDeRepuesto> usos;
  final List<Repuesto> disponibles;
  final bool puedeEditar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(detalleOrdenViewModelProvider(ordenId));

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EncabezadoSeccion(
            icono: LucideIcons.package,
            titulo: 'Repuestos del almacén',
            etiqueta: '${usos.length} ${usos.length == 1 ? 'item' : 'items'}',
          ),
          const SizedBox(height: 12),
          if (usos.isEmpty)
            Text('Sin repuestos usados', style: AppTextStyles.bodyMd),
          for (final u in usos)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.card,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.repuesto.nombre, style: AppTextStyles.titleSm),
                          Text(
                            '${u.repuesto.codigo} • ${u.uso.cantidad} x '
                            '${formatoDinero(u.uso.precioUnitario)}',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatoDinero(u.uso.cantidad * u.uso.precioUnitario),
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
                          () => vm.quitarRepuesto(u.uso.id),
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
                icon: const Icon(LucideIcons.package_plus, size: 18),
                label: const Text('Añadir repuesto del almacén'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _agregar(BuildContext context, DetalleOrdenViewModel vm) async {
    final nuevo = await showDialog<NuevoUso>(
      context: context,
      builder: (_) => _DialogoRepuesto(disponibles: disponibles),
    );
    if (nuevo == null || !context.mounted) return;

    await ejecutarAccion(
      context,
      () => vm.usarRepuesto(
        repuestoId: nuevo.repuestoId,
        cantidad: nuevo.cantidad,
      ),
    );
  }
}

class _DialogoRepuesto extends StatefulWidget {
  const _DialogoRepuesto({required this.disponibles});

  final List<Repuesto> disponibles;

  @override
  State<_DialogoRepuesto> createState() => _DialogoRepuestoState();
}

class _DialogoRepuestoState extends State<_DialogoRepuesto> {
  int? _repuestoId;
  final _cantidad = TextEditingController(text: '1');

  @override
  void dispose() {
    _cantidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conStock = widget.disponibles.where((r) => r.existencias > 0);

    return AlertDialog(
      title: const Text('Repuesto del almacén'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            // En versiones nuevas de Flutter puede aparecer un aviso de
            // "deprecated" sobre value. Es solo un aviso y compila igual.
            initialValue: _repuestoId,
            isExpanded: true,
            hint: const Text('Elige un repuesto'),
            items: [
              for (final r in conStock)
                DropdownMenuItem(
                  value: r.id,
                  child: Text(
                    '${r.nombre} (${r.existencias} disp.)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (valor) => setState(() => _repuestoId = valor),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cantidad,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Cantidad'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _repuestoId == null
              ? null
              : () => Navigator.pop<NuevoUso>(context, (
                  repuestoId: _repuestoId!,
                  cantidad: int.tryParse(_cantidad.text) ?? 0,
                )),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
