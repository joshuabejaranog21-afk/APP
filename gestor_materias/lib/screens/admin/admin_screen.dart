import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/materia.dart';
import '../../models/grupo.dart';
import '../../models/profesor.dart';
import '../../providers/app_provider.dart';

const _uuid = Uuid();

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Panel de Administrador'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school_outlined),     text: 'Materias'),
            Tab(icon: Icon(Icons.groups_outlined),      text: 'Grupos'),
            Tab(icon: Icon(Icons.co_present_outlined),  text: 'Profesores'),
            Tab(icon: Icon(Icons.person_outlined),      text: 'Alumnos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Cambiar rol',
            onPressed: () => _confirmarCambioRol(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MateriasTab(),
          _GruposTab(),
          _ProfesoresTab(),
          _AlumnosTab(),
        ],
      ),
      floatingActionButton: _FabPorTab(tabController: _tabController),
    );
  }

  Future<void> _confirmarCambioRol(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar rol'),
        content: const Text('¿Deseas volver a la selección de rol?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final provider = context.read<AppProvider>();
      provider.resetRol();
    }
  }
}

// ── FAB dinámico ──────────────────────────────────────────────
class _FabPorTab extends StatefulWidget {
  final TabController tabController;
  const _FabPorTab({required this.tabController});

  @override
  State<_FabPorTab> createState() => _FabPorTabState();
}

class _FabPorTabState extends State<_FabPorTab> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      if (mounted) setState(() => _tab = widget.tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels  = ['Nueva materia', 'Nuevo grupo', 'Nuevo profesor', 'Nuevo alumno'];
    final icons   = [Icons.add, Icons.group_add, Icons.person_add, Icons.person_add_alt_1];

    return FloatingActionButton.extended(
      heroTag: 'admin_fab',
      icon: Icon(icons[_tab]),
      label: Text(labels[_tab]),
      onPressed: () => _accion(context),
    );
  }

  void _accion(BuildContext context) {
    switch (_tab) {
      case 0: _nuevaMateria(context); break;
      case 1: _nuevoGrupo(context);   break;
      case 2: _nuevoProfesor(context); break;
    case 3: _nuevoAlumno(context); break;
    }
  }

  void _nuevaMateria(BuildContext context) =>
      showDialog(context: context, builder: (_) => const _MateriaDialog());

  void _nuevoGrupo(BuildContext context) =>
      showDialog(context: context, builder: (_) => const _GrupoDialog());

  void _nuevoProfesor(BuildContext context) =>
      showDialog(context: context, builder: (_) => const _ProfesorDialog());

  void _nuevoAlumno(BuildContext context) =>
      showDialog(context: context, builder: (_) => const _AlumnoDialog());
}

// ─── Tab Materias ─────────────────────────────────────────────
class _MateriasTab extends StatelessWidget {
  const _MateriasTab();

