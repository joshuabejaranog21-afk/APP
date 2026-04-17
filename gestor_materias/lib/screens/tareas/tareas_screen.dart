import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/tarea.dart';
import '../../models/materia.dart';
import 'tarea_form.dart';

enum _OrdenTareas { fecha, prioridad, tipo }

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});
  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String? _filterMateriaId;
  TipoActividad? _filterTipo;
  PrioridadTarea? _filterPrioridad;
  _OrdenTareas _orden = _OrdenTareas.fecha;

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
    final theme = Theme.of(context);
    final hasFilters =
        _filterMateriaId != null || _filterTipo != null || _filterPrioridad != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort,
                color: _orden != _OrdenTareas.fecha
                    ? theme.colorScheme.primary
                    : null),
            tooltip: 'Ordenar',
            onPressed: () => _mostrarOrden(context),
          ),
          IconButton(
            icon: Icon(Icons.filter_list,
                color: hasFilters ? theme.colorScheme.primary : null),
            tooltip: 'Filtros',
            onPressed: () => _mostrarFiltros(context, provider),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            _buildTab('Pendientes',
                provider.tareas.where((t) => t.estado == EstadoTarea.pendiente).length),
            _buildTab('En progreso',
                provider.tareas.where((t) => t.estado == EstadoTarea.enProgreso).length),
            _buildTab('Entregadas',
                provider.tareas.where((t) => t.estado == EstadoTarea.entregada).length),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: Column(
        children: [
          // ── Active filter chips ────────────────────────────
          if (hasFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Wrap(
                spacing: 6,
                children: [
                  if (_filterMateriaId != null)
                    Builder(builder: (ctx) {
                      final m = provider.materias.firstWhere(
                        (m) => m.id == _filterMateriaId,
                        orElse: () => Materia(
                            id: '', nombre: '?', colorValue: 0xFF9E9E9E),
                      );
                      return Chip(
                        avatar: Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: Color(m.colorValue),
                                shape: BoxShape.circle)),
                        label: Text(m.nombre,
                            style: const TextStyle(fontSize: 11)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () =>
                            setState(() => _filterMateriaId = null),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                  if (_filterTipo != null)
                    Chip(
                      label: Text(
                          '${_filterTipo!.emoji} ${_filterTipo!.label}',
                          style: const TextStyle(fontSize: 11)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _filterTipo = null),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (_filterPrioridad != null)
                    Chip(
                      label: Text(
                          _filterPrioridad == PrioridadTarea.alta
                              ? '🔴 Alta'
                              : _filterPrioridad == PrioridadTarea.media
                                  ? '🟡 Media'
                                  : '🟢 Baja',
                          style: const TextStyle(fontSize: 11)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _filterPrioridad = null),
                      visualDensity: VisualDensity.compact,
                    ),
                  TextButton(
                    onPressed: () => setState(() {
                      _filterMateriaId = null;
                      _filterTipo = null;
                      _filterPrioridad = null;
                    }),
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4)),
                    child: const Text('Limpiar todo',
                        style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),

          // ── Tabs ───────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _TareasList(
                    estado: EstadoTarea.pendiente,
                    filterMateriaId: _filterMateriaId,
                    filterTipo: _filterTipo,
                    filterPrioridad: _filterPrioridad,
                    orden: _orden,
                    onEdit: (t) => _abrirForm(context, t)),
                _TareasList(
                    estado: EstadoTarea.enProgreso,
                    filterMateriaId: _filterMateriaId,
                    filterTipo: _filterTipo,
                    filterPrioridad: _filterPrioridad,
                    orden: _orden,
                    onEdit: (t) => _abrirForm(context, t)),
                _TareasList(
                    estado: EstadoTarea.entregada,
                    filterMateriaId: _filterMateriaId,
                    filterTipo: _filterTipo,
                    filterPrioridad: _filterPrioridad,
                    orden: _orden,
                    onEdit: (t) => _abrirForm(context, t)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Tab _buildTab(String label, int count) => Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ],
        ),
      );

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

  void _mostrarOrden(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ordenar por',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._OrdenTareas.values.map((o) {
              final label = o == _OrdenTareas.fecha
                  ? 'Fecha límite'
                  : o == _OrdenTareas.prioridad
                      ? 'Prioridad'
                      : 'Tipo';
              final icon = o == _OrdenTareas.fecha
                  ? Icons.calendar_today
                  : o == _OrdenTareas.prioridad
                      ? Icons.flag
                      : Icons.category;
              return ListTile(
                leading: Icon(icon),
                title: Text(label),
                trailing: _orden == o
                    ? Icon(Icons.check,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  setState(() => _orden = o);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _mostrarFiltros(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, sc) => Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: sc,
              children: [
                Text('Filtros',
                    style: Theme.of(ctx2)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),

                // Materia filter
                Text('Materia',
                    style: Theme.of(ctx2).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(ctx2).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _filterMateriaId == null,
                      onSelected: (_) {
                        setModalState(() {});
                        setState(() => _filterMateriaId = null);
                      },
                    ),
                    ...provider.materias.map((m) => FilterChip(
                          avatar: Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                  color: Color(m.colorValue),
                                  shape: BoxShape.circle)),
                          label: Text(m.nombre),
                          selected: _filterMateriaId == m.id,
                          onSelected: (_) {
                            setModalState(() {});
                            setState(() => _filterMateriaId =
                                _filterMateriaId == m.id ? null : m.id);
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 16),

                // Tipo filter
                Text('Tipo',
                    style: Theme.of(ctx2).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(ctx2).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: TipoActividad.values.map((t) => FilterChip(
                        label: Text('${t.emoji} ${t.label}'),
                        selected: _filterTipo == t,
                        onSelected: (_) {
                          setModalState(() {});
                          setState(() =>
                              _filterTipo = _filterTipo == t ? null : t);
                        },
                      )).toList(),
                ),
                const SizedBox(height: 16),

                // Prioridad filter
                Text('Prioridad',
                    style: Theme.of(ctx2).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(ctx2).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    FilterChip(
                      label: const Text('🔴 Alta'),
                      selected: _filterPrioridad == PrioridadTarea.alta,
                      onSelected: (_) {
                        setModalState(() {});
                        setState(() => _filterPrioridad =
                            _filterPrioridad == PrioridadTarea.alta
                                ? null
                                : PrioridadTarea.alta);
                      },
                    ),
                    FilterChip(
                      label: const Text('🟡 Media'),
                      selected: _filterPrioridad == PrioridadTarea.media,
                      onSelected: (_) {
                        setModalState(() {});
                        setState(() => _filterPrioridad =
                            _filterPrioridad == PrioridadTarea.media
                                ? null
                                : PrioridadTarea.media);
                      },
                    ),
                    FilterChip(
                      label: const Text('🟢 Baja'),
                      selected: _filterPrioridad == PrioridadTarea.baja,
                      onSelected: (_) {
                        setModalState(() {});
                        setState(() => _filterPrioridad =
                            _filterPrioridad == PrioridadTarea.baja
                                ? null
                                : PrioridadTarea.baja);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx2),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TareasList extends StatelessWidget {
  final EstadoTarea estado;
  final String? filterMateriaId;
  final TipoActividad? filterTipo;
  final PrioridadTarea? filterPrioridad;
  final _OrdenTareas orden;
  final void Function(Tarea) onEdit;

  const _TareasList({
    required this.estado,
    required this.filterMateriaId,
    required this.filterTipo,
    required this.filterPrioridad,
    required this.orden,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    var tareas = provider.tareas.where((t) => t.estado == estado).toList();

    if (filterMateriaId != null) {
      tareas = tareas.where((t) => t.materiaId == filterMateriaId).toList();
    }
    if (filterTipo != null) {
      tareas = tareas.where((t) => t.tipo == filterTipo).toList();
    }
    if (filterPrioridad != null) {
      tareas = tareas.where((t) => t.prioridad == filterPrioridad).toList();
    }

    switch (orden) {
      case _OrdenTareas.fecha:
        tareas.sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));
      case _OrdenTareas.prioridad:
        tareas.sort((a, b) => b.prioridad.index.compareTo(a.prioridad.index));
      case _OrdenTareas.tipo:
        tareas.sort((a, b) => a.tipo.index.compareTo(b.tipo.index));
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
                      width: 10, height: 10,
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
                          fontSize: 11, color: color.withValues(alpha: 0.7))),
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
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _compartir(provider),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Compartir',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              final next = tarea.estado == EstadoTarea.pendiente
                  ? EstadoTarea.enProgreso
                  : EstadoTarea.entregada;
              provider.cambiarEstadoTarea(tarea.id, next);
            },
            backgroundColor: tarea.estado == EstadoTarea.pendiente
                ? Colors.blue
                : Colors.green,
            foregroundColor: Colors.white,
            icon: tarea.estado == EstadoTarea.pendiente
                ? Icons.timelapse
                : Icons.check_circle,
            label: tarea.estado == EstadoTarea.pendiente
                ? 'Iniciar'
                : 'Completar',
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: const Color(0xFF5C6BC0),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
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
          onTap: () => _mostrarDetalle(context, provider),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                              if (tarea.esRecurrente) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.repeat,
                                    size: 12, color: Colors.grey),
                              ],
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
                    _FechaBadge(tarea: tarea),
                  ],
                ),
                // Subtask progress bar
                if (tarea.subtareas.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: tarea.progresoSubtareas,
                            minHeight: 4,
                            backgroundColor:
                                color.withValues(alpha: 0.15),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${tarea.subtareasCompletadasCount}/${tarea.subtareas.length}',
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
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

  void _mostrarDetalle(BuildContext context, AppProvider provider) {
    if (tarea.subtareas.isEmpty) {
      onEdit();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _SubtareasSheet(tarea: tarea, color: color),
    );
  }

  void _compartir(AppProvider provider) {
    final materia = provider.materiaById(tarea.materiaId);
    final fecha = DateFormat("d 'de' MMMM 'de' yyyy", 'es_ES').format(tarea.fechaLimite);
    final prioridad = tarea.prioridad == PrioridadTarea.alta
        ? '🔴 Alta'
        : tarea.prioridad == PrioridadTarea.media
            ? '🟡 Media'
            : '🟢 Baja';
    final estado = tarea.estado == EstadoTarea.entregada
        ? '✅ Entregada'
        : tarea.estado == EstadoTarea.enProgreso
            ? '🔄 En progreso'
            : '⏳ Pendiente';

    String texto = '''
${tarea.tipo.emoji} *${tarea.titulo}*

📖 Materia: ${materia?.nombre ?? 'Sin materia'}
📅 Fecha límite: $fecha
🚦 Prioridad: $prioridad
📌 Estado: $estado${tarea.descripcion.isNotEmpty ? '\n\n📝 ${tarea.descripcion}' : ''}''';

    if (tarea.subtareas.isNotEmpty) {
      texto += '\n\n📋 Subtareas:';
      for (final s in tarea.subtareas) {
        texto += '\n${s.completada ? '✅' : '⬜'} ${s.titulo}';
      }
    }
    texto += '\n\n_Compartido desde Gestor de Tareas_ 🎓';
    Share.share(texto, subject: tarea.titulo);
  }
}

class _SubtareasSheet extends StatefulWidget {
  final Tarea tarea;
  final Color color;
  const _SubtareasSheet({required this.tarea, required this.color});

  @override
  State<_SubtareasSheet> createState() => _SubtareasSheetState();
}

class _SubtareasSheetState extends State<_SubtareasSheet> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.tarea.titulo,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: widget.tarea.progresoSubtareas,
            backgroundColor: widget.color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
              '${widget.tarea.subtareasCompletadasCount} de ${widget.tarea.subtareas.length} subtareas completadas',
              style: TextStyle(
                  fontSize: 12,
                  color: widget.color,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...widget.tarea.subtareas.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return CheckboxListTile(
              value: s.completada,
              activeColor: widget.color,
              onChanged: (v) {
                provider.actualizarSubtarea(widget.tarea.id, i, v!);
                setState(() {});
              },
              title: Text(
                s.titulo,
                style: TextStyle(
                  decoration:
                      s.completada ? TextDecoration.lineThrough : null,
                  color: s.completada
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : null,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
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
            width: 6, height: 6,
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
