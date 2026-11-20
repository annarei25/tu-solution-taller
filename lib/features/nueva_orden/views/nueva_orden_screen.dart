import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/avisos.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/tarjeta.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/database_providers.dart';

const _tipos = ['Smartphone', 'Tablet', 'Laptop'];

class NuevaOrdenScreen extends ConsumerStatefulWidget {
  const NuevaOrdenScreen({
    super.key,
    this.desdeEquipo,
    this.equipoExistente,
    this.clienteExistente,
  }) : assert(
         (equipoExistente == null) == (clienteExistente == null),
         'Proporciona el equipo y su cliente juntos.',
       ),
       assert(
         desdeEquipo == null ||
             (equipoExistente == null && clienteExistente == null),
         'Usa desdeEquipo o los parámetros separados, no ambos.',
       );

  final ({Equipo equipo, Cliente cliente})? desdeEquipo;
  final Equipo? equipoExistente;
  final Cliente? clienteExistente;

  @override
  ConsumerState<NuevaOrdenScreen> createState() => _NuevaOrdenScreenState();
}

class _NuevaOrdenScreenState extends ConsumerState<NuevaOrdenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cliente = TextEditingController();
  final _telefono = TextEditingController();
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _serie = TextEditingController();
  final _falla = TextEditingController();

  String _tipo = _tipos.first;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final equipo = widget.equipoExistente ?? widget.desdeEquipo?.equipo;
    final cliente = widget.clienteExistente ?? widget.desdeEquipo?.cliente;
    if (equipo == null || cliente == null) return;

    _cliente.text = cliente.nombre;
    _telefono.text = cliente.telefono;
    _marca.text = equipo.marca;
    _modelo.text = equipo.modelo;
    _serie.text = equipo.numeroSerie;
    _tipo = equipo.tipo;
  }

  @override
  void dispose() {
    _cliente.dispose();
    _telefono.dispose();
    _marca.dispose();
    _modelo.dispose();
    _serie.dispose();
    _falla.dispose();
    super.dispose();
  }

  String? _obligatorio(String? valor) {
    return (valor == null || valor.trim().isEmpty) ? 'Campo obligatorio' : null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final ok = await ejecutarAccion(context, () async {
      await ref
          .read(ordenRepositoryProvider)
          .recibirEquipo(
            clienteNombre: _cliente.text,
            telefono: _telefono.text,
            tipo: _tipo,
            marca: _marca.text,
            modelo: _modelo.text,
            numeroSerie: _serie.text,
            falla: _falla.text,
          );
    });

    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      mostrarAviso(context, 'Equipo recibido');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            titulo: 'Nueva orden',
            alRegresar: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Tarjeta(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const EncabezadoSeccion(
                          icono: Icons.person_outline,
                          titulo: 'Dueño del equipo',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cliente,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Nombre completo',
                          ),
                          validator: _obligatorio,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telefono,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Teléfono',
                          ),
                          validator: _obligatorio,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Tarjeta(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const EncabezadoSeccion(
                          icono: Icons.devices_outlined,
                          titulo: 'Equipo',
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _tipo,
                          decoration: const InputDecoration(),
                          items: [
                            for (final t in _tiposDisponibles)
                              DropdownMenuItem(value: t, child: Text(t)),
                          ],
                          onChanged: (v) => setState(() => _tipo = v!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _marca,
                          decoration: const InputDecoration(hintText: 'Marca'),
                          validator: _obligatorio,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _modelo,
                          decoration: const InputDecoration(hintText: 'Modelo'),
                          validator: _obligatorio,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _serie,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'Número de serie',
                          ),
                          validator: _obligatorio,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Si el número de serie ya existe, la orden se '
                          'asocia al equipo registrado.',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Tarjeta(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const EncabezadoSeccion(
                          icono: Icons.report_problem_outlined,
                          titulo: 'Falla reportada',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _falla,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText:
                                'Describe la falla que reporta el cliente',
                          ),
                          validator: _obligatorio,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Text('Recibir equipo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _tiposDisponibles =>
      _tipos.contains(_tipo) ? _tipos : [..._tipos, _tipo];
}
