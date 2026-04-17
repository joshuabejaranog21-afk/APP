import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-haiku-4-5-20251001';

  // ── Preguntar sobre el PDF ────────────────────────────────────
  static Future<String> preguntarSobrePDF({
    required String apiKey,
    required String contextoPDF,    // notes / pasted text from the PDF
    required String pregunta,
    List<Map<String, String>> historial = const [],
  }) async {
    if (apiKey.isEmpty) {
      return '⚠️ Agrega tu API key de Anthropic en Configuración → AI.';
    }

    final systemPrompt = '''Eres un asistente de estudio universitario.
Tienes acceso al siguiente contenido extraído de un documento PDF que el estudiante está leyendo:

--- CONTENIDO DEL DOCUMENTO ---
$contextoPDF
--- FIN DEL CONTENIDO ---

Responde de forma concisa y clara. Si el estudiante pregunta en español, responde en español.
Si pide traducción, traduce. Si pide explicación, explica usando el contenido como base.
Si la pregunta no está relacionada con el documento, igual ayuda al estudiante.''';

    final messages = <Map<String, dynamic>>[];
    for (final msg in historial) {
      messages.add({'role': msg['rol'], 'content': msg['contenido']});
    }
    messages.add({'role': 'user', 'content': pregunta});

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': messages,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>;
        return content.first['text'] as String? ?? 'Sin respuesta.';
      } else if (response.statusCode == 401) {
        return '⚠️ API key inválida. Verifica tu clave de Anthropic.';
      } else {
        final err = jsonDecode(response.body);
        return '⚠️ Error ${response.statusCode}: ${err['error']?['message'] ?? response.body}';
      }
    } catch (e) {
      return '⚠️ Sin conexión o tiempo agotado: $e';
    }
  }

  // ── Traducir texto ────────────────────────────────────────────
  static Future<String> traducir({
    required String apiKey,
    required String texto,
    required String idiomaDestino,
  }) async {
    return preguntarSobrePDF(
      apiKey: apiKey,
      contextoPDF: texto,
      pregunta: 'Traduce el siguiente texto al $idiomaDestino de forma fiel y natural:\n\n$texto',
    );
  }

  // ── Resumir texto ────────────────────────────────────────────
  static Future<String> resumir({
    required String apiKey,
    required String texto,
  }) async {
    return preguntarSobrePDF(
      apiKey: apiKey,
      contextoPDF: texto,
      pregunta: 'Haz un resumen claro y estructurado del siguiente contenido, destacando los puntos clave:\n\n$texto',
    );
  }
}
