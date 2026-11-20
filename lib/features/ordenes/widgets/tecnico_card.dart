import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/avisos.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/ordenes_dao.dart';
import '../../../providers/sesion_providers.dart';
import '../../../providers/tecnico_providers.dart';
import '../viewmodels/detalle_orden_viewmodel.dart';

class TecnicoCard extends ConsumerWidget {
  const TecnicoCard({super.key, required this.resumen});

  final OrdenResumen resumen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tecnico = resumen.tecnico;
    final activo = ref.watch(tecnicoActivoProvider);
    final vm = ref.watch(detalleOrdenViewModelProvider(resumen.orden.id));

    if (tecnico == null) {
      return Tarjeta(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EncabezadoSeccion(
              icono: LucideIcons.user_check,
              titulo: 'Técnico responsable',
              etiqueta: 'Libre',
            ),
            const SizedBox(height: 12),
            Text(
              'Nadie tiene esta orden todavía.',
              style: AppTextStyles.bodyMd,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: activo == null
                    ? null
                    : () => ejecutarAccion(context, vm.tomar),
                icon: const Icon(LucideIcons.wrench, size: 18),
                label: const Text('Tomar orden'),
              ),
            ),
          ],
        ),
      );
    }

    final esMio = activo == tecnico.id;

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EncabezadoSeccion(
            icono: LucideIcons.user_check,
            titulo: 'Técnico responsable',
            etiqueta: esMio ? 'Tú' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.secondaryFixed,
                child: Text(
                  tecnico.nombre.substring(0, 1).toUpperCase(),
                  style: AppTextStyles.titleMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tecnico.nombre, style: AppTextStyles.titleMd),
                    Text(
                      esMio
                          ? 'Trabajando en este equipo'
                          : 'Otro técnico tiene esta orden',
                      style: AppTextStyles.bodyMd,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (esMio) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _transferir(context, ref, vm, tecnico),
                    icon: const Icon(LucideIcons.arrow_left_right, size: 18),
                    label: const Text('Transferir'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _liberar(context, vm, tecnico.id),
                    icon: const Icon(LucideIcons.lock_open, size: 18),
                    label: const Text('Liberar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _transferir(
    BuildContext context,
    WidgetRef ref,
    DetalleOrdenViewModel vm,
    Tecnico actual,
  ) async {
    final otros = (ref.read(tecnicosProvider).value ?? const <Tecnico>[])
        .where((t) => t.id != actual.id)
        .toList();

    if (otros.isEmpty) {
      mostrarAviso(context, 'No hay otros técnicos registrados');
      return;
    }

    final elegido = await showDialog<Tecnico>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Transferir orden a:'),
        children: [
          for (final t in otros)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, t),
              child: Text(t.nombre),
            ),
        ],
      ),
    );

    if (elegido == null || !context.mounted) return;
    await ejecutarAccion(
      context,
      () => vm.transferir(desde: actual.id, hacia: elegido.id),
    );
  }

  Future<void> _liberar(
    BuildContext context,
    DetalleOrdenViewModel vm,
    int tecnicoId,
  ) async {
    final ok = await confirmar(
      context,
      '¿Liberar la orden para que otro técnico la tome?',
    );
    if (!ok || !context.mounted) return;
    await ejecutarAccion(context, () => vm.liberar(tecnicoId));
  }
}