class Grupo {
  final String id;
  String nombre;
  int colorValue;
  String descripcion;

  Grupo({
    required this.id,
    required this.nombre,
    required this.colorValue,
    this.descripcion = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'colorValue': colorValue,
        'descripcion': descripcion,
      };

  factory Grupo.fromJson(Map<String, dynamic> json) => Grupo(
        id: json['id'],
        nombre: json['nombre'],
        colorValue: json['colorValue'],
        descripcion: json['descripcion'] ?? '',
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
