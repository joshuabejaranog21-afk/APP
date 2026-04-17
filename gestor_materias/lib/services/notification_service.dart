import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/tarea.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  // ─── Inicializar ─────────────────────────────────────────────
  static Future<void> inicializar() async {
    if (_inicializado) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {},
    );

    // Solicitar permiso en Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _inicializado = true;
  }

  // ─── Canal de notificaciones ──────────────────────────────────
  static const _channelTareas = AndroidNotificationDetails(
    'tareas_channel',
    'Recordatorios de Tareas',
    channelDescription: 'Avisos de tareas próximas a vencer',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _channelPomodoro = AndroidNotificationDetails(
    'pomodoro_channel',
    'Sesiones Pomodoro',
    channelDescription: 'Avisos de sesiones de estudio',
    importance: Importance.max,
    priority: Priority.max,
    icon: '@mipmap/ic_launcher',
    playSound: true,
  );

  static const _channelAnuncios = AndroidNotificationDetails(
    'anuncios_channel',
    'Anuncios del Maestro',
    channelDescription: 'Nuevos anuncios publicados por el maestro',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  // ─── TAREAS: programar recordatorio 24h antes ─────────────────
  static Future<void> programarRecordatorioTarea(Tarea tarea, String nombreMateria) async {
    await inicializar();

    // Cancelar si ya existía
    await cancelarTarea(tarea.id);

    // No programar si ya está entregada o vencida
    if (tarea.estado == EstadoTarea.entregada) return;
    if (tarea.fechaLimite.isBefore(DateTime.now())) return;

    // 24 horas antes de la fecha límite
    final fechaAviso = tarea.fechaLimite.subtract(const Duration(hours: 24));
    if (fechaAviso.isBefore(DateTime.now())) {
      // Menos de 24h: avisar en 5 minutos
      await _mostrarInmediata(
        id: tarea.id.hashCode.abs() % 100000,
        titulo: '⚠️ Tarea próxima a vencer',
        cuerpo: '${tarea.titulo} vence hoy — $nombreMateria',
        channel: _channelTareas,
      );
      return;
    }

    await _plugin.zonedSchedule(
      tarea.id.hashCode.abs() % 100000,
      '📚 Tarea para mañana',
      '${tarea.titulo} • $nombreMateria',
      tz.TZDateTime.from(fechaAviso, tz.local),
      NotificationDetails(android: _channelTareas),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelarTarea(String tareaId) async {
    await _plugin.cancel(tareaId.hashCode.abs() % 100000);
  }

  // ─── POMODORO: inicio de descanso ────────────────────────────
  static Future<void> notificarPomodoroDescanso(int sesion) async {
    await inicializar();
    await _mostrarInmediata(
      id: 90001,
      titulo: '✅ ¡Sesión $sesion completada!',
      cuerpo: 'Tómate un descanso. Te lo mereces 🎉',
      channel: _channelPomodoro,
    );
  }

  // ─── POMODORO: fin del descanso ──────────────────────────────
  static Future<void> notificarPomodoroFin() async {
    await inicializar();
    await _mostrarInmediata(
      id: 90002,
      titulo: '🍅 ¡A estudiar!',
      cuerpo: 'El descanso terminó. ¡Vamos con la siguiente sesión!',
      channel: _channelPomodoro,
    );
  }

  // ─── ANUNCIOS del maestro ────────────────────────────────────
  static Future<void> notificarAnuncio(String titulo, String cuerpo) async {
    await inicializar();
    await _mostrarInmediata(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      titulo: '📢 $titulo',
      cuerpo: cuerpo.length > 80 ? '${cuerpo.substring(0, 77)}...' : cuerpo,
      channel: _channelAnuncios,
    );
  }

  // ─── Recordatorio de horario de clase ────────────────────────
  static Future<void> notificarClaseProxima(String materia, String hora) async {
    await inicializar();
    await _mostrarInmediata(
      id: materia.hashCode.abs() % 100000,
      titulo: '🏫 Clase en 10 minutos',
      cuerpo: '$materia — $hora',
      channel: _channelTareas,
    );
  }

  // ─── Cancelar todas ──────────────────────────────────────────
  static Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }

  // ─── Helper interno ──────────────────────────────────────────
  static Future<void> _mostrarInmediata({
    required int id,
    required String titulo,
    required String cuerpo,
    required AndroidNotificationDetails channel,
  }) async {
    await _plugin.show(id, titulo, cuerpo, NotificationDetails(android: channel));
  }
}
