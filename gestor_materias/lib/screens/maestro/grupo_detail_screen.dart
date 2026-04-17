import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grupo.dart';
import '../../providers/app_provider.dart';

class GrupoDetailScreen extends StatefulWidget {
  final Grupo grupo;
  const GrupoDetailScreen({super.key, required this.grupo});

  @override
  State<GrupoDetailScreen> createState() => _GrupoDetailScreenState();
}

class _GrupoDetailScreenState extends State<GrupoDetailScreen> {
  late Grupo _grupo;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _grupo = widget.grupo;
  }

  List<AlumnoGrupo> get _alumnosFiltrados {
    if (_busqueda.isEmpty) return _grupo.alumnos;
    final q = _busqueda.toLowerCase();
    return _grupo.alumnos
        .where((a) => a.nombreCompleto.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(_grupo.colorValue);
    final tareas = context.watch<AppProvider>().tareasDeGrupo(_grupo.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(_grupo.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Agregar alumno',
            onPressed: () => _agregarAlumno(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header del grupo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                _StatChip(icon: Icons.people, label: '${_grupo.alumnos.length} alumnos', color: color),
                const SizedBox(width: 12),
                _StatChip(icon: Icons.assignment_outlined, label: '${tareas.length} tareas', color: color),
              ],
            ),
          ),
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar alumno...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),
          // Grid de tarjetas
          Expanded(
            child: _alumnosFiltrados.isEmpty
                ? _EmptyAlumnos(onAgregar: () => _agregarAlumno(context))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _alumnosFiltrados.length,
                    itemBuilder: (ctx, i) => _AlumnoCard(
                      alumno: _alumnosFiltrados[i],
                      grupoColor: color,
                      onEliminar: () => _eliminarAlumno(_alumnosFiltrados[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _agregarAlumno(BuildContext context) async {
    final provider = context.read<AppProvider>();
    final result = await showDialog<AlumnoGrupo>(
      context: context,
      builder: (ctx) => const _AgregarAlumnoDialog(),
    );
    if (result != null && mounted) {
      setState(() => _grupo.alumnos.add(result));
      await provider.editarGrupo(_grupo);
    }
  }

  Future<void> _eliminarAlumno(AlumnoGrupo alumno) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar alumno'),
        content: Text('¿Eliminar a ${alumno.nombreCompleto} del grupo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _grupo.alumnos.removeWhere((a) => a.id == alumno.id));
      await context.read<AppProvider>().editarGrupo(_grupo);
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _AlumnoCard extends StatelessWidget {
  final AlumnoGrupo alumno;
  final Color grupoColor;
  final VoidCallback onEliminar;
  const _AlumnoCard({required this.alumno, required this.grupoColor, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(alumno.colorValue);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      alumno.iniciales,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  alumno.nombre,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  alumno.apellido,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
            ),
          ),
          // Botón eliminar
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.6),
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: onEliminar,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlumnos extends StatelessWidget {
  final VoidCallback onAgregar;
  const _EmptyAlumnos({required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Sin alumnos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Agrega alumnos a este grupo', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAgregar,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Agregar alumno'),
          ),
        ],
      ),
    );
  }
}

class _AgregarAlumnoDialog extends StatefulWidget {
  const _AgregarAlumnoDialog();

  @override
  State<_AgregarAlumnoDialog> createState() => _AgregarAlumnoDialogState();
}

class _AgregarAlumnoDialogState extends State<_AgregarAlumnoDialog> {
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _colores = [
    0xFF6C63FF, 0xFF2196F3, 0xFFE91E63, 0xFF4CAF50,
    0xFFFF9800, 0xFF9C27B0, 0xFF009688, 0xFFFF5722,
    0xFF3F51B5, 0xFF795548, 0xFF607D8B, 0xFF00BCD4,
  ];
  int _colorSeleccionado = 0xFF6C63FF;

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar alumno'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apellido,
              decoration: const InputDecoration(labelText: 'Apellidos', prefixIcon: Icon(Icons.badge_outlined)),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el apellido' : null,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: Theme.of(context).textTheme.labelMedium),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colores.map((c) {
                final sel = c == _colorSeleccionado;
                return GestureDetector(
                  onTap: () => setState(() => _colorSeleccionado = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: sel ? Border.all(color: Colors.white, width: 2) : null,
                      boxShadow: sel ? [BoxShadow(color: Color(c).withValues(alpha: 0.6), blurRadius: 6)] : null,
                    ),
                    child: sel ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, AlumnoGrupo(
                id: 'alu-${DateTime.now().millisecondsSinceEpoch}',
                nombre: _nombre.text.trim(),
                apellido: _apellido.text.trim(),
                colorValue: _colorSeleccionado,
              ));
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
