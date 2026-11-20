import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_header.dart';
import '../../../data/database/daos/historial_dao.dart';
import '../../nueva_orden/views/nueva_orden_screen.dart';
import '../viewmodels/historial_viewmodel.dart';
import '../widgets/equipo_historial_card.dart';
import '../widgets/visita_card.dart';

class HistorialScreen extends ConsumerStatefulWidget {
  const HistorialScreen({super.key});

  @override
  ConsumerState<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends ConsumerState<HistorialScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Al escribir, se cierra el equipo abierto para mostrar nuevos resultados.
  void _alCambiar(String texto) {
    ref.read(textoBusquedaHistorialProvider.notifier).cambiar(texto);
    ref.read(equipoSeleccionadoProvider.notifier).limpiar();
  }

  void _limpiar() {
    _controller.clear();
    _alCambiar('');
  }

  @override
  Widget build(BuildContext context) {
    final texto = ref.watch(textoBusquedaHistorialProvider).trim();
    final seleccionado = ref.watch(equipoSeleccionadoProvider);

    return Column(
      children: [
        const AppHeader(titulo: 'Historial'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              Text(
                'Historial de reparaciones',
                style: AppTextStyles.headlineLgMobile,
              ),
              const SizedBox(height: 2),
              Text(
                'Búsqueda por número de serie, cliente o modelo',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 12),
              _Buscador(
                controller: _controller,
                alCambiar: _alCambiar,
                alLimpiar: _limpiar,
              ),
              const SizedBox(height: 16),
              if (seleccionado != null)
                _DetalleEquipo(dato: seleccionado)
              else if (texto.isEmpty)
                const _Vacio()
              else
                _Resultados(texto: texto),
            ],
          ),
        ),
      ],
    );
  }
}

class _Buscador extends StatelessWidget {
  const _Buscador({
    required this.controller,
    required this.alCambiar,
    required this.alLimpiar,
  });

  final TextEditingController controller;
  final ValueChanged<String> alCambiar;
  final VoidCallback alLimpiar;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: alCambiar,
      decoration: InputDecoration(
        hintText: 'Ej: G6TF892K0, Marcos Valdés o iPhone 13',
        prefixIcon: const Icon(LucideIcons.search, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, valor, _) => valor.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: alLimpiar,
                ),
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(
            LucideIcons.file_search,
            size: 40,
            color: AppColors.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'Busca un equipo para ver su historial',
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}

/// Lista de equipos que coinciden con la búsqueda.
class _Resultados extends ConsumerWidget {
  const _Resultados({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultados = ref.watch(resultadosBusquedaProvider(texto));

    return resultados.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error: $error'),
      data: (lista) {
        if (lista.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No hay equipos con ese dato',
                style: AppTextStyles.bodyMd,
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final d in lista)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ResultadoEquipoCard(
                  dato: d,
                  alTocar: () =>
                      ref.read(equipoSeleccionadoProvider.notifier).elegir(d),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Perfil del equipo, su bitácora y el botón para abrir una orden nueva.
class _DetalleEquipo extends ConsumerWidget {
  const _DetalleEquipo({required this.dato});

  final EquipoBusqueda dato;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitasAsync = ref.watch(visitasDeEquipoProvider(dato.equipo.id));
    final visitas = visitasAsync.value ?? const <OrdenDeEquipo>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EquipoHistorialCard(dato: dato, cantidadVisitas: visitas.length),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(
              LucideIcons.file_clock,
              size: 18,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Bitácora técnica integral',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        visitasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error: $error'),
          data: (lista) {
            if (lista.isEmpty) {
              return Text(
                'Este equipo todavía no tiene órdenes.',
                style: AppTextStyles.bodyMd,
              );
            }
            return TimelineVisitas(visitas: lista);
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NuevaOrdenScreen(desdeEquipo: dato),
              ),
            ),
            icon: const Icon(LucideIcons.circle_plus, size: 18),
            label: const Text('Iniciar nueva orden para este mismo equipo'),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Se autocompletarán los datos del cliente, modelo y número de serie.',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
        ),
        TextButton(
          onPressed: () =>
              ref.read(equipoSeleccionadoProvider.notifier).limpiar(),
          child: const Text('Buscar otro equipo'),
        ),
      ],
    );
  }
}
