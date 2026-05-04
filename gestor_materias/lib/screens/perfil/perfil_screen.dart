import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/tarea.dart';
import '../../services/export_service.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final total = provider.tareas.length;
    final completadas = provider.totalTareasCompletadas;
    final pendientes = provider.tareasPendientes.length;
    final vencidas = provider.tareasVencidas.length;
    final progreso = total > 0 ? completadas / total : 0.0;
    final racha = provider.rachaEstudio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Compartir resumen semanal',
            onPressed: () => _compartirResumenSemanal(provider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Avatar ────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          provider.userName.isNotEmpty
                              ? provider.userName[0].toUpperCase()
                              : '🎓',
                          style: TextStyle(
                            fontSize: provider.userName.isNotEmpty ? 38 : 40,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (racha > 0)
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9A3C),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: theme.scaffoldBackgroundColor, width: 2),
                          ),
                          child: Text('🔥$racha',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  provider.userName.isNotEmpty ? provider.userName : 'Alumno',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
                if (provider.userEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(provider.userEmail,
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.materias.length} materias activas',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Racha ─────────────────────────────────────────
          if (racha > 0) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A3C), Color(0xFFFF6B6B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('🔥', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Racha de estudio',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            '$racha ${racha == 1 ? 'día consecutivo' : 'días consecutivos'}',
                            style: const TextStyle(
                                color: Color(0xFFFF9A3C),
                                fontWeight: FontWeight.w800,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Progreso general ──────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progreso General',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        '${(progreso * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progreso,
                      minHeight: 12,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatItem(icon: Icons.task_outlined, label: 'Total', value: '$total', color: theme.colorScheme.primary),
                      _StatItem(icon: Icons.check_circle_outline, label: 'Hechas', value: '$completadas', color: Colors.green),
                      _StatItem(icon: Icons.pending_outlined, label: 'Pendientes', value: '$pendientes', color: Colors.orange),
                      _StatItem(icon: Icons.warning_amber_outlined, label: 'Vencidas', value: '$vencidas', color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Promedios y nota necesaria ────────────────────
          if (provider.materias.isNotEmpty) ...[
            Text('Promedios por Materia',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...provider.materias.map((m) {
              final prom = provider.promedioMateria(m.id);
              final color = Color(m.colorValue);
              final calCount = provider.calificacionesPorMateria(m.id).length;
              final necesaria = m.notaObjetivo != null
                  ? provider.notaNecesaria(m.id, m.notaObjetivo! * 10)
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                              calCount > 0
                                  ? '$calCount calificaciones registradas'
                                  : 'Sin calificaciones',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                            if (necesaria != null &&
                                calCount > 0 &&
                                prom < (m.notaObjetivo ?? 0) * 10) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Necesitas ${(necesaria / 10).toStringAsFixed(2)} en lo restante',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: calCount > 0
                              ? (prom >= 70
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1))
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          calCount > 0
                              ? (prom / 10).toStringAsFixed(2)
                              : '—',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: calCount > 0
                                ? (prom >= 70 ? Colors.green : Colors.red)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // ── Últimas tareas ────────────────────────────────
          Text('Últimas tareas',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...provider.tareas.take(5).map((t) {
            final materia = provider.materiaById(t.materiaId);
            final color = materia != null ? Color(materia.colorValue) : Colors.grey;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: Container(
                    width: 4, height: 36,
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(4))),
                title: Text(t.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text(materia?.nombre ?? '',
                    style: TextStyle(fontSize: 11, color: color)),
                trailing: _EstadoChip(estado: t.estado),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            );
          }),
          const SizedBox(height: 16),

          // ── Exportar calificaciones ───────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Exportar calificaciones PDF'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final prov = context.read<AppProvider>();
                try {
                  final bytes = await ExportService.generarReporteCompleto(
                    nombreAlumno: prov.userName.isNotEmpty ? prov.userName : 'Alumno',
                    materias: prov.materias,
                    calificaciones: prov.calificaciones,
                    tareas: prov.tareas,
                  );
                  await ExportService.compartir(bytes, 'reporte_calificaciones');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al generar PDF: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Cerrar sesión ─────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                        '¿Estás seguro de que quieres cerrar sesión?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Cerrar sesión')),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AppProvider>().logout();
                }
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _compartirResumenSemanal(AppProvider provider) async {
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final formatter = DateFormat("d 'de' MMMM", 'es_ES');

    // Tasks completed this week
    final completadasSemana = provider.tareas.where((t) =>
        t.completadaEn != null && t.completadaEn!.isAfter(inicioSemana)).length;

    // Upcoming this week
    final finSemana = inicioSemana.add(const Duration(days: 6));
    final proximasSemana = provider.tareasPendientes.where((t) =>
        t.fechaLimite.isBefore(finSemana.add(const Duration(days: 1)))).toList();

    final promediosLineas = provider.materias.map((m) {
      final prom = provider.promedioMateria(m.id);
      final calCount = provider.calificacionesPorMateria(m.id).length;
      if (calCount == 0) return '  ${m.nombre}: sin calificaciones';
      return '  ${m.nombre}: ${(prom / 10).toStringAsFixed(2)} / ${m.notaObjetivo?.toStringAsFixed(1) ?? '—'}';
    }).join('\n');

    final proximasLineas = proximasSemana.take(5).map((t) {
      final materia = provider.materiaById(t.materiaId);
      return '  ${t.tipo.emoji} ${t.titulo} (${materia?.nombre ?? '?'}) — ${formatter.format(t.fechaLimite)}';
    }).join('\n');

    final racha = provider.rachaEstudio;

    final texto = '''
🎓 Resumen Semanal — ${formatter.format(inicioSemana)} al ${formatter.format(finSemana)}

📊 Progreso general: ${provider.tareas.isNotEmpty ? (provider.totalTareasCompletadas / provider.tareas.length * 100).round() : 0}%
✅ Completadas esta semana: $completadasSemana
📚 Materias: ${provider.materias.length}
${racha > 0 ? '🔥 Racha de estudio: $racha días\n' : ''}
📈 Promedios actuales:
$promediosLineas
${proximasSemana.isNotEmpty ? '\n📅 Próximas entregas:\n$proximasLineas' : ''}

¡Gestionando mis tareas con éxito! 💪
''';

    await Share.share(texto, subject: 'Mi Resumen Semanal Académico');
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final EstadoTarea estado;
  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (estado) {
      EstadoTarea.entregada  => ('✅ Hecha',    Colors.green),
      EstadoTarea.enProgreso => ('🔄 Progreso', Colors.blue),
      EstadoTarea.pendiente  => ('⏳ Pendiente', Colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
