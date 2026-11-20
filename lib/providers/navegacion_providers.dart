import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pestaña activa de la barra inferior.
/// 0 = Órdenes, 1 = Técnicos, 2 = Inventario, 3 = Historial.
class IndiceTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void ir(int indice) => state = indice;
}

final indiceTabProvider = NotifierProvider<IndiceTabNotifier, int>(
  IndiceTabNotifier.new,
);