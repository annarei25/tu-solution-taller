import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/seed.dart';
import '../features/sesion/views/elegir_tecnico_screen.dart';
import '../providers/database_providers.dart';
import '../providers/sesion_providers.dart';
import 'shell/main_shell.dart';
import 'theme/app_theme.dart';

final datosInicialesProvider = FutureProvider<void>(
  (ref) => cargarDatosDePrueba(ref.watch(databaseProvider)),
);

class TuSolutionApp extends ConsumerStatefulWidget {
  const TuSolutionApp({super.key});

  @override
  ConsumerState<TuSolutionApp> createState() => _TuSolutionAppState();
}

class _TuSolutionAppState extends ConsumerState<TuSolutionApp> {
  late final Future<void> _datosListos;

  @override
  void initState() {
    super.initState();
    _datosListos = ref.read(datosInicialesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final tecnicoId = ref.watch(tecnicoActivoProvider);

    return MaterialApp(
      title: 'Tu Solution',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FutureBuilder<void>(
        future: _datosListos,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'No se pudieron cargar los datos: ${snapshot.error}',
                ),
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return tecnicoId == null
              ? const ElegirTecnicoScreen()
              : const MainShell();
        },
      ),
    );
  }
}
