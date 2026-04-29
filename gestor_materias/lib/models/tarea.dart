enum EstadoTarea { pendiente, enProgreso, entregada }

class EntregaTarea {
  final String texto;
  final List<String> archivos;
  final DateTime fecha;
  double? calificacion;       // 0.0 – 10.0, null = sin calificar
  String retroalimentacion;
  DateTime? fechaCalificacion;

  EntregaTarea({
    this.texto = '',
    List<String>? archivos,
    DateTime? fecha,
    this.calificacion,
    this.retroalimentacion = '',
    this.fechaCalificacion,
  })  : archivos = archivos ?? [],
        fecha = fecha ?? DateTime.now();

  bool get calificada => calificacion != null;

  Map<String, dynamic> toJson() => {
        'texto': texto,
        'archivos': archivos,
        'fecha': fecha.toIso8601String(),
        'calificacion': calificacion,
        'retroalimentacion': retroalimentacion,
        'fechaCalificacion': fechaCalificacion?.toIso8601String(),
      };

  factory EntregaTarea.fromJson(Map<String, dynamic> j) => EntregaTarea(
        texto: j['texto'] ?? '',
        archivos: List<String>.from(j['archivos'] ?? []),
        fecha: DateTime.tryParse(j['fecha'] ?? '') ?? DateTime.now(),
        calificacion: (j['calificacion'] as num?)?.toDouble(),
        retroalimentacion: j['retroalimentacion'] ?? '',
        fechaCalificacion: j['fechaCalificacion'] != null
            ? DateTime.tryParse(j['fechaCalificacion'])
            : null,
      );
}

enum PrioridadTarea { baja, media, alta }

class SubtareaItem {
  String titulo;
  bool completada;

  SubtareaItem({required this.titulo, this.completada = false});

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'completada': completada,
      };

  factory SubtareaItem.fromJson(Map<String, dynamic> json) => SubtareaItem(
        titulo: json['titulo'] ?? '',
        completada: json['completada'] == true,
      );
}

class Tarea {
  final String id;
  String titulo;
  String descripcion;
  String materiaId;
  DateTime fechaLimite;
  EstadoTarea estado;
  PrioridadTarea prioridad;
  TipoActividad tipo;
  DateTime fechaCreacion;
  bool notificado;
  bool asignadoPorMaestro;
  String? grupoId;
  List<SubtareaItem> subtareas;
  bool esRecurrente;
  DateTime? completadaEn;
  EntregaTarea? entrega;

  Tarea({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    required this.materiaId,
    required this.fechaLimite,
    this.estado = EstadoTarea.pendiente,
    this.prioridad = PrioridadTarea.media,
    this.tipo = TipoActividad.tarea,
    DateTime? fechaCreacion,
    this.notificado = false,
    this.asignadoPorMaestro = false,
    this.grupoId,
    List<SubtareaItem>? subtareas,
    this.esRecurrente = false,
    this.completadaEn,
    this.entrega,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        subtareas = subtareas ?? [];

  int get diasRestantes {
    final hoy = DateTime.now();
    final diff = fechaLimite.difference(DateTime(hoy.year, hoy.month, hoy.day));
    return diff.inDays;
  }

  bool get estaVencida =>
      diasRestantes < 0 && estado != EstadoTarea.entregada;

  int get subtareasCompletadasCount =>
      subtareas.where((s) => s.completada).length;

  double get progresoSubtareas =>
      subtareas.isEmpty ? 0.0 : subtareasCompletadasCount / subtareas.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'materiaId': materiaId,
        'fechaLimite': fechaLimite.toIso8601String(),
        'estado': estado.index,
        'prioridad': prioridad.index,
        'tipo': tipo.index,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'notificado': notificado,
        'asignadoPorMaestro': asignadoPorMaestro,
        'grupoId': grupoId,
        'subtareas': subtareas.map((s) => s.toJson()).toList(),
        'esRecurrente': esRecurrente,
        'completadaEn': completadaEn?.toIso8601String(),
        'entrega': entrega?.toJson(),
      };

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
        id: json['id'],
        titulo: json['titulo'],
        descripcion: json['descripcion'] ?? '',
        materiaId: json['materiaId'],
        fechaLimite: DateTime.parse(json['fechaLimite']),
        estado: EstadoTarea.values[json['estado'] ?? 0],
        prioridad: PrioridadTarea.values[json['prioridad'] ?? 1],
        tipo: TipoActividad.values[json['tipo'] ?? 0],
        fechaCreacion: DateTime.parse(
            json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
        notificado: json['notificado'] == true,
        asignadoPorMaestro: json['asignadoPorMaestro'] == true,
        grupoId: json['grupoId'] as String?,
        subtareas: (json['subtareas'] as List<dynamic>? ?? [])
            .map((s) => SubtareaItem.fromJson(s as Map<String, dynamic>))
            .toList(),
        esRecurrente: json['esRecurrente'] == true,
        completadaEn: json['completadaEn'] != null
            ? DateTime.tryParse(json['completadaEn'])
            : null,
        entrega: json['entrega'] != null
            ? EntregaTarea.fromJson(json['entrega'] as Map<String, dynamic>)
            : null,
      );
}

enum TipoActividad {
  tarea,
  examen,
  quiz,
  proyecto,
  exposicion,
  laboratorio,
  lectura,
  otro,
}

extension TipoActividadExt on TipoActividad {
  String get label {
    const labels = [
      'Tarea',
      'Examen',
      'Quiz',
      'Proyecto',
      'Exposición',
      'Laboratorio',
      'Lectura',
      'Otro',
    ];
    return labels[index];
  }

  String get emoji {
    const emojis = ['📝', '📋', '✏️', '🗂️', '🎤', '🔬', '📖', '📌'];
    return emojis[index];
  }
}
