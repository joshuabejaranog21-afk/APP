import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/tarea.dart';

class TareaForm extends StatefulWidget {
  final Tarea? tarea;
  final String? materiaIdInicial;
  const TareaForm({super.key, this.tarea, this.materiaIdInicial});

  @override
  State<TareaForm> createState() => _TareaFormState();
}

class _TareaFormState extends State<TareaForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _subtareaCtrl;
  late String? _materiaId;
  late DateTime _fechaLimite;
  late EstadoTarea _estado;
  late PrioridadTarea _prioridad;
  late TipoActividad _tipo;
  late bool _esRecurrente;
  late List<SubtareaItem> _subtareas;

  @override
  void initState() {
    super.initState();
    final t = widget.tarea;
    _tituloCtrl = TextEditingController(text: t?.titulo ?? '');
    _descCtrl = TextEditingController(text: t?.descripcion ?? '');
    _subtareaCtrl = TextEditingController();
    _materiaId = t?.materiaId ?? widget.materiaIdInicial;
    _fechaLimite = t?.fechaLimite ?? DateTime.now().add(const Duration(days: 1));
    _estado = t?.estado ?? EstadoTarea.pendiente;
    _prioridad = t?.prioridad ?? PrioridadTarea.media;
    _tipo = t?.tipo ?? TipoActividad.tarea;
    _esRecurrente = t?.esRecurrente ?? false;
    _subtareas = t?.subtareas.map((s) => SubtareaItem(titulo: s.titulo, completada: s.completada)).toList() ?? [];
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _subtareaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isEditing = widget.tarea != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        actions: [
          FilledButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Título ──────────────────────────────────────
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            // ── Descripción ──────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // ── Materia ──────────────────────────────────────
            DropdownButtonFormField<String>(
              value: _materiaId,
              decoration: const InputDecoration(
                labelText: 'Materia *',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              items: provider.materias
                  .map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Row(children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: Color(m.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(m.nombre, overflow: TextOverflow.ellipsis),
                      ])))
                  .toList(),
              onChanged: (v) => setState(() => _materiaId = v),
              validator: (v) => v == null ? 'Selecciona una materia' : null,
            ),
            const SizedBox(height: 12),

            // ── Tipo ─────────────────────────────────────────
            DropdownButtonFormField<TipoActividad>(
              value: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: TipoActividad.values
                  .map((t) => DropdownMenuItem(
                      value: t, child: Text('${t.emoji}  ${t.label}')))
                  .toList(),
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 16),

            // ── Prioridad ────────────────────────────────────
            _SectionLabel('Prioridad'),
            const SizedBox(height: 6),
            SegmentedButton<PrioridadTarea>(
              segments: const [
                ButtonSegment(
                    value: PrioridadTarea.baja,
                    label: Text('Baja'),
                    icon: Icon(Icons.arrow_downward, size: 14)),
                ButtonSegment(
                    value: PrioridadTarea.media,
                    label: Text('Media'),
                    icon: Icon(Icons.remove, size: 14)),
                ButtonSegment(
                    value: PrioridadTarea.alta,
                    label: Text('Alta'),
                    icon: Icon(Icons.arrow_upward, size: 14)),
              ],
              selected: {_prioridad},
              onSelectionChanged: (s) => setState(() => _prioridad = s.first),
            ),
            const SizedBox(height: 16),

            // ── Fecha límite ─────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Fecha límite'),
              subtitle: Text(_formatFechaLarga(_fechaLimite),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: _seleccionarFecha,
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3))),
            ),
            const SizedBox(height: 16),

            // ── Estado (solo edición) ────────────────────────
            if (isEditing) ...[
              _SectionLabel('Estado'),
              const SizedBox(height: 6),
              SegmentedButton<EstadoTarea>(
                segments: const [
                  ButtonSegment(
                      value: EstadoTarea.pendiente,
                      label: Text('Pendiente'),
                      icon: Icon(Icons.radio_button_unchecked, size: 14)),
                  ButtonSegment(
                      value: EstadoTarea.enProgreso,
                      label: Text('En progreso'),
                      icon: Icon(Icons.timelapse, size: 14)),
                  ButtonSegment(
                      value: EstadoTarea.entregada,
                      label: Text('Entregada'),
                      icon: Icon(Icons.check_circle, size: 14)),
                ],
                selected: {_estado},
                onSelectionChanged: (s) => setState(() => _estado = s.first),
              ),
              const SizedBox(height: 16),
            ],

            // ── Repetir semanalmente ─────────────────────────
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: _esRecurrente,
                onChanged: (v) => setState(() => _esRecurrente = v),
                title: const Text('Repetir semanalmente',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    'Al completar, se crea automáticamente para la próxima semana'),
                secondary: Icon(Icons.repeat,
                    color: _esRecurrente
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 20),

            // ── Subtareas ────────────────────────────────────
            Row(
              children: [
                _SectionLabel('Subtareas'),
                const SizedBox(width: 8),
                if (_subtareas.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_subtareas.where((s) => s.completada).length}/${_subtareas.length}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Subtask list
            if (_subtareas.isNotEmpty) ...[
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subtareas.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _subtareas.removeAt(oldIndex);
                    _subtareas.insert(newIndex, item);
                  });
                },
                itemBuilder: (ctx, i) {
                  final s = _subtareas[i];
                  return ListTile(
                    key: ValueKey('sub_$i'),
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: s.completada,
                      onChanged: (v) => setState(() => s.completada = v!),
                    ),
                    title: Text(
                      s.titulo,
                      style: TextStyle(
                        decoration: s.completada ? TextDecoration.lineThrough : null,
                        color: s.completada
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                            : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, size: 18, color: Colors.grey),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.red),
                          onPressed: () => setState(() => _subtareas.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
            ],

            // Add subtask input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtareaCtrl,
                    decoration: InputDecoration(
                      hintText: 'Nueva subtarea...',
                      prefixIcon: const Icon(Icons.add_task, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _agregarSubtarea(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _agregarSubtarea,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _agregarSubtarea() {
    final texto = _subtareaCtrl.text.trim();
    if (texto.isEmpty) return;
    setState(() {
      _subtareas.add(SubtareaItem(titulo: texto));
      _subtareaCtrl.clear();
    });
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaLimite,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _fechaLimite = picked);
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_materiaId == null) return;
    final provider = context.read<AppProvider>();
    final t = Tarea(
      id: widget.tarea?.id ?? provider.generarTareaId(),
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      materiaId: _materiaId!,
      fechaLimite: _fechaLimite,
      estado: _estado,
      prioridad: _prioridad,
      tipo: _tipo,
      fechaCreacion: widget.tarea?.fechaCreacion,
      esRecurrente: _esRecurrente,
      subtareas: _subtareas,
      completadaEn: widget.tarea?.completadaEn,
    );
    if (widget.tarea == null) {
      provider.agregarTarea(t);
    } else {
      provider.editarTarea(t);
    }
    Navigator.pop(context);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600),
    );
  }
}

String _formatFechaLarga(DateTime d) {
  const dias = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  const meses = [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  return '${dias[d.weekday]}, ${d.day} de ${meses[d.month]} ${d.year}';
}
