import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/grupo.dart';

class AnuncioForm extends StatefulWidget {
  final Anuncio? anuncio;
  const AnuncioForm({super.key, this.anuncio});

  @override
  State<AnuncioForm> createState() => _AnuncioFormState();
}

class _AnuncioFormState extends State<AnuncioForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titulo;
  late TextEditingController _cuerpo;
  String? _grupoId;
  bool _fijado = false;

  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.anuncio?.titulo ?? '');
    _cuerpo = TextEditingController(text: widget.anuncio?.cuerpo ?? '');
    _grupoId = widget.anuncio?.grupoId;
    _fijado = widget.anuncio?.fijado ?? false;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _cuerpo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grupos = context.watch<AppProvider>().grupos;
    final esEdicion = widget.anuncio != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar anuncio' : 'Nuevo anuncio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej. Entrega de proyecto final',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa un título' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cuerpo,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                hintText: 'Escribe el mensaje para tus alumnos...',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Escribe el contenido' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _grupoId,
              decoration: const InputDecoration(
                labelText: 'Dirigido a',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Todos los grupos')),
                ...grupos.map((g) => DropdownMenuItem(
                      value: g.id,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                Color(g.colorValue).withValues(alpha: 0.2),
                            radius: 10,
                            child: Text(
                              g.nombre[0].toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10, color: Color(g.colorValue)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(g.nombre),
                        ],
                      ),
                    )),
              ],
              onChanged: (v) => setState(() => _grupoId = v),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _fijado,
              onChanged: (v) => setState(() => _fijado = v),
              title: const Text('Fijar anuncio'),
              subtitle: const Text('Aparece siempre al inicio del tablón'),
              secondary: const Icon(Icons.push_pin_outlined),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.campaign_outlined),
              label: Text(esEdicion ? 'Guardar cambios' : 'Publicar anuncio'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final anuncio = Anuncio(
      id: widget.anuncio?.id ?? provider.generarAnuncioId(),
      titulo: _titulo.text.trim(),
      cuerpo: _cuerpo.text.trim(),
      grupoId: _grupoId,
      fecha: widget.anuncio?.fecha ?? DateTime.now(),
      fijado: _fijado,
    );
    if (widget.anuncio == null) {
      await provider.agregarAnuncio(anuncio);
    } else {
      await provider.editarAnuncio(anuncio);
    }
    if (mounted) Navigator.pop(context);
  }
}
