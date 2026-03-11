enum EstadoTarea { pendiente, enProgreso, entregada }

enum PrioridadTarea { baja, media, alta }

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
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  int get diasRestantes {
    final hoy = DateTime.now();
    final diff = fechaLimite.difference(DateTime(hoy.year, hoy.month, hoy.day));
    return diff.inDays;
  }

  bool get estaVencida =>
      diasRestantes < 0 && estado != EstadoTarea.entregada;

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
        fechaCreacion: DateTime.parse(json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
        notificado: json['notificado'] ?? false,
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
