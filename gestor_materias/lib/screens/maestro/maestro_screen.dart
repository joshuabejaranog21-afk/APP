import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/grupo.dart';
import '../../models/tarea.dart';
import 'grupo_form.dart';
import 'grupo_detail_screen.dart';
import 'anuncio_form.dart';
import 'asignar_tarea_screen.dart';

class MaestroScreen extends StatefulWidget {
  const MaestroScreen({super.key});

  @override
  State<MaestroScreen> createState() => _MaestroScreenState();
}

class _MaestroScreenState extends State<MaestroScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Maestro'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.groups_outlined), text: 'Grupos'),
            Tab(icon: Icon(Icons.campaign_outlined), text: 'Anuncios'),
            Tab(icon: Icon(Icons.assignment_outlined), text: 'Tareas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.data_object),
            tooltip: 'Recargar datos de prueba',
            onPressed: () async {
              await context.read<AppProvider>().seedDatosDePrueba();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Datos recargados!'), backgroundColor: Colors.green),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Cambiar a modo alumno',
            onPressed: () => _confirmarCambioRol(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GruposTab(),
          _AnunciosTab(),
          _TareasAsignadasTab(),
        ],
      ),
      floatingActionButton: _FabPorTab(tabController: _tabController),
    );
  }

  Future<void> _confirmarCambioRol(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar a modo alumno'),
        content: const Text('¿Deseas salir del panel de maestro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, cambiar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppProvider>().setRol(false);
    }
  }
}

// ─── FAB dinámico según tab activo ────────────────────────────────────────────
class _FabPorTab extends StatefulWidget {
  final TabController tabController;
  const _FabPorTab({required this.tabController});

  @override
  State<_FabPorTab> createState() => _FabPorTabState();
}

class _FabPorTabState extends State<_FabPorTab> {
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () { if (mounted) setState(() {}); };
    widget.tabController.addListener(_listener);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.tabController.index;
    return FloatingActionButton.extended(
      onPressed: () {
        if (index == 0) _abrirGrupoForm(context);
        if (index == 1) _abrirAnuncioForm(context);
        if (index == 2) _abrirAsignarTarea(context);
      },
      icon: const Icon(Icons.add),
      label: Text(index == 0
          ? 'Nuevo grupo'
          : index == 1
              ? 'Nuevo anuncio'
              : 'Asignar tarea'),
    );
  }

  void _abrirGrupoForm(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GrupoForm()));
  }

  void _abrirAnuncioForm(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AnuncioForm()));
  }

  void _abrirAsignarTarea(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AsignarTareaScreen()));
  }
}

// ─── Tab Grupos ────────────────────────────────────────────────────────────────
class _GruposTab extends StatelessWidget {
  const _GruposTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final grupos = provider.grupos;

    if (grupos.isEmpty) {
      return const _EmptyState(
        icon: Icons.groups_outlined,
        mensaje: 'No hay grupos creados\nToca + para crear el primero',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grupos.length,
      itemBuilder: (_, i) => _GrupoCard(grupo: grupos[i]),
    );
  }
}

class _GrupoCard extends StatelessWidget {
  final Grupo grupo;
  const _GrupoCard({required this.grupo});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final color = Color(grupo.colorValue);
    final numTareas = provider.tareasDeGrupo(grupo.id).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => GrupoDetailScreen(grupo: grupo))),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            grupo.nombre.substring(0, grupo.nombre.length > 2 ? 2 : grupo.nombre.length).toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        title: Text(grupo.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: grupo.descripcion.isNotEmpty ? Text(grupo.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (numTareas > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$numTareas tarea${numTareas != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'editar') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => GrupoForm(grupo: grupo)));
                } else if (v == 'eliminar') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar grupo'),
                      content: Text('Se eliminarán también las tareas asignadas a "${grupo.nombre}".'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    provider.eliminarGrupo(grupo.id);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Anuncios ──────────────────────────────────────────────────────────────
class _AnunciosTab extends StatelessWidget {
  const _AnunciosTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final anuncios = provider.anunciosRecientes;

    if (anuncios.isEmpty) {
      return const _EmptyState(
        icon: Icons.campaign_outlined,
        mensaje: 'Sin anuncios publicados\nToca + para crear uno',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: anuncios.length,
      itemBuilder: (_, i) => _AnuncioCard(anuncio: anuncios[i], esMaestro: true),
    );
  }
}

class _AnuncioCard extends StatelessWidget {
  final Anuncio anuncio;
  final bool esMaestro;
  const _AnuncioCard({required this.anuncio, this.esMaestro = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final grupo = anuncio.grupoId != null
        ? provider.grupos.where((g) => g.id == anuncio.grupoId).firstOrNull
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (anuncio.fijado) ...[
                  const Icon(Icons.push_pin, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(anuncio.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                if (esMaestro)
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'fijar') {
                        provider.toggleFijarAnuncio(anuncio.id);
                      } else if (v == 'editar') {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AnuncioForm(anuncio: anuncio)));
                      } else if (v == 'eliminar') {
                        provider.eliminarAnuncio(anuncio.id);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'fijar',
                        child: Text(anuncio.fijado ? 'Desfijar' : 'Fijar'),
                      ),
                      const PopupMenuItem(value: 'editar', child: Text('Editar')),
                      const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(anuncio.cuerpo, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  _formatFecha(anuncio.fecha),
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
                if (grupo != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(grupo.colorValue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(grupo.nombre,
                        style: TextStyle(fontSize: 11, color: Color(grupo.colorValue), fontWeight: FontWeight.w600)),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Todos',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}

// ─── Tab Tareas Asignadas ──────────────────────────────────────────────────────
class _TareasAsignadasTab extends StatelessWidget {
  const _TareasAsignadasTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final tareas = provider.tareas.where((t) => t.asignadoPorMaestro == true).toList()
      ..sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));

    if (tareas.isEmpty) {
      return const _EmptyState(
        icon: Icons.assignment_outlined,
        mensaje: 'No hay tareas asignadas\nToca + para asignar una tarea a un grupo',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tareas.length,
      itemBuilder: (_, i) => _TareaMaestroCard(tarea: tareas[i]),
    );
  }
}

class _TareaMaestroCard extends StatelessWidget {
  final Tarea tarea;
  const _TareaMaestroCard({required this.tarea});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final materia = provider.materiaById(tarea.materiaId);
    final grupo = tarea.grupoId != null
        ? provider.grupos.where((g) => g.id == tarea.grupoId).firstOrNull
        : null;
    final color = materia != null ? Color(materia.colorValue) : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(tarea.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (materia != null)
              Text(materia.nombre, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
            Row(
              children: [
                if (grupo != null) ...[
                  Icon(Icons.groups, size: 12, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(grupo.nombre, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 8),
                ],
                Icon(Icons.calendar_today, size: 12, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 3),
                Text(_formatFecha(tarea.fechaLimite),
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => provider.eliminarTarea(tarea.id),
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String mensaje;
  const _EmptyState({required this.icon, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// Clase pública para reusar AnuncioCard desde el dashboard del alumno
class AnuncioCard extends StatelessWidget {
  final Anuncio anuncio;
  const AnuncioCard({super.key, required this.anuncio});

  @override
  Widget build(BuildContext context) => _AnuncioCard(anuncio: anuncio, esMaestro: false);
}
