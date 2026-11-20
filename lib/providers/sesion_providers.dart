import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Se entrega desde main.dart, después de cargar SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Se define en main.dart'),
);

const _claveTecnico = 'tecnico_activo_id';

class TecnicoActivoNotifier extends Notifier<int?> {
  @override
  int? build() {
    return ref.watch(sharedPreferencesProvider).getInt(_claveTecnico);
  }

  Future<void> elegir(int tecnicoId) async {
    state = tecnicoId;
    await ref.read(sharedPreferencesProvider).setInt(_claveTecnico, tecnicoId);
  }

  Future<void> cerrarSesion() async {
    state = null;
    await ref.read(sharedPreferencesProvider).remove(_claveTecnico);
  }
}

/// Id del técnico activo, o null si todavía no eligió.
final tecnicoActivoProvider =
    NotifierProvider<TecnicoActivoNotifier, int?>(TecnicoActivoNotifier.new);
