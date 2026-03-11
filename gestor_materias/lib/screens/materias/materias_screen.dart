import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../providers/app_provider.dart';
import '../../models/materia.dart';
import 'materia_form.dart';
import 'materia_detail_screen.dart';

class MateriasScreen extends StatelessWidget {
  const MateriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Materias'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('${provider.materias.length} materias',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva materia'),
      ),
      body: provider.materias.isEmpty
          ? _EmptyMaterias(onAdd: () => _abrirForm(context, null))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: provider.materias.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) =>
                  _MateriaCard(materia: provider.materias[i]),
            ),
    );
  }

  void _abrirForm(BuildContext context, Materia? materia) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MateriaForm(materia: materia),
    );
  }
}

class _MateriaCard extends StatelessWidget {
  final Materia materia;
  const _MateriaCard({required this.materia});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final color = Color(materia.colorValue);
    final progreso = provider.progresoMateria(materia.id);
    final pendientes = provider
        .tareasDeMateria(materia.id)
        .where((t) => t.estado.index != 2)
        .length;
    final promedio = provider.promedioMateria(materia.id);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MateriaDetailScreen(materia: materia)),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconoMateria(materia.icono), color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(materia.nombre,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        if (materia.profesor.isNotEmpty)
                          Text(materia.profesor,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                      ],
                    ),
                  ),
                  _EditDeleteMenu(materia: materia),
                ],
              ),
              const SizedBox(height: 14),
              LinearPercentIndicator(
                percent: progreso.clamp(0.0, 1.0),
                lineHeight: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                progressColor: color,
                barRadius: const Radius.circular(8),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Badge(
                    icon: Icons.pending_actions,
                    label: '$pendientes pendiente${pendientes != 1 ? 's' : ''}',
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  if (materia.aula.isNotEmpty)
                    _Badge(icon: Icons.location_on, label: materia.aula, color: Colors.grey),
                  const Spacer(),
                  if (promedio > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _colorNota(promedio).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        promedio.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _colorNota(promedio)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorNota(double nota) {
    if (nota >= 80) return Colors.green;
    if (nota >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _iconoMateria(String icono) {
    const map = {
      'book': Icons.menu_book,
      'science': Icons.science,
      'calculate': Icons.calculate,
      'computer': Icons.computer,
      'history': Icons.history_edu,
      'language': Icons.language,
      'art': Icons.palette,
      'music': Icons.music_note,
      'sports': Icons.sports,
      'business': Icons.business,
    };
    return map[icono] ?? Icons.menu_book;
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

class _EditDeleteMenu extends StatelessWidget {
  final Materia materia;
  const _EditDeleteMenu({required this.materia});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 20),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Editar')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
      ],
      onSelected: (v) {
        if (v == 'edit') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => MateriaForm(materia: materia),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Eliminar materia'),
              content: Text('¿Eliminar "${materia.nombre}"? Se borrarán todas sus tareas y notas.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                FilledButton(
                  onPressed: () {
                    provider.eliminarMateria(materia.id);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _EmptyMaterias extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMaterias({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Sin materias', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Agrega tus materias del semestre', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Agregar materia')),
        ],
      ),
    );
  }
}
