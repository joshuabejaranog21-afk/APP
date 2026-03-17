import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/grupo.dart';

class GrupoForm extends StatefulWidget {
  final Grupo? grupo;
  const GrupoForm({super.key, this.grupo});

  @override
  State<GrupoForm> createState() => _GrupoFormState();
}

class _GrupoFormState extends State<GrupoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombre;
  late TextEditingController _descripcion;
  late int _colorValue;

  static const _colores = [
    0xFF6C63FF, 0xFF4CAF50, 0xFFFF9800, 0xFFF44336,
    0xFF2196F3, 0xFF9C27B0, 0xFF00BCD4, 0xFFFF5722,
  ];

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.grupo?.nombre ?? '');
    _descripcion = TextEditingController(text: widget.grupo?.descripcion ?? '');
    _colorValue = widget.grupo?.colorValue ?? _colores[0];
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.grupo != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar grupo' : 'Nuevo grupo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo',
                hintText: 'Ej. 6°A, Ingeniería 2024...',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcion,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej. Turno matutino, semestre 3...',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Text('Color del grupo', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colores.map((c) {
                final seleccionado = _colorValue == c;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: seleccionado
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3)
                          : null,
                      boxShadow: seleccionado
                          ? [BoxShadow(color: Color(c).withValues(alpha: 0.5), blurRadius: 8)]
                          : null,
                    ),
                    child: seleccionado
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save_outlined),
              label: Text(esEdicion ? 'Guardar cambios' : 'Crear grupo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    if (widget.grupo == null) {
      await provider.agregarGrupo(Grupo(
        id: provider.generarGrupoId(),
        nombre: _nombre.text.trim(),
        colorValue: _colorValue,
        descripcion: _descripcion.text.trim(),
      ));
    } else {
      await provider.editarGrupo(Grupo(
        id: widget.grupo!.id,
        nombre: _nombre.text.trim(),
        colorValue: _colorValue,
        descripcion: _descripcion.text.trim(),
      ));
    }
    if (mounted) Navigator.pop(context);
  }
}
