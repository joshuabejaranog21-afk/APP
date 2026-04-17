import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/tarea.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: provider.materias.isEmpty
          ? const Center(child: Text('Agrega materias para ver estadísticas'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RachaSection(provider: provider),
                const SizedBox(height: 20),
                _ResumenGeneral(provider: provider),
                const SizedBox(height: 20),
                _GraficaPromedios(provider: provider),
                const SizedBox(height: 20),
                _GraficaTareasPorEstado(provider: provider),
                const SizedBox(height: 20),
                _CargaPorMateria(provider: provider),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

// ─── Streak Section ──────────────────────────────────────────────────────────
class _RachaSection extends StatelessWidget {
  final AppProvider provider;
  const _RachaSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final racha = provider.rachaEstudio;
    final completadas = provider.totalTareasCompletadas;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Productividad',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            // Racha card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9A3C), Color(0xFFFF6B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      '$racha',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900),
                    ),
                    Text(
                      racha == 1 ? 'día de racha' : 'días de racha',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Completadas card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      '$completadas',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900),
                    ),
                    Text(
                      completadas == 1 ? 'tarea completada' : 'tareas completadas',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (racha == 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Completa al menos una tarea hoy para iniciar tu racha.',
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Resumen General ─────────────────────────────────────────────────────────
class _ResumenGeneral extends StatelessWidget {
  final AppProvider provider;
  const _ResumenGeneral({required this.provider});

  @override
  Widget build(BuildContext context) {
    final total = provider.tareas.length;
    final completadas = provider.totalTareasCompletadas;
    final vencidas = provider.tareasVencidas.length;
    final enProgreso =
        provider.tareas.where((t) => t.estado == EstadoTarea.enProgreso).length;
    final pct = total > 0 ? (completadas / total * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen General',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            _MiniStat(label: 'Total', value: '$total', icon: Icons.task),
            const SizedBox(width: 10),
            _MiniStat(
                label: 'Completadas',
                value: '$completadas',
                icon: Icons.check_circle,
                color: Colors.green),
            const SizedBox(width: 10),
            _MiniStat(
                label: 'En progreso',
                value: '$enProgreso',
                icon: Icons.timelapse,
                color: Colors.blue),
            const SizedBox(width: 10),
            _MiniStat(
                label: 'Vencidas',
                value: '$vencidas',
                icon: Icons.warning_amber,
                color: vencidas > 0 ? Colors.red : Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progreso general',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('$pct%',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total > 0 ? completadas / total : 0,
                minHeight: 10,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const _MiniStat(
      {required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: c)),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 9, color: c.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

// ─── Gráfica promedios ────────────────────────────────────────────────────────
class _GraficaPromedios extends StatelessWidget {
  final AppProvider provider;
  const _GraficaPromedios({required this.provider});

  @override
  Widget build(BuildContext context) {
    final materiasConNotas = provider.materias
        .where((m) => provider.calificacionesPorMateria(m.id).isNotEmpty)
        .toList();

    if (materiasConNotas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Promedios por Materia',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          height: 220,
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: BarChart(
            BarChartData(
              maxY: 10,
              minY: 0,
              gridData: FlGridData(
                show: true,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              groupsSpace: 12,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    reservedSize: 26,
                    getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                        style: const TextStyle(fontSize: 10)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i >= materiasConNotas.length) return const SizedBox();
                      final nombre = materiasConNotas[i].nombre;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          nombre.length > 6 ? '${nombre.substring(0, 5)}.' : nombre,
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: materiasConNotas.asMap().entries.map((e) {
                final promedio = provider.promedioMateria(e.value.id);
                final color = Color(e.value.colorValue);
                final barWidth =
                    (260 / materiasConNotas.length).clamp(14.0, 28.0);
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: promedio,
                      color: color,
                      width: barWidth,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Gráfica por estado ───────────────────────────────────────────────────────
class _GraficaTareasPorEstado extends StatelessWidget {
  final AppProvider provider;
  const _GraficaTareasPorEstado({required this.provider});

  @override
  Widget build(BuildContext context) {
    final pendientes =
        provider.tareas.where((t) => t.estado == EstadoTarea.pendiente).length;
    final enProgreso =
        provider.tareas.where((t) => t.estado == EstadoTarea.enProgreso).length;
    final entregadas =
        provider.tareas.where((t) => t.estado == EstadoTarea.entregada).length;

    if (provider.tareas.isEmpty) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    if (pendientes > 0) {
      sections.add(PieChartSectionData(
        value: pendientes.toDouble(),
        color: Colors.amber,
        title: '$pendientes',
        radius: 60,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
      ));
    }
    if (enProgreso > 0) {
      sections.add(PieChartSectionData(
        value: enProgreso.toDouble(),
        color: Colors.blue,
        title: '$enProgreso',
        radius: 60,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
      ));
    }
    if (entregadas > 0) {
      sections.add(PieChartSectionData(
        value: entregadas.toDouble(),
        color: Colors.green,
        title: '$entregadas',
        radius: 60,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado de Tareas',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 150, width: 150,
                child: PieChart(PieChartData(
                  sections: sections,
                  sectionsSpace: 3,
                  centerSpaceRadius: 30,
                )),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Leyenda(color: Colors.amber, label: 'Pendientes', count: pendientes),
                  const SizedBox(height: 8),
                  _Leyenda(color: Colors.blue, label: 'En progreso', count: enProgreso),
                  const SizedBox(height: 8),
                  _Leyenda(color: Colors.green, label: 'Entregadas', count: entregadas),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _Leyenda({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label ($count)',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Carga por materia ────────────────────────────────────────────────────────
class _CargaPorMateria extends StatelessWidget {
  final AppProvider provider;
  const _CargaPorMateria({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Carga por Materia',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...provider.materias.map((m) {
          final todas = provider.tareasPorMateria(m.id);
          final completadas =
              todas.where((t) => t.estado == EstadoTarea.entregada).length;
          final total = todas.length;
          final pct = total > 0 ? completadas / total : 0.0;
          final color = Color(m.colorValue);
          final promedio = provider.promedioMateria(m.id);
          final notaObj = m.notaObjetivo;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(m.nombre,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    Row(
                      children: [
                        if (notaObj != null && promedio > 0) ...[
                          Icon(
                            promedio >= notaObj * 10
                                ? Icons.check_circle
                                : Icons.trending_up,
                            size: 14,
                            color:
                                promedio >= notaObj * 10 ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text('$completadas/$total',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
