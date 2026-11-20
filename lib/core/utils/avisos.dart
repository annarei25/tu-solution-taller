import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Convierte un error en un texto que el técnico pueda leer.
String mensajeDeError(Object error) => switch (error) {
      ArgumentError(:final message) => '$message',
      StateError(:final message) => message,
      _ => error.toString(),
    };

void mostrarAviso(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

/// Ejecuta una acción. Si falla, muestra el error en pantalla.
/// Devuelve true si todo salió bien.
Future<bool> ejecutarAccion(
  BuildContext context,
  Future<void> Function() accion,
) async {
  try {
    await accion();
    return true;
  } catch (error) {
    if (context.mounted) mostrarAviso(context, mensajeDeError(error));
    return false;
  }
}

/// Pregunta antes de una acción importante. Devuelve true si el usuario confirma.
Future<bool> confirmar(BuildContext context, String pregunta) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(pregunta),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSecondaryContainer,
              minimumSize: const Size(0, 48),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ),
      ],
    ),
  );
  return ok ?? false;
}