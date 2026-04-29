import 'dart:typed_data';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ── Nota/anotación por página ─────────────────────────────────
class NotaPDF {
  final String id;
  int pagina;
  String texto;
  String colorHex; // '#FFFF00', '#FF6B6B', '#90EE90', '#87CEEB'
  bool esResaltado; // false = nota de texto, true = resaltado
  DateTime fecha;

  NotaPDF({
    String? id,
    required this.pagina,
    required this.texto,
    this.colorHex = '#FFFF00',
    this.esResaltado = false,
    DateTime? fecha,
  })  : id = id ?? _uuid.v4(),
        fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'pagina': pagina,
        'texto': texto,
        'colorHex': colorHex,
        'esResaltado': esResaltado,
        'fecha': fecha.toIso8601String(),
      };

  factory NotaPDF.fromJson(Map<String, dynamic> j) => NotaPDF(
        id: j['id'],
        pagina: j['pagina'] ?? 0,
        texto: j['texto'] ?? '',
        colorHex: j['colorHex'] ?? '#FFFF00',
        esResaltado: j['esResaltado'] == true,
        fecha: j['fecha'] != null ? DateTime.tryParse(j['fecha']) ?? DateTime.now() : DateTime.now(),
      );
}

// ── Mensaje de chat con la IA ────────────────────────────────
class MensajeIA {
  final String rol; // 'user' | 'assistant'
  final String contenido;
  final DateTime fecha;

  const MensajeIA({
    required this.rol,
    required this.contenido,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'rol': rol,
        'contenido': contenido,
        'fecha': fecha.toIso8601String(),
      };

  factory MensajeIA.fromJson(Map<String, dynamic> j) => MensajeIA(
        rol: j['rol'] ?? 'user',
        contenido: j['contenido'] ?? '',
        fecha: DateTime.tryParse(j['fecha'] ?? '') ?? DateTime.now(),
      );
}

// ── Documento PDF de estudio ──────────────────────────────────
class EstudioPDF {
  final String id;
  String titulo;
  String rutaLocal; // absolute path on device
  String? materiaId;
  String? urlSupabase; // public URL in Supabase Storage
  List<NotaPDF> notas;
  List<MensajeIA> historialIA;
  DateTime fechaAgregado;
  int ultimaPagina;
  int totalPaginas;
  Uint8List? bytes; // web-only: in-memory PDF bytes (not persisted)

  EstudioPDF({
    String? id,
    required this.titulo,
    required this.rutaLocal,
    this.materiaId,
    this.urlSupabase,
    List<NotaPDF>? notas,
    List<MensajeIA>? historialIA,
    DateTime? fechaAgregado,
    this.ultimaPagina = 0,
    this.totalPaginas = 0,
    this.bytes,
  })  : id = id ?? _uuid.v4(),
        notas = notas ?? [],
        historialIA = historialIA ?? [],
        fechaAgregado = fechaAgregado ?? DateTime.now();

  List<NotaPDF> notasDePagina(int pagina) =>
      notas.where((n) => n.pagina == pagina).toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));

  String get resumenNotas {
    if (notas.isEmpty) return '';
    final buf = StringBuffer();
    final paginas = notas.map((n) => n.pagina).toSet().toList()..sort();
    for (final p in paginas) {
      final ns = notasDePagina(p);
      buf.writeln('--- Página ${p + 1} ---');
      for (final n in ns) {
        buf.writeln(n.texto);
      }
    }
    return buf.toString();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'rutaLocal': rutaLocal,
        'materiaId': materiaId,
        'urlSupabase': urlSupabase,
        'notas': notas.map((n) => n.toJson()).toList(),
        'historialIA': historialIA.map((m) => m.toJson()).toList(),
        'fechaAgregado': fechaAgregado.toIso8601String(),
        'ultimaPagina': ultimaPagina,
        'totalPaginas': totalPaginas,
      };

  factory EstudioPDF.fromJson(Map<String, dynamic> j) => EstudioPDF(
        id: j['id'],
        titulo: j['titulo'] ?? '',
        rutaLocal: j['rutaLocal'] ?? '',
        materiaId: j['materiaId'],
        urlSupabase: j['urlSupabase'],
        notas: (j['notas'] as List<dynamic>? ?? [])
            .map((n) => NotaPDF.fromJson(n as Map<String, dynamic>))
            .toList(),
        historialIA: (j['historialIA'] as List<dynamic>? ?? [])
            .map((m) => MensajeIA.fromJson(m as Map<String, dynamic>))
            .toList(),
        fechaAgregado: DateTime.tryParse(j['fechaAgregado'] ?? '') ?? DateTime.now(),
        ultimaPagina: j['ultimaPagina'] ?? 0,
        totalPaginas: j['totalPaginas'] ?? 0,
      );
}
