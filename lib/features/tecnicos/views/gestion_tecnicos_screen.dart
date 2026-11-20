import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/avisos.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/tecnico_repository.dart';
import '../../../providers/database_providers.dart';
import '../../../providers/sesion_providers.dart';
import '../../../providers/tecnico_providers.dart';
import '../widgets/dialogo_tecnico.dart';

class GestionTecnicosScreen extends ConsumerWidget {
  const GestionTecnicosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tecnicos = ref.watch(tecnicosProvider);

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            titulo: 'Gestionar técnicos',
            alRegresar: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: tecnicos.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (lista) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text(
                    'El taller tiene ${lista.length} de '
                    '${TecnicoRepository.cupoTecnicos} técnicos. Para cambiar '
                    'uno, se da de baja y se registra su reemplazo.',
                    style: AppTextStyles.bodyMd,
                  ),
                  const SizedBox(height: 12),
                  for (final t in lista)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TarjetaTecnico(tecnico: t),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaTecnico extends ConsumerWidget {
  const _TarjetaTecnico({required this.tecnico});

  final Tecnico tecnico;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(tecnicoRepositoryProvider);

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    Text(
                      tecnico.nombre,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      tecnico.especialidad ?? 'Sin especialidad',
                      style: AppTextStyles.bodyMd,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editar(context, repo),
                  icon: const Icon(LucideIcons.pencil, size: 16),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reemplazar(context, ref, repo),
                  icon: const Icon(LucideIcons.refresh_cw, size: 16),
                  label: const Text('Reemplazar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editar(BuildContext context, TecnicoRepository repo) async {
    final datos = await mostrarDialogoTecnico(
      context,
      titulo: 'Editar técnico',
      nombre: tecnico.nombre,
      especialidad: tecnico.especialidad,
    );
    if (datos == null || !context.mounted) return;

    final ok = await ejecutarAccion(
      context,
      () => repo.editar(
        id: tecnico.id,
        nombre: datos.nombre,
        especialidad: datos.especialidad,
      ),
    );
    if (ok && context.mounted) mostrarAviso(context, 'Técnico actualizado');
  }

  Future<void> _reemplazar(
    BuildContext context,
    WidgetRef ref,
    TecnicoRepository repo,
  ) async {
    final confirmado = await confirmar(
      context,
      'Se dará de baja a ${tecnico.nombre}. Sus órdenes abiertas quedarán '
      'sin técnico. ¿Continuar?',
    );
    if (!confirmado || !context.mounted) return;

    final datos = await mostrarDialogoTecnico(
      context,
      titulo: 'Nuevo técnico',
    );
    if (datos == null || !context.mounted) return;

    final ok = await ejecutarAccion(
      context,
      () => repo.reemplazar(
        viejoId: tecnico.id,
        nombre: datos.nombre,
        especialidad: datos.especialidad,
      ),
    );
    if (!ok || !context.mounted) return;

    // Si el técnico que salió era el que usa el teléfono, se cierra la sesión
    // y se vuelve a la pantalla de elegir técnico.
    if (ref.read(tecnicoActivoProvider) == tecnico.id) {
      await ref.read(tecnicoActivoProvider.notifier).cerrarSesion();
      if (context.mounted) {
        Navigator.of(context).popUntil((ruta) => ruta.isFirst);
      }
    } else if (context.mounted) {
      mostrarAviso(context, '${datos.nombre} reemplaza a ${tecnico.nombre}');
    }
  }
}
