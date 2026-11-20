import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_decorations.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/sesion_providers.dart';
import '../../../providers/tecnico_providers.dart';

class ElegirTecnicoScreen extends ConsumerWidget {
  const ElegirTecnicoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tecnicos = ref.watch(tecnicosProvider);

    return Scaffold(
      body: Column(
        children: [
          const _Encabezado(),
          Expanded(
            child: tecnicos.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (lista) {
                if (lista.isEmpty) {
                  return const Center(
                    child: Text('No hay técnicos registrados'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _TarjetaTecnico(
                    tecnico: lista[i],
                    alTocar: () => ref
                        .read(tecnicoActivoProvider.notifier)
                        .elegir(lista[i].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 24,
        16,
        28,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.header,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu Solution',
            style: AppTextStyles.headlineLgMobile.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¿Quién está usando este teléfono?',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.secondaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaTecnico extends StatelessWidget {
  const _TarjetaTecnico({required this.tecnico, required this.alTocar});

  final Tecnico tecnico;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final inicial = tecnico.nombre.substring(0, 1).toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: alTocar,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.secondaryFixed,
                  child: Text(
                    inicial,
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
                      if (tecnico.especialidad != null)
                        Text(
                          tecnico.especialidad!,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}