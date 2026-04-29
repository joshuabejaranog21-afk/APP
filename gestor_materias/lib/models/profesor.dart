import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Profesor {
  final String id;
  String nombre;
  String email;
  String especialidad;

  Profesor({
    String? id,
    required this.nombre,
    this.email = '',
    this.especialidad = '',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'especialidad': especialidad,
      };

  factory Profesor.fromJson(Map<String, dynamic> j) => Profesor(
        id: j['id'],
        nombre: j['nombre'] ?? '',
        email: j['email'] ?? '',
        especialidad: j['especialidad'] ?? '',
      );
}
