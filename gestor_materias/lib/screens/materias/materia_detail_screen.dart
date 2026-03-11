import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../providers/app_provider.dart';
import '../../models/materia.dart';
import '../../models/tarea.dart';
import '../../models/nota.dart';
import '../tareas/tarea_form.dart';
import 'materia_form.dart';

class MateriaDetailScreen extends StatefulWidget {
  final Materia materia;
  const MateriaDetailScreen({super.key, required this.materia});

  @override
  State<MateriaDetailScreen> createState() => _MateriaDetailScreenState();
}

class _MateriaDetailScreenState extends State<MateriaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

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
    // Refresh materia data from provider in case it was edited
    final materia = provider.materias.firstWhere(
      (m) => m.id == widget.materia.id,
      orElse: () => widget.materia,
    );
    final color = Color(materia.colorValue);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context2, innerBoxScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (_) => MateriaForm(materia: materia),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
              title: Text(materia.nombre,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
                  child: Row(
                    children: [
                      if (materia.profesor.isNotEmpty)
                        _InfoChip(Icons.person, materia.profesor),
                      if (materia.aula.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _InfoChip(Icons.location_on, materia.aula),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Tareas'),
                Tab(text: 'Calificaciones'),
                Tab(text: 'Notas'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _TareasTab(materia: materia),
            _CalificacionesTab(materia: materia),
            _NotasTab(materia: materia),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () => _fabAction(context, materia),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _fabAction(BuildContext context, Materia materia) {
    switch (_tabs.index) {
      case 0:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => TareaForm(materiaIdInicial: materia.id),
        );
        break;
      case 1:
        _mostrarFormCalificacion(context, materia);
        break;
      case 2:
        _mostrarFormNota(context, materia);
        break;
    }
  }

  void _mostrarFormCalificacion(BuildContext context, Materia materia) {
    final nombreCtrl = TextEditingController();
    final notaCtrl = TextEditingController();
    final maxCtrl = TextEditingController(text: '10');
    final porcCtrl = TextEditingController();
    final provider = context.read<AppProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nueva calificación',
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre (ej: Parcial 1)')),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: notaCtrl, decoration: const InputDecoration(labelText: 'Nota obtenida'), keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: maxCtrl, decoration: const InputDecoration(labelText: 'Nota máxima'), keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: porcCtrl, decoration: const InputDecoration(labelText: 'Porcentaje %'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (nombreCtrl.text.isEmpty || notaCtrl.text.isEmpty || porcCtrl.text.isEmpty) return;
                  provider.agregarCalificacion(Calificacion(
                    id: provider.generarCalificacionId(),
                    nombre: nombreCtrl.text,
                    nota: double.tryParse(notaCtrl.text) ?? 0,
                    notaMaxima: double.tryParse(maxCtrl.text) ?? 10,
                    porcentaje: double.tryParse(porcCtrl.text) ?? 0,
                    materiaId: materia.id,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormNota(BuildContext context, Materia materia) {
    final tituloCtrl = TextEditingController();
    final contenidoCtrl = TextEditingController();
    final provider = context.read<AppProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nueva nota',
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
            const SizedBox(height: 10),
            TextField(
              controller: contenidoCtrl,
              decoration: const InputDecoration(labelText: 'Contenido'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (tituloCtrl.text.isEmpty) return;
                  provider.agregarNota(Nota(
                    id: provider.generarNotaId(),
                    titulo: tituloCtrl.text,
                    contenido: contenidoCtrl.text,
                    materiaId: materia.id,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Tareas Tab ────────────────────────────────────────────────────────────────
class _TareasTab extends StatelessWidget {
  final Materia materia;
  const _TareasTab({required this.materia});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final tareas = provider.tareasDeMateria(materia.id);

    if (tareas.isEmpty) {
      return const Center(child: Text('Sin tareas. Toca + para agregar.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tareas.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final t = tareas[i];
        final color = Color(materia.colorValue);
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: t.estado == EstadoTarea.entregada,
              activeColor: color,
              onChanged: (_) => provider.cambiarEstadoTarea(
                t.id,
                t.estado == EstadoTarea.entregada
                    ? EstadoTarea.pendiente
                    : EstadoTarea.entregada,
              ),
            ),
            title: Text(t.titulo,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: t.estado == EstadoTarea.entregada
                        ? TextDecoration.lineThrough
                        : null)),
            subtitle: Text('${t.tipo.emoji} ${t.tipo.label} · ${_formatFecha(t.fechaLimite)}'),
            trailing: t.estaVencida
                ? const Icon(Icons.warning_amber, color: Colors.red, size: 18)
                : Text(
                    t.diasRestantes == 0
                        ? 'Hoy'
                        : '${t.diasRestantes}d',
                    style: TextStyle(
                        fontSize: 12,
                        color: t.diasRestantes <= 2
                            ? Colors.orange
                            : Colors.grey),
                  ),
            onLongPress: () => provider.eliminarTarea(t.id),
          ),
        );
      },
    );
  }

  String _formatFecha(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

// ─── Calificaciones Tab ────────────────────────────────────────────────────────
class _CalificacionesTab extends StatelessWidget {
  final Materia materia;
  const _CalificacionesTab({required this.materia});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cals = provider.calificacionesDeMateria(materia.id);
    final promedio = provider.promedioMateria(materia.id);
    final color = Color(materia.colorValue);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (cals.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 45,
                    lineWidth: 8,
                    percent: (promedio / 100).clamp(0.0, 1.0),
                    center: Text(promedio.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    progressColor: color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Promedio actual',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(promedio.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: color)),
                      Text('sobre 100',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (cals.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Sin calificaciones. Toca + para agregar.')),
          ),
        ...cals.map((c) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(c.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${c.nota}/${c.notaMaxima}  ·  ${c.porcentaje.toStringAsFixed(0)}%'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      c.notaPonderada.toStringAsFixed(1),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: () => provider.eliminarCalificacion(c.id),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// ─── Notas Tab ────────────────────────────────────────────────────────────────
class _NotasTab extends StatelessWidget {
  final Materia materia;
  const _NotasTab({required this.materia});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final notas = provider.notasDeMateria(materia.id);

    if (notas.isEmpty) {
      return const Center(child: Text('Sin notas. Toca + para agregar.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: notas.length,
      itemBuilder: (ctx, i) {
        final n = notas[i];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: () => provider.eliminarNota(n.id),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(n.colorValue),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF333333))),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(n.contenido,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF555555))),
                ),
                Text(
                  '${n.fechaCreacion.day}/${n.fechaCreacion.month}/${n.fechaCreacion.year}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
