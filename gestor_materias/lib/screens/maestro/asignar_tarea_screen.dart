import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/tarea.dart';

class AsignarTareaScreen extends StatefulWidget {
  const AsignarTareaScreen({super.key});

  @override
  State<AsignarTareaScreen> createState() => _AsignarTareaScreenState();
}

class _AsignarTareaScreenState extends State<AsignarTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  String? _materiaId;
  String? _grupoId;
  DateTime _fechaLimite = DateTime.now().add(const Duration(days: 7));
  PrioridadTarea _prioridad = PrioridadTarea.media;
  TipoActividad _tipo = TipoActividad.tarea;

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final materias = provider.materias;
    final grupos = provider.grupos;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Asignar tarea al grupo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Encabezado informativo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: theme.colorScheme.onPrimaryContainer, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La tarea aparecerá en la lista de tareas del alumno con la etiqueta "Del Maestro".',
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(
                labelText: 'Título de la tarea',
                prefixIcon: Icon(Icons.assignment_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa un título' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcion,
              decoration: const InputDecoration(
                labelText: 'Instrucciones (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _materiaId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Materia',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: materias
                  .map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(m.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                m.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _materiaId = v),
              validator: (v) => v == null ? 'Selecciona una materia' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _grupoId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Grupo (opcional)',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin grupo específico')),
                ...grupos.map((g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(g.nombre, overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: (v) => setState(() => _grupoId = v),
            ),
            const SizedBox(height: 16),
            // Fecha límite
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Fecha límite'),
              subtitle: Text(_formatFecha(_fechaLimite)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _seleccionarFecha,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TipoActividad>(
                    initialValue: _tipo,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                    ),
                    items: TipoActividad.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                '${t.emoji} ${t.label}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _tipo = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<PrioridadTarea>(
                    initialValue: _prioridad,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: PrioridadTarea.baja, child: Text('🟢 Baja')),
                      DropdownMenuItem(
                          value: PrioridadTarea.media,
                          child: Text('🟡 Media')),
                      DropdownMenuItem(
                          value: PrioridadTarea.alta, child: Text('🔴 Alta')),
                    ],
                    onChanged: (v) => setState(() => _prioridad = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Asignar tarea'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaLimite,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) setState(() => _fechaLimite = fecha);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    await provider.agregarTarea(Tarea(
      id: provider.generarTareaId(),
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      materiaId: _materiaId!,
      fechaLimite: _fechaLimite,
      prioridad: _prioridad,
      tipo: _tipo,
      asignadoPorMaestro: true,
      grupoId: _grupoId,
    ));
    if (mounted) Navigator.pop(context);
  }

  String _formatFecha(DateTime fecha) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
