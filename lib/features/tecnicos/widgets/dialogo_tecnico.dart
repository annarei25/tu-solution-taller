import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

typedef DatosTecnico = ({String nombre, String? especialidad});

Future<DatosTecnico?> mostrarDialogoTecnico(
  BuildContext context, {
  required String titulo,
  String nombre = '',
  String? especialidad,
}) {
  return showDialog<DatosTecnico>(
    context: context,
    builder: (_) => _DialogoTecnico(
      titulo: titulo,
      nombre: nombre,
      especialidad: especialidad,
    ),
  );
}

class _DialogoTecnico extends StatefulWidget {
  const _DialogoTecnico({
    required this.titulo,
    required this.nombre,
    this.especialidad,
  });

  final String titulo;
  final String nombre;
  final String? especialidad;

  @override
  State<_DialogoTecnico> createState() => _DialogoTecnicoState();
}

class _DialogoTecnicoState extends State<_DialogoTecnico> {
  late final _nombre = TextEditingController(text: widget.nombre);
  late final _especialidad =
      TextEditingController(text: widget.especialidad ?? '');

  @override
  void dispose() {
    _nombre.dispose();
    _especialidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _especialidad,
            decoration: const InputDecoration(
              hintText: 'Especialidad (opcional)',
            ),
          ),
        ],
      ),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => Navigator.pop<DatosTecnico>(
              context,
              (nombre: _nombre.text, especialidad: _especialidad.text),
            ),
            child: const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}
