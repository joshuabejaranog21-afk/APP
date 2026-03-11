import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/tarea.dart';
import '../../models/materia.dart';
import 'tarea_form.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});
  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String? _filterMateriaId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'En progreso'),
            Tab(text: 'Entregadas'),
          ],
        ),
        actions: [
          PopupMenuButton<String?>(
            icon: Icon(
              Icons.filter_list,
              color: _filterMateriaId != null
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: 'Filtrar por materia',
            initialValue: _filterMateriaId,
            onSelected: (v) => setState(() => _filterMateriaId = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Todas las materias')),
              ...provider.materias.map((m) => PopupMenuItem(
                    value: m.id,
                    child: Row(children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: Color(m.colorValue),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(m.nombre),
                    ]),
                  )),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TareasList(
              estado: EstadoTarea.pendiente,
              filterMateriaId: _filterMateriaId,
              onEdit: (t) => _abrirForm(context, t)),
          _TareasList(
              estado: EstadoTarea.enProgreso,
              filterMateriaId: _filterMateriaId,
              onEdit: (t) => _abrirForm(context, t)),
          _TareasList(
              estado: EstadoTarea.entregada,
              filterMateriaId: _filterMateriaId,
              onEdit: (t) => _abrirForm(context, t)),
        ],
      ),
    );
  }

  void _abrirForm(BuildContext context, Tarea? tarea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => TareaForm(tarea: tarea),
    );
  }
}

class _TareasList extends StatelessWidget {
  final EstadoTarea estado;
  final String? filterMateriaId;
  final void Function(Tarea) onEdit;

  const _TareasList({
    required this.estado,
    required this.filterMateriaId,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    var tareas = provider.tareas
        .where((t) => t.estado == estado)
        .toList()
      ..sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));

    if (filterMateriaId != null) {
      tareas = tareas.where((t) => t.materiaId == filterMateriaId).toList();
    }

    if (tareas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              estado == EstadoTarea.entregada
                  ? 'Sin tareas entregadas'
                  : estado == EstadoTarea.enProgreso
                      ? 'Nada en progreso'
                      : '¡Sin pendientes!',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4)),
            ),
          ],
        ),
      );
    }

    // Group by materia
    final grupos = <String, List<Tarea>>{};
    for (final t in tareas) {
      grupos.putIfAbsent(t.materiaId, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: grupos.entries.map((entry) {
        final materia = provider.materias.firstWhere(
          (m) => m.id == entry.key,
          orElse: () =>
              Materia(id: '', nombre: 'Sin materia', colorValue: 0xFF9E9E9E),
        );
        final color = Color(materia.colorValue);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(materia.nombre,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: color)),
                  const SizedBox(width: 6),
                  Text('(${entry.value.length})',
                      style: TextStyle(
                          fontSize: 11,
                          color: color.withValues(alpha: 0.7))),
                ],
              ),
            ),
            ...entry.value.map((t) => _TareaCard(
                tarea: t, color: color, onEdit: () => onEdit(t))),
            const SizedBox(height: 4),
          ],
        );
      }).toList(),
    );
  }
}

class _TareaCard extends StatelessWidget {
  final Tarea tarea;
  final Color color;
  final VoidCallback onEdit;

  const _TareaCard(
      {required this.tarea, required this.color, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => provider.eliminarTarea(tarea.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12)),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _ciclarEstado(provider),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Estado icon
                GestureDetector(
                  onTap: () => _ciclarEstado(provider),
                  child: Icon(
                    tarea.estado == EstadoTarea.entregada
                        ? Icons.check_circle
                        : tarea.estado == EstadoTarea.enProgreso
                            ? Icons.timelapse
                            : Icons.radio_button_unchecked,
                    color: tarea.estado == EstadoTarea.entregada
                        ? Colors.green
                        : tarea.estado == EstadoTarea.enProgreso
                            ? Colors.blue
                            : color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarea.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: tarea.estado == EstadoTarea.entregada
                              ? TextDecoration.lineThrough
                              : null,
                          color: tarea.estado == EstadoTarea.entregada
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${tarea.tipo.emoji} ${tarea.tipo.label}',
                              style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 8),
                          _PrioridadDot(prioridad: tarea.prioridad),
                        ],
                      ),
                      if (tarea.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tarea.descripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5)),
                        ),
                      ],
                    ],
                  ),
                ),
                // Fecha
                _FechaBadge(tarea: tarea),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _ciclarEstado(AppProvider provider) {
    final next = tarea.estado == EstadoTarea.pendiente
        ? EstadoTarea.enProgreso
        : tarea.estado == EstadoTarea.enProgreso
            ? EstadoTarea.entregada
            : EstadoTarea.pendiente;
    provider.cambiarEstadoTarea(tarea.id, next);
  }
}

class _PrioridadDot extends StatelessWidget {
  final PrioridadTarea prioridad;
  const _PrioridadDot({required this.prioridad});

  @override
  Widget build(BuildContext context) {
    final color = prioridad == PrioridadTarea.alta
        ? Colors.red
        : prioridad == PrioridadTarea.media
            ? Colors.orange
            : Colors.green;
    final label = prioridad == PrioridadTarea.alta
        ? 'Alta'
        : prioridad == PrioridadTarea.media
            ? 'Media'
            : 'Baja';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FechaBadge extends StatelessWidget {
  final Tarea tarea;
  const _FechaBadge({required this.tarea});

  @override
  Widget build(BuildContext context) {
    if (tarea.estado == EstadoTarea.entregada) {
      return const Icon(Icons.done_all, color: Colors.green, size: 18);
    }

    final dias = tarea.diasRestantes;
    final vencida = tarea.estaVencida;
    final color = vencida
        ? Colors.red
        : dias == 0
            ? Colors.orange
            : dias <= 3
                ? Colors.amber
                : Colors.grey;

    final texto = vencida
        ? '${dias.abs()}d atrás'
        : dias == 0
            ? 'Hoy'
            : dias == 1
                ? 'Mañana'
                : '${dias}d';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
