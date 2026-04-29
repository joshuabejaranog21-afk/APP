import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/tarea.dart';
import '../models/materia.dart';
import '../models/grupo.dart';
import 'materias/materias_screen.dart';
import 'tareas/tareas_screen.dart';
import 'tareas/tarea_form.dart';
import 'horario/horario_screen.dart';
import 'calendario/calendario_screen.dart';
import 'pomodoro/pomodoro_screen.dart';
import 'maestro/maestro_screen.dart';
import 'perfil/perfil_screen.dart';
import 'busqueda/busqueda_screen.dart';
import 'pdfs/pdfs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _screensAlumno = [
    _DashboardTab(),
    MateriasScreen(),
    TareasScreen(),
    PDFsScreen(),
    CalendarioScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final esMaestro = context.watch<AppProvider>().esMaestro;

    if (esMaestro) return const MaestroScreen();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screensAlumno),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Materias'),
          NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task), label: 'Tareas'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'PDFs'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendario'),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ──────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final hoy = DateTime.now();
    const diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    final userName = provider.userName;
    final saludo = userName.isNotEmpty && userName != 'Invitado'
        ? 'Hola, ${userName.split(' ').first}! 👋'
        : 'Buenos días 👋';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(saludo,
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
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusquedaScreen())),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) async {
              if (v == 'perfil') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen()));
              } else if (v == 'tema') {
                context.read<AppProvider>().toggleModoOscuro();
              } else if (v == 'maestro') {
                context.read<AppProvider>().setRol(true);
              } else if (v == 'seed') {
                await context.read<AppProvider>().seedDatosDePrueba();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('¡Datos de prueba cargados!'),
                        backgroundColor: Colors.green),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'perfil', child: ListTile(leading: Icon(Icons.account_circle_outlined), title: Text('Mi perfil'), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(
                value: 'tema',
                child: ListTile(
                  leading: Icon(provider.modoOscuro ? Icons.light_mode : Icons.dark_mode),
                  title: Text(provider.modoOscuro ? 'Modo claro' : 'Modo oscuro'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(value: 'maestro', child: ListTile(leading: Icon(Icons.swap_horiz), title: Text('Modo maestro'), contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'seed', child: ListTile(leading: Icon(Icons.data_object), title: Text('Cargar datos prueba'), contentPadding: EdgeInsets.zero)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => const TareaForm(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Resumen cards ──────────────────────────────────
          _ResumenCards(provider: provider),
          const SizedBox(height: 16),

          // ── Frase del día ──────────────────────────────────
          const _FraseDelDia(),
          const SizedBox(height: 16),

          // ── Streak card ────────────────────────────────────
          if (provider.rachaEstudio > 0) ...[
            _RachaCard(racha: provider.rachaEstudio),
            const SizedBox(height: 16),
          ],

          // ── Para hoy ──────────────────────────────────────
          if (provider.tareasHoy.isNotEmpty) ...[
            _SectionHeader(title: 'Para hoy', count: provider.tareasHoy.length),
            const SizedBox(height: 8),
            ...provider.tareasHoy.map((t) => _TareaQuickCard(tarea: t)),
            const SizedBox(height: 16),
          ],

          // ── Próximas entregas ──────────────────────────────
          if (provider.tareasPendientes.isNotEmpty) ...[
            _SectionHeader(title: 'Próximas entregas', count: provider.tareasPendientes.length),
            const SizedBox(height: 8),
            ...provider.tareasPendientes.take(5).map((t) => _TareaQuickCard(tarea: t)),
            const SizedBox(height: 16),
          ],

          // ── Vencidas ──────────────────────────────────────
          if (provider.tareasVencidas.isNotEmpty) ...[
            _SectionHeader(
                title: 'Vencidas',
                count: provider.tareasVencidas.length,
                color: Colors.red),
            const SizedBox(height: 8),
            ...provider.tareasVencidas.map((t) => _TareaQuickCard(tarea: t, vencida: true)),
            const SizedBox(height: 16),
          ],

          // ── Mis materias ───────────────────────────────────
          if (provider.materias.isNotEmpty) ...[
            _SectionHeader(title: 'Mis materias'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.materias.length,
                separatorBuilder: (_, i) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) =>
                    _MateriaChip(materia: provider.materias[i]),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Anuncios del maestro ───────────────────────────
          if (provider.anunciosRecientes.isNotEmpty) ...[
            _SectionHeader(
                title: 'Anuncios del maestro',
                count: provider.anunciosRecientes.length),
            const SizedBox(height: 8),
            ...provider.anunciosRecientes.take(3).map((a) => AnuncioCard(anuncio: a)),
            const SizedBox(height: 16),
          ],

          if (provider.materias.isEmpty && provider.tareas.isEmpty)
            const _EmptyDashboard(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─── Racha card ─────────────────────────────────────────────────────────────
class _RachaCard extends StatelessWidget {
  final int racha;
  const _RachaCard({required this.racha});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9A3C),
            const Color(0xFFFF6B6B),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$racha ${racha == 1 ? 'día' : 'días'} de racha',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
                Text(
                  '¡Sigue así! Completa tareas cada día para mantener tu racha.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Resumen cards ───────────────────────────────────────────────────────────
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
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────
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

// ─── Tarea quick card ────────────────────────────────────────────────────────
class _TareaQuickCard extends StatelessWidget {
  final Tarea tarea;
  final bool vencida;
  const _TareaQuickCard({required this.tarea, this.vencida = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final materia = provider.materias.firstWhere(
      (m) => m.id == tarea.materiaId,
      orElse: () => Materia(id: '', nombre: 'Sin materia', colorValue: 0xFF9E9E9E),
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
          width: 4, height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    materia.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 6),
                Text('${tarea.tipo.emoji} ${tarea.tipo.label}',
                    style: const TextStyle(fontSize: 11)),
                if (tarea.esRecurrente) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.repeat, size: 11, color: Colors.grey),
                ],
              ],
            ),
            // Subtask mini-bar
            if (tarea.subtareas.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: tarea.progresoSubtareas,
                        minHeight: 3,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${tarea.subtareasCompletadasCount}/${tarea.subtareas.length}',
                    style: TextStyle(fontSize: 10, color: color),
                  ),
                ],
              ),
            ],
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
              width: 8, height: 8,
              decoration: BoxDecoration(color: prioColor, shape: BoxShape.circle),
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

// ─── Materia chip ────────────────────────────────────────────────────────────
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

// ─── Anuncio card ────────────────────────────────────────────────────────────
class AnuncioCard extends StatelessWidget {
  final Anuncio anuncio;
  const AnuncioCard({super.key, required this.anuncio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (anuncio.fijado)
                  const Icon(Icons.push_pin, size: 14, color: Colors.orange),
                if (anuncio.fijado) const SizedBox(width: 4),
                Expanded(
                  child: Text(anuncio.titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(anuncio.cuerpo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ─── Empty dashboard ─────────────────────────────────────────────────────────
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

// ─── Frase del día ───────────────────────────────────────────────────────────
class _FraseDelDia extends StatelessWidget {
  const _FraseDelDia();

  static const _frases = [
    'El éxito es la suma de pequeños esfuerzos repetidos día a día.',
    'No estudies para aprobar. Estudia para aprender.',
    'Cada experto fue una vez un principiante.',
    'El conocimiento crece cuando se comparte.',
    'La constancia vence al talento cuando el talento no trabaja.',
    'Tu futuro se crea por lo que haces hoy, no mañana.',
    'Disciplina es recordar lo que quieres.',
    'No hay atajos para ningún lugar que valga la pena.',
    'El estudio es la llave que abre todas las puertas.',
    'Invierte en tu mente. Es el mejor rendimiento posible.',
    'Aprende como si fueras a vivir para siempre.',
    'No te compares con otros. Compárate con quien eras ayer.',
    'Los retos de hoy son los triunfos de mañana.',
    'Perseverar es la clave del éxito académico.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diaDelAnio = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    final frase = _frases[diaDelAnio % _frases.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frase del día',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '"$frase"',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
