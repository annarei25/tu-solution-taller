import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../viewmodels/inventario_viewmodel.dart';

/// Pide los datos de un repuesto. Si [inicial] viene lleno, es edición
/// y no se piden las existencias iniciales.
Future<DatosRepuesto?> mostrarDialogoRepuesto(
  BuildContext context, {
  Repuesto? inicial,
}) {
  return showDialog<DatosRepuesto>(
    context: context,
    builder: (_) => _DialogoRepuesto(inicial: inicial),
  );
}

class _DialogoRepuesto extends StatefulWidget {
  const _DialogoRepuesto({this.inicial});

  final Repuesto? inicial;

  @override
  State<_DialogoRepuesto> createState() => _DialogoRepuestoState();
}

class _DialogoRepuestoState extends State<_DialogoRepuesto> {
  late final _codigo = TextEditingController(text: widget.inicial?.codigo ?? '');
  late final _nombre = TextEditingController(text: widget.inicial?.nombre ?? '');
  late final _precio = TextEditingController(
    text: widget.inicial?.precio.toString() ?? '',
  );
  final _existencias = TextEditingController(text: '0');
  late final _minimo = TextEditingController(
    text: '${widget.inicial?.stockMinimo ?? 2}',
  );

  final _categorias = const [
    'Pantallas',
    'Baterías',
    'Puertos',
    'Cámaras',
    'Otros',
  ];
  late String _categoria = widget.inicial?.categoria ?? 'Pantallas';

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _precio.dispose();
    _existencias.dispose();
    _minimo.dispose();
    super.dispose();
  }

  void _guardar() {
    // Un precio no válido se envía como -1 para que el repositorio lo rechace.
    final precio = double.tryParse(_precio.text.replaceAll(',', '.')) ?? -1;

    Navigator.pop<DatosRepuesto>(context, (
      codigo: _codigo.text,
      nombre: _nombre.text,
      categoria: _categoria,
      precio: precio,
      existencias: int.tryParse(_existencias.text) ?? 0,
      stockMinimo: int.tryParse(_minimo.text) ?? 2,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.inicial != null;

    return AlertDialog(
      title: Text(editando ? 'Editar repuesto' : 'Nuevo repuesto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codigo,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código',
                hintText: 'REP-IP13-SCR',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: [
                for (final c in _categorias)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precio,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Precio (USD)'),
            ),
            const SizedBox(height: 12),
            if (!editando) ...[
              TextField(
                controller: _existencias,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Existencias iniciales',
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _minimo,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock mínimo'),
            ),
          ],
        ),
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
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}