  @override
  Widget build(BuildContext context) {
    final materias = context.watch<AppProvider>().materias;
    final theme = Theme.of(context);

    if (materias.isEmpty) {
      return _EmptyState(
        icon: Icons.school_outlined,
        mensaje: 'No hay materias registradas',
        sub: 'Toca + para agregar una',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: materias.length,
      itemBuilder: (context, i) {
        final m = materias[i];
        final color = Color(m.colorValue);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(Icons.school, color: color),
            ),
            title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${m.profesor}  •  ${m.aula}',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            trailing: PopupMenuButton<String>(
              onSelected: (v) => _accionMateria(context, v, m),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar',   child: Text('Editar')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar',
                    style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }

  void _accionMateria(BuildContext context, String accion, Materia m) {
    if (accion == 'editar') {
      showDialog(context: context, builder: (_) => _MateriaDialog(materia: m));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar materia'),
          content: Text('¿Eliminar "${m.nombre}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<AppProvider>().eliminarMateria(m.id);
                Navigator.pop(ctx);
              },
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
    }
  }
}

// ─── Tab Grupos ───────────────────────────────────────────────
class _GruposTab extends StatelessWidget {
  const _GruposTab();

  @override
  Widget build(BuildContext context) {
    final grupos = context.watch<AppProvider>().grupos;
    final theme = Theme.of(context);

    if (grupos.isEmpty) {
      return _EmptyState(
        icon: Icons.groups_outlined,
        mensaje: 'No hay grupos registrados',
        sub: 'Toca + para agregar uno',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: grupos.length,
      itemBuilder: (context, i) {
        final g = grupos[i];
        final color = Color(g.colorValue);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Text('${g.alumnos.length}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ),
            title: Text(g.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(g.descripcion.isEmpty ? 'Sin descripción' : g.descripcion,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _GrupoDialog(grupo: g),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: () => _confirmarEliminar(context, g),
              ),
            ]),
            children: g.alumnos.isEmpty
                ? [Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Sin alumnos asignados',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  )]
                : g.alumnos.map((a) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(a.colorValue).withValues(alpha: 0.2),
                        child: Text(a.nombre[0].toUpperCase(),
                            style: TextStyle(fontSize: 12,
                                color: Color(a.colorValue),
                                fontWeight: FontWeight.w700)),
                      ),
                      title: Text('${a.nombre} ${a.apellido}',
                          style: const TextStyle(fontSize: 13)),
                    )).toList(),
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, Grupo g) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text('¿Eliminar el grupo "${g.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AppProvider>().eliminarGrupo(g.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Profesores ───────────────────────────────────────────
class _ProfesoresTab extends StatelessWidget {
  const _ProfesoresTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profesores = provider.profesores;
    final theme = Theme.of(context);

    if (profesores.isEmpty) {
      return _EmptyState(
        icon: Icons.co_present_outlined,
        mensaje: 'No hay profesores registrados',
        sub: 'Toca + para agregar uno',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: profesores.length,
      itemBuilder: (context, i) {
        final p = profesores[i];
        // Materias que imparte este profesor
        final materiasAsignadas = provider.materias
            .where((m) => m.profesor == p.nombre)
            .toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(p.nombre[0].toUpperCase(),
                  style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700)),
            ),
            title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(p.email,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            trailing: PopupMenuButton<String>(
              onSelected: (v) => _accionProfesor(context, v, p),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar',   child: Text('Editar')),
                PopupMenuItem(value: 'asignar',  child: Text('Asignar materia')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar',
                    style: TextStyle(color: Colors.red))),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Materias asignadas',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    if (materiasAsignadas.isEmpty)
                      Text('Sin materias asignadas',
                          style: TextStyle(fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant))
                    else
                      Wrap(
                        spacing: 6, runSpacing: 4,
                        children: materiasAsignadas.map((m) => Chip(
                          label: Text(m.nombre, style: const TextStyle(fontSize: 11)),
                          backgroundColor: Color(m.colorValue).withValues(alpha: 0.15),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _accionProfesor(BuildContext context, String accion, Profesor p) {
    switch (accion) {
      case 'editar':
        showDialog(context: context, builder: (_) => _ProfesorDialog(profesor: p));
        break;
      case 'asignar':
        showDialog(context: context, builder: (_) => _AsignarMateriaDialog(profesor: p));
        break;
      case 'eliminar':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar profesor'),
            content: Text('¿Eliminar a "${p.nombre}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<AppProvider>().eliminarProfesor(p.id);
                  Navigator.pop(ctx);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        break;
    }
  }
}

// ─── Diálogos ─────────────────────────────────────────────────
class _MateriaDialog extends StatefulWidget {
  final Materia? materia;
  const _MateriaDialog({this.materia});

  @override
  State<_MateriaDialog> createState() => _MateriaDialogState();
}

class _MateriaDialogState extends State<_MateriaDialog> {
  late final TextEditingController _nombre = TextEditingController(text: widget.materia?.nombre ?? '');
  late final TextEditingController _prof   = TextEditingController(text: widget.materia?.profesor ?? '');
  late final TextEditingController _aula   = TextEditingController(text: widget.materia?.aula ?? '');

  @override
  void dispose() { _nombre.dispose(); _prof.dispose(); _aula.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.materia != null;
    return AlertDialog(
      title: Text(esEdicion ? 'Editar materia' : 'Nueva materia'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nombre, decoration: const InputDecoration(labelText: 'Nombre de la materia')),
        const SizedBox(height: 12),
        TextField(controller: _prof, decoration: const InputDecoration(labelText: 'Profesor')),
        const SizedBox(height: 12),
        TextField(controller: _aula, decoration: const InputDecoration(labelText: 'Aula')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (_nombre.text.trim().isEmpty) return;
            final provider = context.read<AppProvider>();
            if (esEdicion) {
              final m = widget.materia!;
              m.nombre   = _nombre.text.trim();
              m.profesor = _prof.text.trim();
              m.aula     = _aula.text.trim();
              provider.editarMateria(m);
            } else {
              provider.agregarMateria(Materia(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: _nombre.text.trim(),
                profesor: _prof.text.trim(),
                aula: _aula.text.trim(),
                colorValue: 0xFF6750A4,
              ));
            }
            Navigator.pop(context);
          },
          child: Text(esEdicion ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }
}

class _GrupoDialog extends StatefulWidget {
  final Grupo? grupo;
  const _GrupoDialog({this.grupo});

  @override
  State<_GrupoDialog> createState() => _GrupoDialogState();
}

class _GrupoDialogState extends State<_GrupoDialog> {
  late final TextEditingController _nombre = TextEditingController(text: widget.grupo?.nombre ?? '');
  late final TextEditingController _desc   = TextEditingController(text: widget.grupo?.descripcion ?? '');

  @override
  void dispose() { _nombre.dispose(); _desc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.grupo != null;
    return AlertDialog(
      title: Text(esEdicion ? 'Editar grupo' : 'Nuevo grupo'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nombre, decoration: const InputDecoration(labelText: 'Nombre del grupo')),
        const SizedBox(height: 12),
        TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Descripción')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (_nombre.text.trim().isEmpty) return;
            final provider = context.read<AppProvider>();
            if (esEdicion) {
              final g = widget.grupo!;
              g.nombre      = _nombre.text.trim();
              g.descripcion = _desc.text.trim();
              provider.editarGrupo(g);
            } else {
              provider.agregarGrupo(Grupo(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: _nombre.text.trim(),
                descripcion: _desc.text.trim(),
                colorValue: 0xFF4CAF50,
              ));
            }
            Navigator.pop(context);
          },
          child: Text(esEdicion ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }
}

class _ProfesorDialog extends StatefulWidget {
  final Profesor? profesor;
  const _ProfesorDialog({this.profesor});

  @override
  State<_ProfesorDialog> createState() => _ProfesorDialogState();
}

class _ProfesorDialogState extends State<_ProfesorDialog> {
  late final TextEditingController _nombre  = TextEditingController(text: widget.profesor?.nombre ?? '');
  late final TextEditingController _email   = TextEditingController(text: widget.profesor?.email ?? '');
  late final TextEditingController _materia = TextEditingController(text: widget.profesor?.especialidad ?? '');

  @override
  void dispose() { _nombre.dispose(); _email.dispose(); _materia.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.profesor != null;
    return AlertDialog(
      title: Text(esEdicion ? 'Editar profesor' : 'Nuevo profesor'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nombre, decoration: const InputDecoration(labelText: 'Nombre completo')),
        const SizedBox(height: 12),
        TextField(controller: _email, decoration: const InputDecoration(labelText: 'Correo electrónico'), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        TextField(controller: _materia, decoration: const InputDecoration(labelText: 'Especialidad')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (_nombre.text.trim().isEmpty) return;
            final provider = context.read<AppProvider>();
            if (esEdicion) {
              final p = widget.profesor!;
              p.nombre        = _nombre.text.trim();
              p.email         = _email.text.trim();
              p.especialidad  = _materia.text.trim();
              provider.editarProfesor(p);
            } else {
              provider.agregarProfesor(Profesor(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: _nombre.text.trim(),
                email: _email.text.trim(),
                especialidad: _materia.text.trim(),
              ));
            }
            Navigator.pop(context);
          },
          child: Text(esEdicion ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }
}

class _AsignarMateriaDialog extends StatelessWidget {
  final Profesor profesor;
  const _AsignarMateriaDialog({required this.profesor});

  @override
  Widget build(BuildContext context) {
    final materias = context.read<AppProvider>().materias;
    return AlertDialog(
      title: Text('Asignar materia a ${profesor.nombre}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: materias.length,
          itemBuilder: (context, i) {
            final m = materias[i];
            final asignada = m.profesor == profesor.nombre;
            return ListTile(
              title: Text(m.nombre),
              subtitle: Text(m.aula),
              trailing: asignada
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.circle_outlined),
              onTap: () {
                m.profesor = asignada ? '' : profesor.nombre;
                context.read<AppProvider>().editarMateria(m);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String mensaje;
  final String sub;
  const _EmptyState({required this.icon, required this.mensaje, required this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
        const SizedBox(height: 12),
        Text(mensaje, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

// ─── Tab Alumnos ──────────────────────────────────────────────
class _AlumnosTab extends StatelessWidget {
  const _AlumnosTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final alumnos = provider.todosLosAlumnos;
    final theme = Theme.of(context);

    if (alumnos.isEmpty) {
      return _EmptyState(
        icon: Icons.person_outlined,
        mensaje: 'No hay alumnos registrados',
        sub: 'Toca + para agregar uno',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: alumnos.length,
      itemBuilder: (context, i) {
        final alumno = alumnos[i].alumno;
        final grupo  = alumnos[i].grupo;
        final color  = Color(alumno.colorValue);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Text(alumno.iniciales,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            title: Text(alumno.nombreCompleto,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Row(children: [
              Icon(Icons.groups_outlined, size: 12,
                  color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(grupo.nombre,
                  style: TextStyle(fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant)),
            ]),
            trailing: PopupMenuButton<String>(
              onSelected: (v) => _accion(context, v, alumno, grupo),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar',   child: Text('Editar')),
                PopupMenuItem(value: 'mover',    child: Text('Cambiar grupo')),
                PopupMenuItem(value: 'eliminar', child: Text('Eliminar',
                    style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }

  void _accion(BuildContext context, String accion, AlumnoGrupo alumno, Grupo grupo) {
    switch (accion) {
      case 'editar':
        showDialog(context: context,
            builder: (_) => _AlumnoDialog(alumno: alumno, grupoId: grupo.id));
        break;
      case 'mover':
        showDialog(context: context,
            builder: (_) => _CambiarGrupoDialog(alumno: alumno, grupoActualId: grupo.id));
        break;
      case 'eliminar':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar alumno'),
            content: Text('¿Eliminar a "${alumno.nombreCompleto}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<AppProvider>().eliminarAlumnoDeGrupo(grupo.id, alumno.id);
                  Navigator.pop(ctx);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        break;
    }
  }
}

// ─── Dialog Alumno ────────────────────────────────────────────
class _AlumnoDialog extends StatefulWidget {
  final AlumnoGrupo? alumno;
  final String? grupoId;
  const _AlumnoDialog({this.alumno, this.grupoId});

  @override
  State<_AlumnoDialog> createState() => _AlumnoDialogState();
}

class _AlumnoDialogState extends State<_AlumnoDialog> {
  late final TextEditingController _nombre   = TextEditingController(text: widget.alumno?.nombre ?? '');
  late final TextEditingController _apellido = TextEditingController(text: widget.alumno?.apellido ?? '');
  String? _grupoSeleccionado;

  @override
  void initState() {
    super.initState();
    _grupoSeleccionado = widget.grupoId;
  }

  @override
  void dispose() { _nombre.dispose(); _apellido.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final grupos = provider.grupos;
    final esEdicion = widget.alumno != null;

    return AlertDialog(
      title: Text(esEdicion ? 'Editar alumno' : 'Nuevo alumno'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nombre,
            decoration: const InputDecoration(labelText: 'Nombre')),
        const SizedBox(height: 12),
        TextField(controller: _apellido,
            decoration: const InputDecoration(labelText: 'Apellido')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _grupoSeleccionado,
          decoration: const InputDecoration(labelText: 'Grupo'),
          items: grupos.map((g) => DropdownMenuItem(
            value: g.id,
            child: Text(g.nombre),
          )).toList(),
          onChanged: (v) => setState(() => _grupoSeleccionado = v),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (_nombre.text.trim().isEmpty || _grupoSeleccionado == null) return;
            final prov = context.read<AppProvider>();
            if (esEdicion) {
              final actualizado = AlumnoGrupo(
                id: widget.alumno!.id,
                nombre: _nombre.text.trim(),
                apellido: _apellido.text.trim(),
                colorValue: widget.alumno!.colorValue,
              );
              prov.editarAlumnoEnGrupo(_grupoSeleccionado!, actualizado);
            } else {
              prov.agregarAlumnoAGrupo(_grupoSeleccionado!, AlumnoGrupo(
                id: _uuid.v4(),
                nombre: _nombre.text.trim(),
                apellido: _apellido.text.trim(),
                colorValue: 0xFF6750A4,
              ));
            }
            Navigator.pop(context);
          },
          child: Text(esEdicion ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }
}

// ─── Dialog cambiar grupo ─────────────────────────────────────
class _CambiarGrupoDialog extends StatelessWidget {
  final AlumnoGrupo alumno;
  final String grupoActualId;
  const _CambiarGrupoDialog({required this.alumno, required this.grupoActualId});

  @override
  Widget build(BuildContext context) {
    final grupos = context.read<AppProvider>().grupos;
    return AlertDialog(
      title: Text('Mover a ${alumno.nombre}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: grupos.length,
          itemBuilder: (context, i) {
            final g = grupos[i];
            final esActual = g.id == grupoActualId;
            return ListTile(
              title: Text(g.nombre),
              trailing: esActual
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: esActual ? null : () {
                final prov = context.read<AppProvider>();
                prov.eliminarAlumnoDeGrupo(grupoActualId, alumno.id);
                prov.agregarAlumnoAGrupo(g.id, alumno);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      ],
    );
  }
}
