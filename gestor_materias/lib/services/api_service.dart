import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/materia.dart';
import '../models/tarea.dart';
import '../models/nota.dart';
import '../models/grupo.dart';
import '../models/estudio_pdf.dart';

// ─── Credenciales Supabase ─────────────────────────────────────
// Reemplaza estos valores con los de tu proyecto en supabase.com
// Settings → API → Project URL y anon/public key
const String supabaseUrl  = 'https://xzrdsfvjdbizunmtodxp.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6cmRzZnZqZGJpenVubXRvZHhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNzE2MTcsImV4cCI6MjA5MTg0NzYxN30.syqNYNfDCEIiXR2uOJn3EhcUVlMz0ZIcn7ga0RM4psI';

// ─── Helper para obtener el cliente ──────────────────────────
SupabaseClient get _db => Supabase.instance.client;

// ─── Manejo de errores ────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

Future<T> _run<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on PostgrestException catch (e) {
    throw ApiException('Supabase: ${e.message}');
  } catch (e) {
    throw ApiException('Sin conexión: $e');
  }
}

// ═══════════════════════════════════════════════════════════════
// MATERIAS
// ═══════════════════════════════════════════════════════════════
class MateriasApi {
  static Future<List<Materia>> getAll() => _run(() async {
        final rows = await _db.from('materias').select('data');
        return rows
            .map((r) => Materia.fromJson(r['data'] as Map<String, dynamic>))
            .toList();
      });

  static Future<void> crear(Materia m) => _run(() async {
        await _db.from('materias').upsert({'id': m.id, 'data': m.toJson()});
      });

  static Future<void> editar(Materia m) => _run(() async {
        await _db
            .from('materias')
            .update({'data': m.toJson()})
            .eq('id', m.id);
      });

  static Future<void> eliminar(String id) => _run(() async {
        await _db.from('materias').delete().eq('id', id);
      });
}

// ═══════════════════════════════════════════════════════════════
// TAREAS
// ═══════════════════════════════════════════════════════════════
class TareasApi {
  static Future<List<Tarea>> getAll() => _run(() async {
        final rows = await _db.from('tareas').select('data');
        return rows
            .map((r) => Tarea.fromJson(r['data'] as Map<String, dynamic>))
            .toList();
      });

  static Future<List<Tarea>> getDeGrupo(String grupoId) => _run(() async {
        // Filter server-side on the JSONB field
        final rows = await _db
            .from('tareas')
            .select('data')
            .eq('data->>grupoId', grupoId);
        return rows
            .map((r) => Tarea.fromJson(r['data'] as Map<String, dynamic>))
            .toList();
      });

  static Future<void> crear(Tarea t) => _run(() async {
        await _db.from('tareas').upsert({'id': t.id, 'data': t.toJson()});
      });

  static Future<void> editar(Tarea t) => _run(() async {
        await _db
            .from('tareas')
            .update({'data': t.toJson()})
            .eq('id', t.id);
      });

  static Future<void> cambiarEstado(String id, int estado) => _run(() async {
        // Fetch current data, update estado field, then write back
        final row = await _db
            .from('tareas')
            .select('data')
            .eq('id', id)
            .single();
        final data = Map<String, dynamic>.from(row['data'] as Map);
        data['estado'] = estado;
        await _db.from('tareas').update({'data': data}).eq('id', id);
      });

  static Future<void> eliminar(String id) => _run(() async {
        await _db.from('tareas').delete().eq('id', id);
      });
}

// ═══════════════════════════════════════════════════════════════
// NOTAS
// ═══════════════════════════════════════════════════════════════
class NotasApi {
  static Future<List<Nota>> getAll() => _run(() async {
        final rows = await _db.from('notas').select('data');
        return rows
            .map((r) => Nota.fromJson(r['data'] as Map<String, dynamic>))
            .toList();
      });

  static Future<void> crear(Nota n) => _run(() async {
        await _db.from('notas').upsert({'id': n.id, 'data': n.toJson()});
      });

  static Future<void> editar(Nota n) => _run(() async {
        await _db
            .from('notas')
            .update({'data': n.toJson()})
            .eq('id', n.id);
      });

  static Future<void> eliminar(String id) => _run(() async {
        await _db.from('notas').delete().eq('id', id);
      });
}

