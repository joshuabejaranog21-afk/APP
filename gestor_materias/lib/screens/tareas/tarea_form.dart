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
  late String? _materiaId;
  late DateTime _fechaLimite;
  late EstadoTarea _estado;
  late PrioridadTarea _prioridad;
  late TipoActividad _tipo;

  @override
  void initState() {
    super.initState();
    final t = widget.tarea;
    _tituloCtrl = TextEditingController(text: t?.titulo ?? '');
    _descCtrl = TextEditingController(text: t?.descripcion ?? '');
    _materiaId = t?.materiaId ?? widget.materiaIdInicial;
    _fechaLimite = t?.fechaLimite ?? DateTime.now().add(const Duration(days: 1));
    _estado = t?.estado ?? EstadoTarea.pendiente;
    _prioridad = t?.prioridad ?? PrioridadTarea.media;
    _tipo = t?.tipo ?? TipoActividad.tarea;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isEditing = widget.tarea != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        actions: [
          TextButton(onPressed: _guardar, child: const Text('Guardar')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            // Descripción
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Materia
            DropdownButtonFormField<String>(
              value: _materiaId,
              decoration: const InputDecoration(
                labelText: 'Materia *',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              items: provider.materias
                  .map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.nombre,
                          overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _materiaId = v),
              validator: (v) => v == null ? 'Selecciona una materia' : null,
            ),
            const SizedBox(height: 12),

            // Tipo
            DropdownButtonFormField<TipoActividad>(
              value: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: TipoActividad.values
                  .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text('${t.emoji}  ${t.label}')))
                  .toList(),
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 12),

            // Prioridad
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prioridad',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6))),
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
                  onSelectionChanged: (s) =>
                      setState(() => _prioridad = s.first),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fecha límite
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
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3))),
            ),
            const SizedBox(height: 12),

            // Estado (solo al editar)
            if (isEditing) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6))),
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
                    onSelectionChanged: (s) =>
                        setState(() => _estado = s.first),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
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
    );
    if (widget.tarea == null) {
      provider.agregarTarea(t);
    } else {
      provider.editarTarea(t);
    }
    Navigator.pop(context);
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
