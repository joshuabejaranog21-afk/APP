class Nota {
  final String id;
  String titulo;
  String contenido;
  String materiaId;
  DateTime fechaCreacion;
  DateTime fechaModificacion;
  int colorValue;

  Nota({
    required this.id,
    required this.titulo,
    this.contenido = '',
    required this.materiaId,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    this.colorValue = 0xFFFFF9C4,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        fechaModificacion = fechaModificacion ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'contenido': contenido,
        'materiaId': materiaId,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaModificacion': fechaModificacion.toIso8601String(),
        'colorValue': colorValue,
      };

  factory Nota.fromJson(Map<String, dynamic> json) => Nota(
        id: json['id'],
        titulo: json['titulo'],
        contenido: json['contenido'] ?? '',
        materiaId: json['materiaId'],
        fechaCreacion: DateTime.parse(json['fechaCreacion']),
        fechaModificacion: DateTime.parse(json['fechaModificacion']),
        colorValue: json['colorValue'] ?? 0xFFFFF9C4,
      );
}

class Calificacion {
  final String id;
  String nombre;
  double nota;
  double notaMaxima;
  double porcentaje;
  String materiaId;
  DateTime fecha;

  Calificacion({
    required this.id,
    required this.nombre,
    required this.nota,
    this.notaMaxima = 10.0,
    required this.porcentaje,
    required this.materiaId,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  double get notaPonderada => (nota / notaMaxima) * porcentaje;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'nota': nota,
        'notaMaxima': notaMaxima,
        'porcentaje': porcentaje,
        'materiaId': materiaId,
        'fecha': fecha.toIso8601String(),
      };

  factory Calificacion.fromJson(Map<String, dynamic> json) => Calificacion(
        id: json['id'],
        nombre: json['nombre'],
        nota: (json['nota'] as num).toDouble(),
        notaMaxima: (json['notaMaxima'] as num?)?.toDouble() ?? 10.0,
        porcentaje: (json['porcentaje'] as num).toDouble(),
        materiaId: json['materiaId'],
        fecha: DateTime.parse(json['fecha']),
      );
}
