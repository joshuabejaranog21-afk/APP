class AlumnoGrupo {
  final String id;
  String nombre;
  String apellido;
  int colorValue;

  AlumnoGrupo({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.colorValue,
  });

  String get nombreCompleto => '$nombre $apellido';
  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0] : '';
    final a = apellido.isNotEmpty ? apellido[0] : '';
    return '$n$a'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'apellido': apellido,
        'colorValue': colorValue,
      };

  factory AlumnoGrupo.fromJson(Map<String, dynamic> json) => AlumnoGrupo(
        id: json['id'],
        nombre: json['nombre'],
        apellido: json['apellido'] ?? '',
        colorValue: json['colorValue'],
      );
}

class Grupo {
  final String id;
  String nombre;
  int colorValue;
  String descripcion;
  List<AlumnoGrupo> alumnos;

  Grupo({
    required this.id,
    required this.nombre,
    required this.colorValue,
    this.descripcion = '',
    this.alumnos = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'colorValue': colorValue,
        'descripcion': descripcion,
        'alumnos': alumnos.map((a) => a.toJson()).toList(),
      };

  factory Grupo.fromJson(Map<String, dynamic> json) => Grupo(
        id: json['id'],
        nombre: json['nombre'],
        colorValue: json['colorValue'],
        descripcion: json['descripcion'] ?? '',
        alumnos: (json['alumnos'] as List<dynamic>? ?? [])
            .map((a) => AlumnoGrupo.fromJson(a))
            .toList(),
      );
}

class Anuncio {
  final String id;
  String titulo;
  String cuerpo;
  String? grupoId; // null = todos
  DateTime fecha;
  bool fijado;

  Anuncio({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    this.grupoId,
    required this.fecha,
    this.fijado = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'cuerpo': cuerpo,
        'grupoId': grupoId,
        'fecha': fecha.toIso8601String(),
        'fijado': fijado,
      };

  factory Anuncio.fromJson(Map<String, dynamic> json) => Anuncio(
        id: json['id'],
        titulo: json['titulo'],
        cuerpo: json['cuerpo'],
        grupoId: json['grupoId'],
        fecha: DateTime.parse(json['fecha']),
        fijado: json['fijado'] ?? false,
      );
}
