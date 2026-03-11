class Materia {
  final String id;
  String nombre;
  String profesor;
  String aula;
  int colorValue;
  List<HorarioClase> horarios;
  String icono;
  double? notaObjetivo;

  Materia({
    required this.id,
    required this.nombre,
    this.profesor = '',
    this.aula = '',
    required this.colorValue,
    this.horarios = const [],
    this.icono = 'book',
    this.notaObjetivo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'profesor': profesor,
        'aula': aula,
        'colorValue': colorValue,
        'horarios': horarios.map((h) => h.toJson()).toList(),
        'icono': icono,
        'notaObjetivo': notaObjetivo,
      };

  factory Materia.fromJson(Map<String, dynamic> json) => Materia(
        id: json['id'],
        nombre: json['nombre'],
        profesor: json['profesor'] ?? '',
        aula: json['aula'] ?? '',
        colorValue: json['colorValue'],
        horarios: (json['horarios'] as List<dynamic>? ?? [])
            .map((h) => HorarioClase.fromJson(h))
            .toList(),
        icono: json['icono'] ?? 'book',
        notaObjetivo: json['notaObjetivo']?.toDouble(),
      );
}

class HorarioClase {
  int diaSemana; // 1=Lunes ... 7=Domingo
  String horaInicio; // "08:00"
  String horaFin;   // "09:30"

  HorarioClase({
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });

  Map<String, dynamic> toJson() => {
        'diaSemana': diaSemana,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
      };

  factory HorarioClase.fromJson(Map<String, dynamic> json) => HorarioClase(
        diaSemana: json['diaSemana'],
        horaInicio: json['horaInicio'],
        horaFin: json['horaFin'],
      );

  String get diaLabel {
    const dias = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[diaSemana];
  }
}
