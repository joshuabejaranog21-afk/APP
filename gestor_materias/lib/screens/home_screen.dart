import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/tarea.dart';
import '../models/materia.dart';
import 'materias/materias_screen.dart';
import 'tareas/tareas_screen.dart';
import 'horario/horario_screen.dart';
import 'calendario/calendario_screen.dart';
import 'estadisticas/estadisticas_screen.dart';
import 'pomodoro/pomodoro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    MateriasScreen(),
    TareasScreen(),
    CalendarioScreen(),
    EstadisticasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Materias'),
          NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task), label: 'Tareas'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendario'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final hoy = DateTime.now();
    const diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buenos días 👋',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text(
              '${diasSemana[hoy.weekday - 1]}, ${hoy.day} ${meses[hoy.month - 1]}',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(provider.modoOscuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: provider.toggleModoOscuro,
          ),
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Pomodoro',
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PomodoroScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.schedule_outlined),
            tooltip: 'Horario',
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HorarioScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ResumenCards(provider: provider),
          const SizedBox(height: 20),
          if (provider.tareasHoy.isNotEmpty) ...[
            _SectionHeader(title: 'Para hoy', count: provider.tareasHoy.length),
            const SizedBox(height: 8),
            ...provider.tareasHoy.map((t) => _TareaQuickCard(tarea: t)),
            const SizedBox(height: 20),
          ],
          if (provider.tareasPendientes.isNotEmpty) ...[
            _SectionHeader(title: 'Próximas entregas', count: provider.tareasPendientes.length),
            const SizedBox(height: 8),
            ...provider.tareasPendientes.take(5).map((t) => _TareaQuickCard(tarea: t)),
            const SizedBox(height: 20),
          ],
          if (provider.tareasVencidas.isNotEmpty) ...[
            _SectionHeader(
                title: '⚠️ Vencidas',
                count: provider.tareasVencidas.length,
                color: Colors.red),
            const SizedBox(height: 8),
            ...provider.tareasVencidas
                .map((t) => _TareaQuickCard(tarea: t, vencida: true)),
            const SizedBox(height: 20),
          ],
          if (provider.materias.isNotEmpty) ...[
            _SectionHeader(title: 'Mis materias'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.materias.length,
                separatorBuilder: (_, index) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) =>
                    _MateriaChip(materia: provider.materias[i]),
              ),
            ),
          ],
          if (provider.materias.isEmpty && provider.tareas.isEmpty)
            const _EmptyDashboard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ResumenCards extends StatelessWidget {
  final AppProvider provider;
  const _ResumenCards({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Materias', value: '${provider.materias.length}', icon: Icons.school, color: const Color(0xFF6C63FF))),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Pendientes', value: '${provider.tareasPendientes.length}', icon: Icons.pending_actions, color: const Color(0xFFFF9A3C))),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Vencidas', value: '${provider.tareasVencidas.length}', icon: Icons.warning_amber, color: const Color(0xFFEF5350))),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Color? color;
  const _SectionHeader({required this.title, this.count, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, color: color)),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? theme.colorScheme.primary).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color ?? theme.colorScheme.primary),
            ),
          ),
        ],
      ],
    );
  }
}

class _TareaQuickCard extends StatelessWidget {
  final Tarea tarea;
  final bool vencida;
  const _TareaQuickCard({required this.tarea, this.vencida = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final materia = provider.materias.firstWhere(
      (m) => m.id == tarea.materiaId,
      orElse: () =>
          Materia(id: '', nombre: 'Sin materia', colorValue: 0xFF9E9E9E),
    );
    final color = Color(materia.colorValue);
    final prioColor = tarea.prioridad == PrioridadTarea.alta
        ? Colors.red
        : tarea.prioridad == PrioridadTarea.media
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          tarea.titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: tarea.estado == EstadoTarea.entregada
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Row(
          children: [
            Flexible(
              child: Text(
                materia.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 6),
            Text('${tarea.tipo.emoji} ${tarea.tipo.label}',
                style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: vencida
                    ? Colors.red.withValues(alpha: 0.1)
                    : tarea.diasRestantes <= 1
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vencida
                    ? '${tarea.diasRestantes.abs()}d atrás'
                    : tarea.diasRestantes == 0
                        ? 'Hoy'
                        : tarea.diasRestantes == 1
                            ? 'Mañana'
                            : '${tarea.diasRestantes}d',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: vencida
                      ? Colors.red
                      : tarea.diasRestantes <= 1
                          ? Colors.orange
                          : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: prioColor, shape: BoxShape.circle),
            ),
          ],
        ),
        onTap: () => provider.cambiarEstadoTarea(
          tarea.id,
          tarea.estado == EstadoTarea.entregada
              ? EstadoTarea.pendiente
              : EstadoTarea.entregada,
        ),
      ),
    );
  }
}

class _MateriaChip extends StatelessWidget {
  final Materia materia;
  const _MateriaChip({required this.materia});

  @override
  Widget build(BuildContext context) {
    final color = Color(materia.colorValue);
    final provider = context.read<AppProvider>();
    final pendientes = provider
        .tareasDeMateria(materia.id)
        .where((t) => t.estado != EstadoTarea.entregada)
        .length;

    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            materia.nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color),
          ),
          if (pendientes > 0)
            Text(
              '$pendientes pendiente${pendientes > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
            ),
        ],
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.school_outlined,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('¡Bienvenido!',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Agrega tu primera materia para empezar',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
