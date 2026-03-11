import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/app_provider.dart';
import '../../models/tarea.dart';
import '../tareas/tarea_form.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final tareasDelDia = _selectedDay == null
        ? <Tarea>[]
        : provider.tareas.where((t) {
            final fl = t.fechaLimite;
            final sd = _selectedDay!;
            return fl.year == sd.year &&
                fl.month == sd.month &&
                fl.day == sd.day;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 380,
            child: TableCalendar<Tarea>(
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _format,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            }),
            onFormatChanged: (f) => setState(() => _format = f),
            onPageChanged: (f) => _focusedDay = f,
            eventLoader: (day) => provider.tareas
                .where((t) =>
                    t.fechaLimite.year == day.year &&
                    t.fechaLimite.month == day.month &&
                    t.fechaLimite.day == day.day)
                .toList(),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonShowsNext: false,
              titleCentered: true,
            ),
          ),
          ),
          const Divider(height: 1),
          Expanded(
            child: tareasDelDia.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available_outlined,
                            size: 48,
                            color: colorScheme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 8),
                        Text(
                          _selectedDay != null
                              ? 'Sin tareas este día'
                              : 'Selecciona un día',
                          style: TextStyle(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tareasDelDia.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 6),
                    itemBuilder: (ctx, i) {
                      final t = tareasDelDia[i];
                      final materia = provider.materiaById(t.materiaId);
                      final color = materia != null
                          ? Color(materia.colorValue)
                          : Colors.grey;
                      return _EventoItem(
                          tarea: t,
                          color: color,
                          materiaNombre: materia?.nombre ?? '',
                          provider: provider);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => const TareaForm(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EventoItem extends StatelessWidget {
  final Tarea tarea;
  final Color color;
  final String materiaNombre;
  final AppProvider provider;

  const _EventoItem({
    required this.tarea,
    required this.color,
    required this.materiaNombre,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(tarea.tipo.emoji, style: const TextStyle(fontSize: 18)),
        ),
        title: Text(tarea.titulo,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: tarea.estado == EstadoTarea.entregada
                    ? TextDecoration.lineThrough
                    : null)),
        subtitle: Text(materiaNombre,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500)),
        trailing: GestureDetector(
          onTap: () {
            final next = tarea.estado == EstadoTarea.pendiente
                ? EstadoTarea.enProgreso
                : tarea.estado == EstadoTarea.enProgreso
                    ? EstadoTarea.entregada
                    : EstadoTarea.pendiente;
            provider.cambiarEstadoTarea(tarea.id, next);
          },
          child: Icon(
            tarea.estado == EstadoTarea.entregada
                ? Icons.check_circle
                : tarea.estado == EstadoTarea.enProgreso
                    ? Icons.timelapse
                    : Icons.radio_button_unchecked,
            color: tarea.estado == EstadoTarea.entregada
                ? Colors.green
                : color,
          ),
        ),
      ),
    );
  }
}
