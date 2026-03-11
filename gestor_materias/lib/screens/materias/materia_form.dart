import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/materia.dart';
import '../../theme/app_theme.dart';

class MateriaForm extends StatefulWidget {
  final Materia? materia;
  const MateriaForm({super.key, this.materia});

  @override
  State<MateriaForm> createState() => _MateriaFormState();
}

class _MateriaFormState extends State<MateriaForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _profesorCtrl;
  late TextEditingController _aulaCtrl;
  late TextEditingController _notaObjetivoCtrl;
  late int _colorValue;
  late String _icono;
  late List<HorarioClase> _horarios;

  final List<Map<String, dynamic>> _iconos = [
    {'key': 'book', 'icon': Icons.menu_book, 'label': 'Libro'},
    {'key': 'science', 'icon': Icons.science, 'label': 'Ciencia'},
    {'key': 'calculate', 'icon': Icons.calculate, 'label': 'Matemáticas'},
    {'key': 'code', 'icon': Icons.code, 'label': 'Código'},
    {'key': 'history', 'icon': Icons.history_edu, 'label': 'Historia'},
    {'key': 'art', 'icon': Icons.palette, 'label': 'Arte'},
    {'key': 'language', 'icon': Icons.language, 'label': 'Idioma'},
    {'key': 'sports', 'icon': Icons.sports, 'label': 'Deportes'},
    {'key': 'music', 'icon': Icons.music_note, 'label': 'Música'},
    {'key': 'psychology', 'icon': Icons.psychology, 'label': 'Psicología'},
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.materia;
    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    _profesorCtrl = TextEditingController(text: m?.profesor ?? '');
    _aulaCtrl = TextEditingController(text: m?.aula ?? '');
    _notaObjetivoCtrl =
        TextEditingController(text: m?.notaObjetivo?.toString() ?? '');
    _colorValue = m?.colorValue ?? AppTheme.materiaColors[0].toARGB32();
    _icono = m?.icono ?? 'book';
    _horarios = m?.horarios.map((h) => HorarioClase(
          diaSemana: h.diaSemana,
          horaInicio: h.horaInicio,
          horaFin: h.horaFin,
        )).toList() ?? [];
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _profesorCtrl.dispose();
    _aulaCtrl.dispose();
    _notaObjetivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.materia != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Materia' : 'Nueva Materia'),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview color
            _Preview(
                colorValue: _colorValue,
                icono: _icono,
                nombre: _nombreCtrl.text),
            const SizedBox(height: 20),

            // Nombre
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la materia *',
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),

            // Profesor
            TextFormField(
              controller: _profesorCtrl,
              decoration: const InputDecoration(
                labelText: 'Profesor',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),

            // Aula
            TextFormField(
              controller: _aulaCtrl,
              decoration: const InputDecoration(
                labelText: 'Aula / Salón',
                prefixIcon: Icon(Icons.room_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Nota objetivo
            TextFormField(
              controller: _notaObjetivoCtrl,
              decoration: const InputDecoration(
                labelText: 'Nota objetivo (ej. 8.0)',
                prefixIcon: Icon(Icons.star_outline),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            // Color
            Text('Color',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppTheme.materiaColors.map((c) {
                final selected = c.toARGB32() == _colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = c.toARGB32()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3)
                          : null,
                      boxShadow: selected
                          ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Icono
            Text('Ícono',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _iconos.map((item) {
                final selected = item['key'] == _icono;
                final color = Color(_colorValue);
                return GestureDetector(
                  onTap: () => setState(() => _icono = item['key']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.2)
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(color: color, width: 2)
                          : null,
                    ),
                    child: Tooltip(
                      message: item['label'],
                      child: Icon(item['icon'] as IconData,
                          color: selected ? color : null, size: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Horarios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Horario de clases',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                TextButton.icon(
                  onPressed: _agregarHorario,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (_horarios.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Sin horarios definidos',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                        fontSize: 13)),
              ),
            ..._horarios.asMap().entries.map((entry) {
              final i = entry.key;
              final h = entry.value;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(
                      '${h.diaLabel}  ${h.horaInicio} - ${h.horaFin}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () =>
                        setState(() => _horarios.removeAt(i)),
                  ),
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _agregarHorario() async {
    int dia = 1;
    TimeOfDay inicio = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay fin = const TimeOfDay(hour: 9, minute: 30);
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Agregar horario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: dia,
                decoration: const InputDecoration(labelText: 'Día'),
                items: List.generate(
                    7,
                    (i) => DropdownMenuItem(
                        value: i + 1, child: Text(dias[i]))),
                onChanged: (v) => setS(() => dia = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text(inicio.format(ctx)),
                      onPressed: () async {
                        final t = await showTimePicker(
                            context: ctx, initialTime: inicio);
                        if (t != null) setS(() => inicio = t);
                      },
                    ),
                  ),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('-')),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text(fin.format(ctx)),
                      onPressed: () async {
                        final t = await showTimePicker(
                            context: ctx, initialTime: fin);
                        if (t != null) setS(() => fin = t);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                setState(() {
                  _horarios.add(HorarioClase(
                    diaSemana: dia,
                    horaInicio:
                        '${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')}',
                    horaFin:
                        '${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}',
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final m = Materia(
      id: widget.materia?.id ?? provider.generarMateriaId(),
      nombre: _nombreCtrl.text.trim(),
      profesor: _profesorCtrl.text.trim(),
      aula: _aulaCtrl.text.trim(),
      colorValue: _colorValue,
      icono: _icono,
      horarios: _horarios,
      notaObjetivo: double.tryParse(_notaObjetivoCtrl.text),
    );
    if (widget.materia == null) {
      provider.agregarMateria(m);
    } else {
      provider.editarMateria(m);
    }
    Navigator.pop(context);
  }
}

class _Preview extends StatelessWidget {
  final int colorValue;
  final String icono;
  final String nombre;
  const _Preview(
      {required this.colorValue, required this.icono, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    final IconData icon = {
          'book': Icons.menu_book,
          'science': Icons.science,
          'calculate': Icons.calculate,
          'code': Icons.code,
          'history': Icons.history_edu,
          'art': Icons.palette,
          'language': Icons.language,
          'sports': Icons.sports,
          'music': Icons.music_note,
          'psychology': Icons.psychology,
        }[icono] ??
        Icons.menu_book;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              nombre.isEmpty ? 'Nombre de la materia' : nombre,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
