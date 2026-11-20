import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/historial/views/historial_screen.dart';
import '../../features/inventario/views/inventario_screen.dart';
import '../../features/nueva_orden/views/nueva_orden_screen.dart';
import '../../features/ordenes/views/ordenes_screen.dart';
import '../../features/tecnicos/views/tecnicos_screen.dart';
import '../../providers/navegacion_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text_styles.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _pantallas = <Widget>[
    OrdenesScreen(),
    TecnicosScreen(),
    InventarioScreen(),
    HistorialScreen(),
  ];

  void _abrirNuevaOrden(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NuevaOrdenScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indice = ref.watch(indiceTabProvider);

    return Scaffold(
      body: IndexedStack(index: indice, children: _pantallas),
      bottomNavigationBar: _Dock(
        indice: indice,
        alSeleccionar: (i) => ref.read(indiceTabProvider.notifier).ir(i),
        alNueva: () => _abrirNuevaOrden(context),
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  const _Dock({
    required this.indice,
    required this.alSeleccionar,
    required this.alNueva,
  });

  final int indice;
  final ValueChanged<int> alSeleccionar;
  final VoidCallback alNueva;

  @override
  Widget build(BuildContext context) {
    final inferior = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 80 + inferior,
      padding: EdgeInsets.only(bottom: inferior),
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.dock,
        boxShadow: AppShadows.dock,
      ),
      child: Row(
        children: [
          _ItemDock(
            icono: LucideIcons.clipboard_list,
            etiqueta: 'Órdenes',
            activo: indice == 0,
            alTocar: () => alSeleccionar(0),
          ),
          _ItemDock(
            icono: LucideIcons.users,
            etiqueta: 'Técnicos',
            activo: indice == 1,
            alTocar: () => alSeleccionar(1),
          ),
          _BotonNueva(alTocar: alNueva),
          _ItemDock(
            icono: LucideIcons.package,
            etiqueta: 'Inventario',
            activo: indice == 2,
            alTocar: () => alSeleccionar(2),
          ),
          _ItemDock(
            icono: LucideIcons.file_search,
            etiqueta: 'Historial',
            activo: indice == 3,
            alTocar: () => alSeleccionar(3),
          ),
        ],
      ),
    );
  }
}

class _ItemDock extends StatelessWidget {
  const _ItemDock({
    required this.icono,
    required this.etiqueta,
    required this.activo,
    required this.alTocar,
  });

  final IconData icono;
  final String etiqueta;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final color = activo
        ? AppColors.secondaryContainer
        : AppColors.secondaryFixed.withValues(alpha: 0.8);

    return Expanded(
      child: InkWell(
        onTap: alTocar,
        borderRadius: AppRadius.card,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: activo ? 1.08 : 1,
              duration: const Duration(milliseconds: 200),
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: color),
                duration: const Duration(milliseconds: 250),
                builder: (context, c, _) => Icon(icono, size: 22, color: c),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: AppTextStyles.labelSm.copyWith(
                color: color,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(etiqueta),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonNueva extends StatelessWidget {
  const _BotonNueva({required this.alTocar});

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: AppColors.secondaryContainer,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: alTocar,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.fab,
                  ),
                  child: const Icon(
                    LucideIcons.plus,
                    size: 28,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nueva',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.secondaryFixed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
