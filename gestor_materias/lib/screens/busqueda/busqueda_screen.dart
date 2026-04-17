import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/tarea.dart';
import '../../models/materia.dart';
import '../../models/nota.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final _ctrl = TextEditingController();
  Map<String, List<dynamic>> _resultados = {};
  bool _buscado = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _buscar(AppProvider provider) {
    setState(() {
      _resultados = provider.buscar(_ctrl.text);
      _buscado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final total = _resultados.values.fold(0, (s, l) => s + l.length);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Buscar tareas, materias, notas...',
            border: InputBorder.none,
            filled: false,
            hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
          onChanged: (_) => _buscar(provider),
          onSubmitted: (_) => _buscar(provider),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                setState(() {
                  _resultados = {};
                  _buscado = false;
                });
              },
            ),
        ],
      ),
      body: !_buscado
          ? _buildSugerencias(provider)
          : _ctrl.text.trim().isEmpty
              ? _buildSugerencias(provider)
              : total == 0
                  ? _buildVacio()
                  : _buildResultados(provider),
    );
  }

  Widget _buildSugerencias(AppProvider provider) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Búsqueda rápida',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...provider.materias.map((m) => ActionChip(
                  avatar: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                        color: Color(m.colorValue), shape: BoxShape.circle),
                  ),
                  label: Text(m.nombre),
                  onPressed: () {
                    _ctrl.text = m.nombre;
                    _buscar(provider);
                  },
                )),
            ...['Examen', 'Proyecto', 'Quiz', 'Laboratorio'].map((s) =>
                ActionChip(
                  label: Text(s),
                  onPressed: () {
                    _ctrl.text = s;
                    _buscar(provider);
                  },
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildVacio() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('Sin resultados para "${_ctrl.text}"',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget _buildResultados(AppProvider provider) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Tareas ──────────────────────────────────────────
        if (_resultados['tareas'] != null) ...[
          _ResultHeader(
              label: 'Tareas',
              count: _resultados['tareas']!.length,
              icon: Icons.task),
          ...(_resultados['tareas'] as List<Tarea>).map((t) {
            final materia = provider.materiaById(t.materiaId);
            final color =
                materia != null ? Color(materia.colorValue) : Colors.grey;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 4, height: 36,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(4)),
                ),
                title: _Highlighted(text: t.titulo, query: _ctrl.text),
                subtitle: Row(
                  children: [
                    Text(materia?.nombre ?? '',
                        style:
                            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Text('${t.tipo.emoji} ${t.tipo.label}',
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
                trailing: _EstadoBadge(estado: t.estado),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // ── Materias ─────────────────────────────────────────
        if (_resultados['materias'] != null) ...[
          _ResultHeader(
              label: 'Materias',
              count: _resultados['materias']!.length,
              icon: Icons.school),
          ...(_resultados['materias'] as List<Materia>).map((m) {
            final color = Color(m.colorValue);
            final pendientes = provider
                .tareasDeMateria(m.id)
                .where((t) => t.estado != EstadoTarea.entregada)
                .length;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(m.nombre[0],
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                ),
                title: _Highlighted(text: m.nombre, query: _ctrl.text),
                subtitle: Text(m.profesor.isNotEmpty ? m.profesor : 'Sin profesor',
                    style: const TextStyle(fontSize: 11)),
                trailing: pendientes > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('$pendientes pend.',
                            style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w700)),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // ── Notas ────────────────────────────────────────────
        if (_resultados['notas'] != null) ...[
          _ResultHeader(
              label: 'Notas',
              count: _resultados['notas']!.length,
              icon: Icons.note),
          ...(_resultados['notas'] as List<Nota>).map((n) {
            final materia = provider.materiaById(n.materiaId);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Color(n.colorValue),
              child: ListTile(
                title: _Highlighted(
                    text: n.titulo,
                    query: _ctrl.text,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333))),
                subtitle: Text(n.contenido,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF555555))),
                trailing: materia != null
                    ? Text(materia.nombre,
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(materia.colorValue),
                            fontWeight: FontWeight.w600))
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            );
          }),
        ],

        const SizedBox(height: 80),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  const _ResultHeader(
      {required this.label, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}

/// Renders text with the query substring highlighted in bold.
class _Highlighted extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  const _Highlighted({required this.text, required this.query, this.style});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);
    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final idx = lower.indexOf(lowerQ);
    if (idx < 0) return Text(text, style: style);

    final base = style ?? DefaultTextStyle.of(context).style;
    return Text.rich(TextSpan(children: [
      if (idx > 0) TextSpan(text: text.substring(0, idx), style: base),
      TextSpan(
          text: text.substring(idx, idx + query.length),
          style: base.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary)),
      if (idx + query.length < text.length)
        TextSpan(text: text.substring(idx + query.length), style: base),
    ]));
  }
}

class _EstadoBadge extends StatelessWidget {
  final EstadoTarea estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (estado) {
      EstadoTarea.entregada  => ('✅', Colors.green),
      EstadoTarea.enProgreso => ('🔄', Colors.blue),
      EstadoTarea.pendiente  => ('⏳', Colors.orange),
    };
    return Text(label);
  }
}
