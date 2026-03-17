import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/materia.dart';
import '../models/tarea.dart';
import '../models/nota.dart';
import '../models/grupo.dart';

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
    try { return _materias.firstWhere((m) => m.id == id); } catch (_) { return null; }
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
  }

  Future<void> editarTarea(Tarea t) async {
    final i = _tareas.indexWhere((x) => x.id == t.id);
    if (i >= 0) {
      _tareas[i] = t;
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> cambiarEstadoTarea(String id, EstadoTarea estado) async {
    final i = _tareas.indexWhere((t) => t.id == id);
    if (i >= 0) {
      _tareas[i].estado = estado;
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> eliminarTarea(String id) async {
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

  // ─── Persistencia ──────────────────────────────────────────
  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    final mJson = prefs.getString('materias');
    if (mJson != null) {
      _materias = (jsonDecode(mJson) as List)
          .map((e) => Materia.fromJson(e))
          .toList();
    }

    final tJson = prefs.getString('tareas');
    if (tJson != null) {
      _tareas =
          (jsonDecode(tJson) as List).map((e) => Tarea.fromJson(e)).toList();
    }

    final nJson = prefs.getString('notas');
    if (nJson != null) {
      _notas =
          (jsonDecode(nJson) as List).map((e) => Nota.fromJson(e)).toList();
    }

    final cJson = prefs.getString('calificaciones');
    if (cJson != null) {
      _calificaciones = (jsonDecode(cJson) as List)
          .map((e) => Calificacion.fromJson(e))
          .toList();
    }

    final gJson = prefs.getString('grupos');
    if (gJson != null) {
      _grupos = (jsonDecode(gJson) as List)
          .map((e) => Grupo.fromJson(e))
          .toList();
    }

    final aJson = prefs.getString('anuncios');
    if (aJson != null) {
      _anuncios = (jsonDecode(aJson) as List)
          .map((e) => Anuncio.fromJson(e))
          .toList();
    }

    _modoOscuro = prefs.getBool('modoOscuro') ?? false;
    _esMaestro = prefs.getBool('esMaestro') ?? false;
    _rolSeleccionado = prefs.getBool('rolSeleccionado') ?? false;

    _cargando = false;
    notifyListeners();
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'materias', jsonEncode(_materias.map((m) => m.toJson()).toList()));
    await prefs.setString(
        'tareas', jsonEncode(_tareas.map((t) => t.toJson()).toList()));
    await prefs.setString(
        'notas', jsonEncode(_notas.map((n) => n.toJson()).toList()));
    await prefs.setString('calificaciones',
        jsonEncode(_calificaciones.map((c) => c.toJson()).toList()));
    await prefs.setString(
        'grupos', jsonEncode(_grupos.map((g) => g.toJson()).toList()));
    await prefs.setString(
        'anuncios', jsonEncode(_anuncios.map((a) => a.toJson()).toList()));
    await prefs.setBool('modoOscuro', _modoOscuro);
    await prefs.setBool('esMaestro', _esMaestro);
    await prefs.setBool('rolSeleccionado', _rolSeleccionado);
  }
}
