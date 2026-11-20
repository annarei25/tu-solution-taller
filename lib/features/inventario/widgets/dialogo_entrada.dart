import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/database/app_database.dart';

/// Pide la cantidad a sumar. Devuelve la cantidad o null si se cancela.
Future<int?> mostrarDialogoEntrada(BuildContext context, Repuesto repuesto) {
  return showDialog<int>(
    context: context,
    builder: (_) => _DialogoEntrada(repuesto: repuesto),
  );
}

class _DialogoEntrada extends StatefulWidget {
  const _DialogoEntrada({required this.repuesto});

  final Repuesto repuesto;

  @override
  State<_DialogoEntrada> createState() => _DialogoEntradaState();
}

class _DialogoEntradaState extends State<_DialogoEntrada> {
  final _cantidad = TextEditingController(text: '1');

  @override
  void dispose() {
    _cantidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajustar: ${widget.repuesto.nombre}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Existencias actuales: ${widget.repuesto.existencias}',
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cantidad,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Cantidad a sumar'),
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
            onPressed: () {
              final cantidad = int.tryParse(_cantidad.text) ?? 0;
              Navigator.pop<int>(context, cantidad);
            },
            child: const Text('Confirmar'),
          ),
        ),
      ],
    );
  }
}
