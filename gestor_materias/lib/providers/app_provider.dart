import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/materia.dart';
import '../models/tarea.dart';
import '../models/nota.dart';
import '../models/grupo.dart';
import '../models/estudio_pdf.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<Materia> _materias = [];
  List<Tarea> _tareas = [];
  List<Nota> _notas = [];
  List<Calificacion> _calificaciones = [];
  List<Grupo> _grupos = [];
  List<Anuncio> _anuncios = [];
  bool _modoOscuro = false;
  bool _cargando = false;
  bool _esMaestro = false;
  bool _rolSeleccionado = false;

  // ─── Pomodoro settings ────────────────────────────────────
  int _pomodoroTrabajo = 25;
  int _pomodoroDescansoCorto = 5;
  int _pomodoroDescansoLargo = 15;

  // ─── Streak tracking ──────────────────────────────────────
  List<String> _fechasEstudio = []; // "2024-04-14" ISO date strings

  // ─── PDF study module ─────────────────────────────────────
  List<EstudioPDF> _pdfs = [];
  String _claudeApiKey = '';

  List<EstudioPDF> get pdfs => _pdfs;
  String get claudeApiKey => _claudeApiKey;

  List<Materia> get materias => _materias;
  List<Tarea> get tareas => _tareas;
  List<Nota> get notas => _notas;
  List<Calificacion> get calificaciones => _calificaciones;
  List<Grupo> get grupos => _grupos;
  List<Anuncio> get anuncios => _anuncios;
  bool get modoOscuro => _modoOscuro;
  bool get cargando => _cargando;
  bool get esMaestro => _esMaestro;
  bool get rolSeleccionado => _rolSeleccionado;
  int get pomodoroTrabajo => _pomodoroTrabajo;
  int get pomodoroDescansoCorto => _pomodoroDescansoCorto;
  int get pomodoroDescansoLargo => _pomodoroDescansoLargo;

  // ─── Streak ────────────────────────────────────────────────
  int get rachaEstudio {
    if (_fechasEstudio.isEmpty) return 0;
    final fechas = _fechasEstudio.toSet().toList()..sort();
    final hoy = _isoDate(DateTime.now());
    final ayer = _isoDate(DateTime.now().subtract(const Duration(days: 1)));

    // Must have studied today or yesterday to have an active streak
    if (!fechas.contains(hoy) && !fechas.contains(ayer)) return 0;

    int racha = 0;
    DateTime cursor = fechas.contains(hoy)
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(days: 1));

    while (fechas.contains(_isoDate(cursor))) {
      racha++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return racha;
  }

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _registrarEstudioHoy() {
    final hoy = _isoDate(DateTime.now());
    if (!_fechasEstudio.contains(hoy)) {
      _fechasEstudio.add(hoy);
    }
  }

  // ─── Filtros ───────────────────────────────────────────────
  List<Tarea> tareasDeMateria(String materiaId) =>
      _tareas.where((t) => t.materiaId == materiaId).toList();

  List<Tarea> get tareasPendientes =>
      _tareas.where((t) => t.estado != EstadoTarea.entregada).toList()
        ..sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));

  List<Tarea> get tareasHoy {
    final hoy = DateTime.now();
    return _tareas
        .where((t) =>
            t.fechaLimite.year == hoy.year &&
            t.fechaLimite.month == hoy.month &&
            t.fechaLimite.day == hoy.day &&
            t.estado != EstadoTarea.entregada)
        .toList();
  }

  List<Tarea> get tareasVencidas =>
      _tareas.where((t) => t.estaVencida).toList();

  List<Nota> notasDeMateria(String materiaId) =>
      _notas.where((n) => n.materiaId == materiaId).toList();

  List<Calificacion> calificacionesDeMateria(String materiaId) =>
      _calificaciones.where((c) => c.materiaId == materiaId).toList();

  double promedioMateria(String materiaId) {
    final cals = calificacionesDeMateria(materiaId);
    if (cals.isEmpty) return 0;
    final totalPorcentaje = cals.fold(0.0, (s, c) => s + c.porcentaje);
    if (totalPorcentaje == 0) return 0;
    final suma = cals.fold(0.0, (s, c) => s + c.notaPonderada);
    return (suma / totalPorcentaje) * 100;
  }

  double progresoMateria(String materiaId) {
    final todas = tareasDeMateria(materiaId);
    if (todas.isEmpty) return 0;
    final entregadas =
        todas.where((t) => t.estado == EstadoTarea.entregada).length;
    return entregadas / todas.length;
  }

  Materia? materiaById(String id) {
    try {
      return _materias.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  int get totalTareasCompletadas =>
      _tareas.where((t) => t.estado == EstadoTarea.entregada).length;

  List<Calificacion> calificacionesPorMateria(String materiaId) =>
      calificacionesDeMateria(materiaId);

  List<Tarea> tareasPorMateria(String materiaId) => tareasDeMateria(materiaId);

  Map<DateTime, List<Tarea>> get tareasPorDia {
    final map = <DateTime, List<Tarea>>{};
    for (final t in _tareas) {
      final dia =
          DateTime(t.fechaLimite.year, t.fechaLimite.month, t.fechaLimite.day);
      map.putIfAbsent(dia, () => []).add(t);
    }
    return map;
  }

  // ─── Grade needed calculator ───────────────────────────────
  /// Returns the grade needed on ungraded work (remaining %) to hit [objetivo]
  /// on a 0–100 scale. Returns null if objective is already achieved or no
  /// remaining percentage exists.
  double? notaNecesaria(String materiaId, double objetivo) {
    final cals = calificacionesDeMateria(materiaId);
    final porcentajeActual = cals.fold(0.0, (s, c) => s + c.porcentaje);
    final porcentajeRestante = 100.0 - porcentajeActual;
    if (porcentajeRestante <= 0) return null;

    final puntosActuales = cals.fold(0.0, (s, c) => s + c.notaPonderada);
    // puntosActuales + (notaNecesaria/10 * porcentajeRestante) = objetivo
    final necesaria =
        (objetivo - puntosActuales) / (porcentajeRestante / 100.0);
    return necesaria.clamp(0.0, 100.0);
  }

  // ─── Search ────────────────────────────────────────────────
  Map<String, List<dynamic>> buscar(String query) {
    if (query.trim().isEmpty) return {};
    final q = query.toLowerCase();
    final tareas = _tareas
        .where((t) =>
            t.titulo.toLowerCase().contains(q) ||
            t.descripcion.toLowerCase().contains(q))
        .toList();
    final materias = _materias
        .where((m) =>
            m.nombre.toLowerCase().contains(q) ||
            m.profesor.toLowerCase().contains(q))
        .toList();
    final notas = _notas
        .where((n) =>
            n.titulo.toLowerCase().contains(q) ||
            n.contenido.toLowerCase().contains(q))
        .toList();
    return {
      if (tareas.isNotEmpty) 'tareas': tareas,
      if (materias.isNotEmpty) 'materias': materias,
      if (notas.isNotEmpty) 'notas': notas,
    };
  }

  // ─── Materias ──────────────────────────────────────────────
  Future<void> agregarMateria(Materia m) async {
    _materias.add(m);
    notifyListeners();
    await _guardar();
  }

  Future<void> editarMateria(Materia m) async {
    final i = _materias.indexWhere((x) => x.id == m.id);
    if (i >= 0) {
      _materias[i] = m;
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> eliminarMateria(String id) async {
    _materias.removeWhere((m) => m.id == id);
    _tareas.removeWhere((t) => t.materiaId == id);
    _notas.removeWhere((n) => n.materiaId == id);
    _calificaciones.removeWhere((c) => c.materiaId == id);
    notifyListeners();
    await _guardar();
  }

  String generarMateriaId() => _uuid.v4();

  // ─── Tareas ────────────────────────────────────────────────
  Future<void> agregarTarea(Tarea t) async {
    _tareas.add(t);
    notifyListeners();
    await _guardar();
    final materia = materiaById(t.materiaId);
    if (materia != null) {
      NotificationService.programarRecordatorioTarea(t, materia.nombre);
    }
  }

  Future<void> editarTarea(Tarea t) async {
    final i = _tareas.indexWhere((x) => x.id == t.id);
    if (i >= 0) {
      _tareas[i] = t;
      notifyListeners();
      await _guardar();
      final materia = materiaById(t.materiaId);
      if (materia != null) {
        NotificationService.programarRecordatorioTarea(t, materia.nombre);
      }
    }
  }

  Future<void> cambiarEstadoTarea(String id, EstadoTarea estado) async {
    final i = _tareas.indexWhere((t) => t.id == id);
    if (i >= 0) {
      _tareas[i].estado = estado;
      if (estado == EstadoTarea.entregada) {
        _tareas[i].completadaEn = DateTime.now();
        _registrarEstudioHoy();
        NotificationService.cancelarTarea(id);
        // Recurring: create next week's copy
        if (_tareas[i].esRecurrente) {
          final original = _tareas[i];
          final nuevaTarea = Tarea(
            id: _uuid.v4(),
            titulo: original.titulo,
            descripcion: original.descripcion,
            materiaId: original.materiaId,
            fechaLimite: original.fechaLimite.add(const Duration(days: 7)),
            prioridad: original.prioridad,
            tipo: original.tipo,
            esRecurrente: true,
            subtareas: original.subtareas
                .map((s) => SubtareaItem(titulo: s.titulo))
                .toList(),
          );
          _tareas.add(nuevaTarea);
        }
      }
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> actualizarSubtarea(
      String tareaId, int index, bool completada) async {
    final i = _tareas.indexWhere((t) => t.id == tareaId);
    if (i >= 0 && index < _tareas[i].subtareas.length) {
      _tareas[i].subtareas[index].completada = completada;
      // If all subtasks done, mark task as in-progress
      if (completada &&
          _tareas[i].subtareasCompletadasCount ==
              _tareas[i].subtareas.length &&
          _tareas[i].estado == EstadoTarea.pendiente) {
        _tareas[i].estado = EstadoTarea.enProgreso;
      }
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> eliminarTarea(String id) async {
    NotificationService.cancelarTarea(id);
    _tareas.removeWhere((t) => t.id == id);
    notifyListeners();
    await _guardar();
  }

  String generarTareaId() => _uuid.v4();

  // ─── Notas ─────────────────────────────────────────────────
  Future<void> agregarNota(Nota n) async {
    _notas.add(n);
    notifyListeners();
    await _guardar();
  }

  Future<void> editarNota(Nota n) async {
    final i = _notas.indexWhere((x) => x.id == n.id);
    if (i >= 0) {
      _notas[i] = n;
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> eliminarNota(String id) async {
    _notas.removeWhere((n) => n.id == id);
    notifyListeners();
    await _guardar();
  }

  String generarNotaId() => _uuid.v4();

  // ─── Calificaciones ────────────────────────────────────────
  Future<void> agregarCalificacion(Calificacion c) async {
    _calificaciones.add(c);
    notifyListeners();
    await _guardar();
  }

  Future<void> eliminarCalificacion(String id) async {
    _calificaciones.removeWhere((c) => c.id == id);
    notifyListeners();
    await _guardar();
  }

  String generarCalificacionId() => _uuid.v4();

  // ─── Rol ───────────────────────────────────────────────────
  Future<void> setRol(bool esMaestro) async {
    _esMaestro = esMaestro;
    _rolSeleccionado = true;
    notifyListeners();
    await _guardar();
  }

  // ─── Grupos ────────────────────────────────────────────────
  Future<void> agregarGrupo(Grupo g) async {
    _grupos.add(g);
    notifyListeners();
    await _guardar();
  }

  Future<void> editarGrupo(Grupo g) async {
    final i = _grupos.indexWhere((x) => x.id == g.id);
    if (i >= 0) {
      _grupos[i] = g;
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> eliminarGrupo(String id) async {
    _grupos.removeWhere((g) => g.id == id);
    _tareas.removeWhere((t) => t.grupoId == id && t.asignadoPorMaestro);
    _anuncios.removeWhere((a) => a.grupoId == id);
    notifyListeners();
    await _guardar();
  }

  String generarGrupoId() => _uuid.v4();

  List<Tarea> tareasDeGrupo(String grupoId) =>
      _tareas.where((t) => t.grupoId == grupoId).toList();

  // ─── Anuncios ──────────────────────────────────────────────
  List<Anuncio> get anunciosFijados =>
      _anuncios.where((a) => a.fijado).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));

  List<Anuncio> get anunciosRecientes {
    final lista = List<Anuncio>.from(_anuncios)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  Future<void> agregarAnuncio(Anuncio a) async {
    _anuncios.add(a);
    notifyListeners();
    await _guardar();
    NotificationService.notificarAnuncio(a.titulo, a.cuerpo);
  }

  Future<void> editarAnuncio(Anuncio a) async {
    final i = _anuncios.indexWhere((x) => x.id == a.id);
    if (i >= 0) {
      _anuncios[i] = a;
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> eliminarAnuncio(String id) async {
    _anuncios.removeWhere((a) => a.id == id);
    notifyListeners();
    await _guardar();
  }

  Future<void> toggleFijarAnuncio(String id) async {
    final i = _anuncios.indexWhere((a) => a.id == id);
    if (i >= 0) {
      _anuncios[i].fijado = !_anuncios[i].fijado;
      notifyListeners();
      await _guardar();
    }
  }

  String generarAnuncioId() => _uuid.v4();

  // ─── Tema ──────────────────────────────────────────────────
  void toggleModoOscuro() {
    _modoOscuro = !_modoOscuro;
    notifyListeners();
    _guardar();
  }

  // ─── PDF study module ─────────────────────────────────────
  Future<void> agregarPDF(EstudioPDF pdf) async {
    _pdfs.add(pdf);
    notifyListeners();
    await _guardar();
    // Sync to Supabase Storage in background
    try {
      final storagePath = '${pdf.id}.pdf';
      final url = await PDFsStorageApi.subirArchivo(pdf.rutaLocal, storagePath);
      final pdfConUrl = EstudioPDF(
        id: pdf.id,
        titulo: pdf.titulo,
        rutaLocal: pdf.rutaLocal,
        materiaId: pdf.materiaId,
        urlSupabase: url,
        notas: pdf.notas,
        historialIA: pdf.historialIA,
        fechaAgregado: pdf.fechaAgregado,
        ultimaPagina: pdf.ultimaPagina,
        totalPaginas: pdf.totalPaginas,
      );
      final i = _pdfs.indexWhere((p) => p.id == pdf.id);
      if (i >= 0) _pdfs[i] = pdfConUrl;
      await PDFsStorageApi.guardarMetadata(pdfConUrl);
      notifyListeners();
      await _guardar();
    } catch (_) {
      // Supabase sync failed — PDF still available locally
    }
  }

  Future<void> actualizarPDF(EstudioPDF pdf) async {
    final i = _pdfs.indexWhere((p) => p.id == pdf.id);
    if (i >= 0) {
      _pdfs[i] = pdf;
    } else {
      _pdfs.add(pdf);
    }
    notifyListeners();
    await _guardar();
    // Sync metadata to Supabase
    try {
      await PDFsStorageApi.guardarMetadata(pdf);
    } catch (_) {}
  }

  Future<void> eliminarPDF(String id) async {
    final pdf = _pdfs.firstWhere((p) => p.id == id, orElse: () => EstudioPDF(titulo: '', rutaLocal: ''));
    if (pdf.rutaLocal.isNotEmpty) {
      final file = File(pdf.rutaLocal);
      if (await file.exists()) await file.delete();
    }
    _pdfs.removeWhere((p) => p.id == id);
    notifyListeners();
    await _guardar();
    // Remove from Supabase
    try {
      await PDFsStorageApi.eliminarArchivo('$id.pdf');
      await PDFsStorageApi.eliminarMetadata(id);
    } catch (_) {}
  }

  Future<void> setClaudeApiKey(String key) async {
    _claudeApiKey = key;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('claudeApiKey', key);
  }

  // ─── Pomodoro settings ─────────────────────────────────────
  Future<void> setPomodoroSettings(int trabajo, int descansoCorto, int descansoLargo) async {
    _pomodoroTrabajo = trabajo;
    _pomodoroDescansoCorto = descansoCorto;
    _pomodoroDescansoLargo = descansoLargo;
    notifyListeners();
    await _guardar();
  }

  // ─── Persistencia ──────────────────────────────────────────
  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    _modoOscuro      = prefs.getBool('modoOscuro')      ?? false;
    _esMaestro       = prefs.getBool('esMaestro')       ?? false;
    _rolSeleccionado = prefs.getBool('rolSeleccionado')  ?? false;
    _pomodoroTrabajo      = prefs.getInt('pomodoroTrabajo')      ?? 25;
    _pomodoroDescansoCorto = prefs.getInt('pomodoroDescansoCorto') ?? 5;
    _pomodoroDescansoLargo = prefs.getInt('pomodoroDescansoLargo') ?? 15;
    _fechasEstudio = prefs.getStringList('fechasEstudio') ?? [];
    _claudeApiKey = prefs.getString('claudeApiKey') ?? '';
    final pdfsJson = prefs.getString('pdfs');
    if (pdfsJson != null) {
      _pdfs.clear();
      _pdfs.addAll((jsonDecode(pdfsJson) as List).map((e) => EstudioPDF.fromJson(e)));
    }

    try {
      final results = await Future.wait([
        MateriasApi.getAll(),
        TareasApi.getAll(),
        NotasApi.getAll(),
        CalificacionesApi.getAll(),
        GruposApi.getAll(),
        AnunciosApi.getAll(),
      ]);
      _materias        = results[0] as List<Materia>;
      _tareas          = results[1] as List<Tarea>;
      _notas           = results[2] as List<Nota>;
      _calificaciones  = results[3] as List<Calificacion>;
      _grupos          = results[4] as List<Grupo>;
      _anuncios        = results[5] as List<Anuncio>;
      _usandoApi       = true;
    } catch (_) {
      _usandoApi = false;
      final mJson = prefs.getString('materias');
      if (mJson != null) _materias = (jsonDecode(mJson) as List).map((e) => Materia.fromJson(e)).toList();
      final tJson = prefs.getString('tareas');
      if (tJson != null) _tareas = (jsonDecode(tJson) as List).map((e) => Tarea.fromJson(e)).toList();
      final nJson = prefs.getString('notas');
      if (nJson != null) _notas = (jsonDecode(nJson) as List).map((e) => Nota.fromJson(e)).toList();
      final cJson = prefs.getString('calificaciones');
      if (cJson != null) _calificaciones = (jsonDecode(cJson) as List).map((e) => Calificacion.fromJson(e)).toList();
      final gJson = prefs.getString('grupos');
      if (gJson != null) _grupos = (jsonDecode(gJson) as List).map((e) => Grupo.fromJson(e)).toList();
      final aJson = prefs.getString('anuncios');
      if (aJson != null) _anuncios = (jsonDecode(aJson) as List).map((e) => Anuncio.fromJson(e)).toList();
    }

    _cargando = false;
    notifyListeners();
  }

  bool _usandoApi = false;
  bool get usandoApi => _usandoApi;

  // ─── Datos de prueba ───────────────────────────────────────
  Future<void> seedDatosDePrueba() async {
    final hoy = DateTime.now();
    d(int dias) => DateTime(hoy.year, hoy.month, hoy.day + dias);

    const m1 = 'mat-01', m2 = 'mat-02', m3 = 'mat-03',
               m4 = 'mat-04', m5 = 'mat-05', m6 = 'mat-06';
    const g1 = 'grp-01', g2 = 'grp-02', g3 = 'grp-03';

    _materias = [
      Materia(id: m1, nombre: 'Matemáticas',   profesor: 'Prof. García',   aula: 'A-301', colorValue: 0xFF6C63FF, icono: 'calculate',   notaObjetivo: 9.0,
        horarios: [HorarioClase(diaSemana: 1, horaInicio: '08:00', horaFin: '09:30'), HorarioClase(diaSemana: 3, horaInicio: '08:00', horaFin: '09:30')]),
      Materia(id: m2, nombre: 'Programación',  profesor: 'Prof. López',    aula: 'B-205', colorValue: 0xFF2196F3, icono: 'code',        notaObjetivo: 9.5,
        horarios: [HorarioClase(diaSemana: 2, horaInicio: '10:00', horaFin: '11:30'), HorarioClase(diaSemana: 4, horaInicio: '10:00', horaFin: '11:30')]),
      Materia(id: m3, nombre: 'Física',        profesor: 'Prof. Ramírez',  aula: 'C-102', colorValue: 0xFFFF9800, icono: 'science',     notaObjetivo: 8.5,
        horarios: [HorarioClase(diaSemana: 1, horaInicio: '11:00', horaFin: '12:30'), HorarioClase(diaSemana: 5, horaInicio: '09:00', horaFin: '10:30')]),
      Materia(id: m4, nombre: 'Historia',      profesor: 'Prof. Martínez', aula: 'A-205', colorValue: 0xFFE53935, icono: 'history',     notaObjetivo: 8.0,
        horarios: [HorarioClase(diaSemana: 2, horaInicio: '08:00', horaFin: '09:30'), HorarioClase(diaSemana: 5, horaInicio: '11:00', horaFin: '12:30')]),
      Materia(id: m5, nombre: 'Inglés',        profesor: 'Prof. Smith',    aula: 'B-101', colorValue: 0xFF4CAF50, icono: 'language',    notaObjetivo: 9.0,
        horarios: [HorarioClase(diaSemana: 3, horaInicio: '10:00', horaFin: '11:30'), HorarioClase(diaSemana: 5, horaInicio: '13:00', horaFin: '14:00')]),
      Materia(id: m6, nombre: 'Química',       profesor: 'Prof. Torres',   aula: 'D-304', colorValue: 0xFF009688, icono: 'biotech',     notaObjetivo: 8.5,
        horarios: [HorarioClase(diaSemana: 4, horaInicio: '13:00', horaFin: '14:30'), HorarioClase(diaSemana: 6, horaInicio: '09:00', horaFin: '10:30')]),
    ];

    _tareas = [
      Tarea(id: 'tar-01', titulo: 'Ejercicios de integrales', materiaId: m1, fechaLimite: d(-5), estado: EstadoTarea.pendiente,  prioridad: PrioridadTarea.alta,  tipo: TipoActividad.tarea,      descripcion: 'Resolver ejercicios 3.1 al 3.10 del libro'),
      Tarea(id: 'tar-02', titulo: 'Ensayo Revolución Industrial', materiaId: m4, fechaLimite: d(-3), estado: EstadoTarea.pendiente, prioridad: PrioridadTarea.alta,  tipo: TipoActividad.tarea,      descripcion: 'Mínimo 3 cuartillas, APA 7ma edición'),
      Tarea(id: 'tar-03', titulo: 'Lab: Leyes de Newton',     materiaId: m3, fechaLimite: d(-1), estado: EstadoTarea.pendiente,  prioridad: PrioridadTarea.media, tipo: TipoActividad.laboratorio, descripcion: 'Reporte de práctica con conclusiones'),
      Tarea(id: 'tar-04', titulo: 'Examen parcial de Inglés', materiaId: m5, fechaLimite: d(0),  estado: EstadoTarea.enProgreso, prioridad: PrioridadTarea.alta,  tipo: TipoActividad.examen,     descripcion: 'Unidades 4 y 5. Reading comprehension + Grammar',
        subtareas: [SubtareaItem(titulo: 'Repasar vocabulario', completada: true), SubtareaItem(titulo: 'Practicar gramática'), SubtareaItem(titulo: 'Leer textos de comprensión')]),
      Tarea(id: 'tar-05', titulo: 'Quiz: Tabla periódica',    materiaId: m6, fechaLimite: d(0),  estado: EstadoTarea.pendiente,  prioridad: PrioridadTarea.alta,  tipo: TipoActividad.quiz,       descripcion: 'Primeros 20 elementos con símbolo y número atómico'),
      Tarea(id: 'tar-06', titulo: 'Proyecto final: App móvil',materiaId: m2, fechaLimite: d(2),  estado: EstadoTarea.enProgreso, prioridad: PrioridadTarea.alta,  tipo: TipoActividad.proyecto,   descripcion: 'Aplicación Flutter con mínimo 5 pantallas. Presentar APK y código',
        subtareas: [SubtareaItem(titulo: 'Diseñar wireframes', completada: true), SubtareaItem(titulo: 'Implementar pantallas', completada: true), SubtareaItem(titulo: 'Conectar base de datos'), SubtareaItem(titulo: 'Generar APK'), SubtareaItem(titulo: 'Preparar presentación')]),
      Tarea(id: 'tar-07', titulo: 'Lectura cap. 7 y 8',       materiaId: m4, fechaLimite: d(3),  estado: EstadoTarea.pendiente,  prioridad: PrioridadTarea.baja,  tipo: TipoActividad.lectura,    descripcion: 'Segunda Guerra Mundial. Cuestionario de 10 preguntas', esRecurrente: true),
      Tarea(id: 'tar-08', titulo: 'Tarea: Algoritmos de ordenamiento', materiaId: m2, fechaLimite: d(4), estado: EstadoTarea.pendiente, prioridad: PrioridadTarea.media, tipo: TipoActividad.tarea, descripcion: 'Implementar BubbleSort, QuickSort y MergeSort en Dart'),
      Tarea(id: 'tar-09', titulo: 'Exposición: Relatividad',  materiaId: m3, fechaLimite: d(5),  estado: EstadoTarea.pendiente,  prioridad: PrioridadTarea.media, tipo: TipoActividad.exposicion, descripcion: '15 minutos. Presentar diapositivas y demo si es posible'),
      Tarea(id: 'tar-10', titulo: 'Práctica: Reacciones químicas', materiaId: m6, fechaLimite: d(7), estado: EstadoTarea.pendiente, prioridad: PrioridadTarea.media, tipo: TipoActividad.laboratorio, descripcion: 'Práctica 5: Oxidación y reducción. Usar EPP completo'),
      Tarea(id: 'tar-11', titulo: 'Examen de Álgebra lineal', materiaId: m1, fechaLimite: d(10), estado: EstadoTarea.pendiente,  prioridad: PrioridadTarea.alta,  tipo: TipoActividad.examen,     descripcion: 'Temas: matrices, determinantes, vectores propios'),
      Tarea(id: 'tar-12', titulo: 'Redacción: My future plans', materiaId: m5, fechaLimite: d(12), estado: EstadoTarea.pendiente, prioridad: PrioridadTarea.baja, tipo: TipoActividad.tarea,      descripcion: '250 palabras mínimo. Future simple y going to'),
      Tarea(id: 'tar-13', titulo: 'Maqueta sistema solar',    materiaId: m3, fechaLimite: d(15), estado: EstadoTarea.pendiente,  prioridad: PrioridadTarea.media, tipo: TipoActividad.proyecto,   descripcion: 'Escala 1:1,000,000,000. Materiales reciclados'),
      Tarea(id: 'tar-14', titulo: 'Introducción a Flutter',   materiaId: m2, fechaLimite: d(-10), estado: EstadoTarea.entregada, prioridad: PrioridadTarea.media, tipo: TipoActividad.tarea,      descripcion: 'Widgets básicos y estructura de un proyecto', completadaEn: d(-10)),
      Tarea(id: 'tar-15', titulo: 'Quiz: Cinemática',         materiaId: m3, fechaLimite: d(-8), estado: EstadoTarea.entregada,  prioridad: PrioridadTarea.media, tipo: TipoActividad.quiz,       descripcion: 'Movimiento rectilíneo uniforme y uniformemente acelerado', completadaEn: d(-8)),
      Tarea(id: 'tar-16', titulo: 'Vocabulario Unit 3',       materiaId: m5, fechaLimite: d(-6), estado: EstadoTarea.entregada,  prioridad: PrioridadTarea.baja,  tipo: TipoActividad.tarea,      descripcion: '50 palabras con definición en inglés', completadaEn: d(-6)),
      Tarea(id: 'tar-17', titulo: 'Propiedades de la materia',materiaId: m6, fechaLimite: d(-4), estado: EstadoTarea.entregada,  prioridad: PrioridadTarea.baja,  tipo: TipoActividad.lectura,    descripcion: 'Capítulo 2 completo con resumen', completadaEn: d(-4)),
      Tarea(id: 'tar-18', titulo: '[Maestro] Examen diagnóstico', materiaId: m1, fechaLimite: d(1), estado: EstadoTarea.pendiente, prioridad: PrioridadTarea.alta, tipo: TipoActividad.examen, asignadoPorMaestro: true, grupoId: g1, descripcion: 'Evaluación diagnóstica de inicio de semestre'),
      Tarea(id: 'tar-19', titulo: '[Maestro] Proyecto integrador',materiaId: m2, fechaLimite: d(20), estado: EstadoTarea.pendiente, prioridad: PrioridadTarea.alta, tipo: TipoActividad.proyecto, asignadoPorMaestro: true, grupoId: g2, descripcion: 'Desarrollar sistema de gestión escolar'),
    ];

    _notas = [
      Nota(id: 'not-01', titulo: 'Fórmulas de derivadas', materiaId: m1, colorValue: 0xFFE3F2FD, contenido: 'd/dx(xⁿ) = n·xⁿ⁻¹\nd/dx(sin x) = cos x\nd/dx(cos x) = -sin x\nd/dx(eˣ) = eˣ\nd/dx(ln x) = 1/x'),
      Nota(id: 'not-02', titulo: 'Shortcuts de VS Code',  materiaId: m2, colorValue: 0xFFE8F5E9, contenido: 'Ctrl+Shift+P → Paleta de comandos\nCtrl+` → Terminal\nCtrl+D → Selección múltiple\nAlt+↑↓ → Mover línea\nCtrl+/ → Comentar'),
      Nota(id: 'not-03', titulo: 'Leyes de Newton',       materiaId: m3, colorValue: 0xFFFFF9C4, contenido: '1ª Ley: Un objeto en reposo permanece en reposo a menos que actúe una fuerza.\n2ª Ley: F = ma\n3ª Ley: Acción y reacción son iguales y opuestas'),
      Nota(id: 'not-04', titulo: 'Causas de la Revolución Francesa', materiaId: m4, colorValue: 0xFFFFEBEE, contenido: '• Crisis económica por guerras\n• Desigualdad social\n• Ideas ilustradas de Voltaire y Rousseau\n• Malas cosechas 1788'),
      Nota(id: 'not-05', titulo: 'Irregular verbs list',  materiaId: m5, colorValue: 0xFFF3E5F5, contenido: 'go → went → gone\nbuy → bought → bought\nrun → ran → run\ntake → took → taken\nwrite → wrote → written'),
      Nota(id: 'not-06', titulo: 'Configuración Flutter', materiaId: m2, colorValue: 0xFFE3F2FD, contenido: 'flutter pub get\nflutter run -d emulator-5554\nflutter build apk --release\nflutter doctor --verbose'),
      Nota(id: 'not-07', titulo: 'Primeros elementos',    materiaId: m6, colorValue: 0xFFE0F2F1, contenido: '1. H - Hidrógeno\n2. He - Helio\n3. Li - Litio\n4. Be - Berilio\n5. B - Boro\n6. C - Carbono\n7. N - Nitrógeno\n8. O - Oxígeno'),
      Nota(id: 'not-08', titulo: 'Regla del producto',    materiaId: m1, colorValue: 0xFFFFF9C4, contenido: 'Producto: (fg)\' = f\'g + fg\'\nCociente: (f/g)\' = (f\'g - fg\') / g²\nCadena: (f∘g)\' = f\'(g(x)) · g\'(x)'),
    ];

    _calificaciones = [
      Calificacion(id: 'cal-01', nombre: 'Primer Parcial',    nota: 8.5,  notaMaxima: 10, porcentaje: 30, materiaId: m1, fecha: d(-45)),
      Calificacion(id: 'cal-02', nombre: 'Quiz semana 3',     nota: 9.0,  notaMaxima: 10, porcentaje: 10, materiaId: m1, fecha: d(-30)),
      Calificacion(id: 'cal-03', nombre: 'Tarea integrales',  nota: 7.5,  notaMaxima: 10, porcentaje: 10, materiaId: m1, fecha: d(-15)),
      Calificacion(id: 'cal-04', nombre: 'Primer Parcial',    nota: 9.5,  notaMaxima: 10, porcentaje: 30, materiaId: m2, fecha: d(-40)),
      Calificacion(id: 'cal-05', nombre: 'Proyecto Flutter',  nota: 10.0, notaMaxima: 10, porcentaje: 20, materiaId: m2, fecha: d(-20)),
      Calificacion(id: 'cal-06', nombre: 'Quiz widgets',      nota: 8.0,  notaMaxima: 10, porcentaje: 10, materiaId: m2, fecha: d(-10)),
      Calificacion(id: 'cal-07', nombre: 'Laboratorio 1',     nota: 7.0,  notaMaxima: 10, porcentaje: 20, materiaId: m3, fecha: d(-35)),
      Calificacion(id: 'cal-08', nombre: 'Examen cinemática', nota: 8.5,  notaMaxima: 10, porcentaje: 30, materiaId: m3, fecha: d(-20)),
      Calificacion(id: 'cal-09', nombre: 'Primer Parcial',    nota: 7.5,  notaMaxima: 10, porcentaje: 30, materiaId: m4, fecha: d(-42)),
      Calificacion(id: 'cal-10', nombre: 'Ensayo',            nota: 8.0,  notaMaxima: 10, porcentaje: 15, materiaId: m4, fecha: d(-25)),
      Calificacion(id: 'cal-11', nombre: 'Speaking Unit 1-3', nota: 9.5,  notaMaxima: 10, porcentaje: 20, materiaId: m5, fecha: d(-30)),
      Calificacion(id: 'cal-12', nombre: 'Writing Test',      nota: 8.5,  notaMaxima: 10, porcentaje: 15, materiaId: m5, fecha: d(-15)),
      Calificacion(id: 'cal-13', nombre: 'Lab: Reacciones',   nota: 9.0,  notaMaxima: 10, porcentaje: 20, materiaId: m6, fecha: d(-28)),
      Calificacion(id: 'cal-14', nombre: 'Examen tabla periódica', nota: 8.0, notaMaxima: 10, porcentaje: 25, materiaId: m6, fecha: d(-12)),
    ];

    _grupos = [
      Grupo(id: g1, nombre: '6°A Matutino', colorValue: 0xFF6C63FF, descripcion: '32 alumnos - Turno matutino', alumnos: [
        AlumnoGrupo(id: 'alu-01', nombre: 'Ana',      apellido: 'García López',   colorValue: 0xFF6C63FF),
        AlumnoGrupo(id: 'alu-02', nombre: 'Carlos',   apellido: 'Martínez Ruiz',  colorValue: 0xFF2196F3),
        AlumnoGrupo(id: 'alu-03', nombre: 'Sofía',    apellido: 'Hernández Cruz', colorValue: 0xFFE91E63),
        AlumnoGrupo(id: 'alu-04', nombre: 'Diego',    apellido: 'López Sánchez',  colorValue: 0xFF4CAF50),
        AlumnoGrupo(id: 'alu-05', nombre: 'Valentina',apellido: 'Ramírez Flores', colorValue: 0xFFFF9800),
      ]),
      Grupo(id: g2, nombre: '6°B Vespertino', colorValue: 0xFF2196F3, descripcion: '28 alumnos - Turno vespertino', alumnos: [
        AlumnoGrupo(id: 'alu-13', nombre: 'Mariana',  apellido: 'Soto Navarro',   colorValue: 0xFFE91E63),
        AlumnoGrupo(id: 'alu-14', nombre: 'Fernando', apellido: 'Luna Estrada',   colorValue: 0xFF2196F3),
        AlumnoGrupo(id: 'alu-15', nombre: 'Daniela',  apellido: 'Ríos Aguilar',   colorValue: 0xFF4CAF50),
      ]),
      Grupo(id: g3, nombre: '7°A Avanzado', colorValue: 0xFF4CAF50, descripcion: '25 alumnos - Grupo avanzado', alumnos: [
        AlumnoGrupo(id: 'alu-23', nombre: 'Valeria',  apellido: 'Ángel Bravo',    colorValue: 0xFF4CAF50),
        AlumnoGrupo(id: 'alu-24', nombre: 'Rodrigo',  apellido: 'Serrano Lara',   colorValue: 0xFF6C63FF),
      ]),
    ];

    _anuncios = [
      Anuncio(id: 'ann-01', titulo: '🚨 Examen recuperativo este viernes', cuerpo: 'El examen de recuperación del primer parcial se realizará este viernes en el aula C-102. Traer calculadora científica.', grupoId: null, fecha: DateTime.now().subtract(const Duration(days: 1)), fijado: true),
      Anuncio(id: 'ann-02', titulo: 'Cambio de horario - Semana Santa', cuerpo: 'Durante la semana del 14 al 18 de abril no habrá clases presenciales. Las actividades se entregarán de forma virtual.', grupoId: null, fecha: DateTime.now().subtract(const Duration(days: 2)), fijado: true),
      Anuncio(id: 'ann-03', titulo: 'Material para laboratorio', cuerpo: 'Traer: bata, guantes, lentes de seguridad y cuaderno de laboratorio.', grupoId: g1, fecha: DateTime.now().subtract(const Duration(days: 3)), fijado: false),
    ];

    // Seed a few study dates so streak shows something
    final now = DateTime.now();
    for (int i = 3; i >= 0; i--) {
      _fechasEstudio.add(_isoDate(now.subtract(Duration(days: i))));
    }

    notifyListeners();
    await _guardar();
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('materias',       jsonEncode(_materias.map((m) => m.toJson()).toList()));
    await prefs.setString('tareas',         jsonEncode(_tareas.map((t) => t.toJson()).toList()));
    await prefs.setString('notas',          jsonEncode(_notas.map((n) => n.toJson()).toList()));
    await prefs.setString('calificaciones', jsonEncode(_calificaciones.map((c) => c.toJson()).toList()));
    await prefs.setString('grupos',         jsonEncode(_grupos.map((g) => g.toJson()).toList()));
    await prefs.setString('anuncios',       jsonEncode(_anuncios.map((a) => a.toJson()).toList()));
    await prefs.setBool('modoOscuro',       _modoOscuro);
    await prefs.setBool('esMaestro',        _esMaestro);
    await prefs.setBool('rolSeleccionado',  _rolSeleccionado);
    await prefs.setInt('pomodoroTrabajo',        _pomodoroTrabajo);
    await prefs.setInt('pomodoroDescansoCorto',  _pomodoroDescansoCorto);
    await prefs.setInt('pomodoroDescansoLargo',  _pomodoroDescansoLargo);
    await prefs.setStringList('fechasEstudio',   _fechasEstudio);
    await prefs.setString('pdfs', jsonEncode(_pdfs.map((p) => p.toJson()).toList()));
  }
}