// ═══════════════════════════════════════════════════════════════
// CALIFICACIONES
// ═══════════════════════════════════════════════════════════════
class CalificacionesApi {
  static Future<List<Calificacion>> getAll() => _run(() async {
        final rows = await _db.from('calificaciones').select('data');
        return rows
            .map((r) => Calificacion.fromJson(r['data'] as Map<String, dynamic>))
            .toList();
      });

  static Future<void> crear(Calificacion c) => _run(() async {
        await _db
            .from('calificaciones')
            .upsert({'id': c.id, 'data': c.toJson()});
      });

  static Future<void> eliminar(String id) => _run(() async {
        await _db.from('calificaciones').delete().eq('id', id);
      });
}

// ═══════════════════════════════════════════════════════════════
// GRUPOS
// ═══════════════════════════════════════════════════════════════
class GruposApi {
  static Future<List<Grupo>> getAll() => _run(() async {
        final rows = await _db.from('grupos').select('data');
        return rows
            .map((r) => Grupo.fromJson(r['data'] as Map<String, dynamic>))
            .toList();
      });

  static Future<void> crear(Grupo g) => _run(() async {
        await _db.from('grupos').upsert({'id': g.id, 'data': g.toJson()});
      });

  static Future<void> editar(Grupo g) => _run(() async {
        await _db
            .from('grupos')
            .update({'data': g.toJson()})
            .eq('id', g.id);
      });

  static Future<void> eliminar(String id) => _run(() async {
        await _db.from('grupos').delete().eq('id', id);
      });
}

// ═══════════════════════════════════════════════════════════════
// ANUNCIOS
// ═══════════════════════════════════════════════════════════════
class AnunciosApi {
  static Future<List<Anuncio>> getAll() => _run(() async {
        final rows = await _db.from('anuncios').select('data');
        return rows
            .map((r) => Anuncio.fromJson(r['data'] as Map<String, dynamic>))
            .toList();
      });

  static Future<void> crear(Anuncio a) => _run(() async {
        await _db.from('anuncios').upsert({'id': a.id, 'data': a.toJson()});
      });

  static Future<void> editar(Anuncio a) => _run(() async {
        await _db
            .from('anuncios')
            .update({'data': a.toJson()})
            .eq('id', a.id);
      });

  static Future<void> toggleFijar(String id) => _run(() async {
        final row = await _db
            .from('anuncios')
            .select('data')
            .eq('id', id)
            .single();
        final data = Map<String, dynamic>.from(row['data'] as Map);
        data['fijado'] = !(data['fijado'] as bool? ?? false);
        await _db.from('anuncios').update({'data': data}).eq('id', id);
      });

  static Future<void> eliminar(String id) => _run(() async {
        await _db.from('anuncios').delete().eq('id', id);
      });
}

// ═══════════════════════════════════════════════════════════════
// PDFs STORAGE  (bucket: pdfs)
// ═══════════════════════════════════════════════════════════════
class PDFsStorageApi {
  static const _bucket = 'pdfs';

  /// Upload a local PDF file to Supabase Storage and return its public URL.
  /// [storagePath] e.g. "pdf-uuid.pdf"
  static Future<String> subirArchivo(String localPath, String storagePath) =>
      _run(() async {
        final file = File(localPath);
        await _db.storage.from(_bucket).upload(
              storagePath,
              file,
              fileOptions: const FileOptions(
                contentType: 'application/pdf',
                upsert: true,
              ),
            );
        return _db.storage.from(_bucket).getPublicUrl(storagePath);
      });

  /// Delete a file from storage by its storage path.
  static Future<void> eliminarArchivo(String storagePath) => _run(() async {
        await _db.storage.from(_bucket).remove([storagePath]);
      });

  /// Save PDF metadata to the `pdfs` table.
  static Future<void> guardarMetadata(EstudioPDF pdf) => _run(() async {
        await _db.from('pdfs').upsert({'id': pdf.id, 'data': pdf.toJson()});
      });

  /// Load all PDF metadata records from Supabase.
  static Future<List<EstudioPDF>> getAll() => _run(() async {
        final rows = await _db.from('pdfs').select('data');
        return rows
            .map((r) => EstudioPDF.fromJson(r['data'] as Map<String, dynamic>))
            .toList();
      });

  /// Delete PDF metadata from the `pdfs` table.
  static Future<void> eliminarMetadata(String id) => _run(() async {
        await _db.from('pdfs').delete().eq('id', id);
      });
}
