import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import '../../models/estudio_pdf.dart';
import '../../providers/app_provider.dart';
import '../../services/claude_service.dart';

class PDFViewerScreen extends StatefulWidget {
  final EstudioPDF pdf;
  const PDFViewerScreen({super.key, required this.pdf});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late EstudioPDF _pdf;
  final PdfViewerController _pdfController = PdfViewerController();
  int _paginaActual = 0; // 0-indexed internally para compatibilidad con notas
  int _totalPaginas = 0;

  // Texto seleccionado actualmente (para resaltar / leer / preguntar IA)
  String _textoSeleccionado = '';

  // TTS
  final FlutterTts _tts = FlutterTts();
  bool _leyendo = false;
  String _textoTTS = '';

  // Pomodoro mini
  bool _pomodoroVisible = false;
  int _pomodoroSegundos = 25 * 60;
  bool _pomodoroActivo = false;
  Timer? _pomodoroTimer;

  // AI chat
  bool _aiVisible = false;
  final _aiCtrl = TextEditingController();
  final _aiScrollCtrl = ScrollController();
  bool _aiCargando = false;
  List<MensajeIA> _mensajes = [];

  @override
  void initState() {
    super.initState();
    _pdf = widget.pdf;
    _paginaActual = _pdf.ultimaPagina;
    _mensajes = List.from(_pdf.historialIA);
    _initTTS();
    final provider = context.read<AppProvider>();
    _pomodoroSegundos = provider.pomodoroTrabajo * 60;
  }

  void _initTTS() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() => setState(() => _leyendo = false));
  }

  @override
  void dispose() {
    _tts.stop();
    _pomodoroTimer?.cancel();
    _aiCtrl.dispose();
    _aiScrollCtrl.dispose();
    _guardarProgreso();
    super.dispose();
  }

  void _guardarProgreso() {
    _pdf.ultimaPagina = _paginaActual;
    _pdf.totalPaginas = _totalPaginas;
    _pdf.historialIA = _mensajes;
    context.read<AppProvider>().actualizarPDF(_pdf);
  }

  // ── TTS ───────────────────────────────────────────────────────
  void _toggleTTS() async {
    if (_leyendo) {
      await _tts.stop();
      setState(() => _leyendo = false);
      return;
    }
    // Si hay texto seleccionado, léelo; si no, usa las notas de la página
    if (_textoSeleccionado.trim().isNotEmpty) {
      _textoTTS = _textoSeleccionado;
    } else {
      final notas = _pdf.notasDePagina(_paginaActual);
      if (notas.isEmpty) {
        _textoTTS = 'Selecciona texto en el PDF o agrega notas en esta página para escucharlas.';
      } else {
        _textoTTS = notas.map((n) => n.texto).join('. ');
      }
    }
    setState(() => _leyendo = true);
    await _tts.speak(_textoTTS);
  }

  void _leerTextoPersonalizado(String texto) async {
    await _tts.stop();
    setState(() => _leyendo = true);
    _textoTTS = texto;
    await _tts.speak(texto);
  }

  // ── Resaltar / guardar selección como nota ────────────────────
  void _resaltarSeleccion({bool comoResaltado = true}) {
    final texto = _textoSeleccionado.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona texto en el PDF primero')),
      );
      return;
    }
    final nota = NotaPDF(
      pagina: _paginaActual,
      texto: texto,
      colorHex: '#FFFF00',
      esResaltado: comoResaltado,
    );
    setState(() => _pdf.notas.add(nota));
    _guardarProgreso();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(comoResaltado ? 'Resaltado guardado' : 'Nota guardada')),
    );
  }

  // ── Pomodoro ──────────────────────────────────────────────────
  void _togglePomodoro() {
    setState(() {
      if (_pomodoroActivo) {
        _pomodoroTimer?.cancel();
        _pomodoroActivo = false;
      } else {
        _pomodoroActivo = true;
        _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            if (_pomodoroSegundos > 0) {
              _pomodoroSegundos--;
            } else {
              _pomodoroTimer?.cancel();
              _pomodoroActivo = false;
              _pomodoroSegundos = context.read<AppProvider>().pomodoroTrabajo * 60;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Sesión de estudio completada! Tómate un descanso.')),
              );
            }
          });
        });
      }
    });
  }

  void _resetPomodoro() {
    _pomodoroTimer?.cancel();
    setState(() {
      _pomodoroActivo = false;
      _pomodoroSegundos = context.read<AppProvider>().pomodoroTrabajo * 60;
    });
  }

  String _formatPomodoro() {
    final m = _pomodoroSegundos ~/ 60;
    final s = _pomodoroSegundos % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── AI ────────────────────────────────────────────────────────
  Future<void> _enviarPregunta() async {
    final pregunta = _aiCtrl.text.trim();
    if (pregunta.isEmpty) return;
    _aiCtrl.clear();

    final provider = context.read<AppProvider>();
    final apiKey = provider.claudeApiKey;

    final userMsg = MensajeIA(rol: 'user', contenido: pregunta, fecha: DateTime.now());
    setState(() {
      _mensajes.add(userMsg);
      _aiCargando = true;
    });
    _scrollAI();

    final contextoBase = _pdf.resumenNotas.isNotEmpty
        ? _pdf.resumenNotas
        : 'El estudiante está leyendo "${_pdf.titulo}", página ${_paginaActual + 1} de $_totalPaginas.';
    final contexto = _textoSeleccionado.trim().isNotEmpty
        ? '$contextoBase\n\nTexto seleccionado por el estudiante en esta página:\n"${_textoSeleccionado.trim()}"'
        : contextoBase;

    final respuesta = await ClaudeService.preguntarSobrePDF(
      apiKey: apiKey,
      contextoPDF: contexto,
      pregunta: pregunta,
      historial: _mensajes
          .where((m) => m.rol == 'user' || m.rol == 'assistant')
          .take(10)
          .map((m) => {'rol': m.rol, 'contenido': m.contenido})
          .toList(),
    );

    final botMsg = MensajeIA(rol: 'assistant', contenido: respuesta, fecha: DateTime.now());
    setState(() {
      _mensajes.add(botMsg);
      _aiCargando = false;
    });
    _scrollAI();
    _guardarProgreso();
  }

  void _scrollAI() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_aiScrollCtrl.hasClients) {
        _aiScrollCtrl.animateTo(
          _aiScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final notasPagina = _pdf.notasDePagina(_paginaActual);
    final tieneSeleccion = _textoSeleccionado.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(_pdf.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (_totalPaginas > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text('${_paginaActual + 1}/$_totalPaginas',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── PDF Viewer ────────────────────────────────────────
          Positioned.fill(
            bottom: 72,
            child: kIsWeb && _pdf.bytes != null
                ? PdfViewer.data(
                    _pdf.bytes!,
                    controller: _pdfController,
                    initialPageNumber: _paginaActual + 1,
                    sourceName: _pdf.titulo,
                    params: PdfViewerParams(
                      enableTextSelection: true,
                      onDocumentChanged: (doc) {
                        if (doc != null) setState(() => _totalPaginas = doc.pages.length);
                      },
                      onPageChanged: (pageNumber) {
                        if (pageNumber == null) return;
                        setState(() => _paginaActual = pageNumber - 1);
                      },
                      onTextSelectionChange: (selections) {
                        final buf = StringBuffer();
                        for (final s in selections) { buf.write(s.text); buf.write(' '); }
                        setState(() => _textoSeleccionado = buf.toString().trim());
                      },
                    ),
                  )
                : PdfViewer.file(
              _pdf.rutaLocal,
              controller: _pdfController,
              initialPageNumber: _paginaActual + 1, // pdfrx es 1-indexed
              params: PdfViewerParams(
                enableTextSelection: true,
                onDocumentChanged: (doc) {
                  if (doc != null) {
                    setState(() => _totalPaginas = doc.pages.length);
                  }
                },
                onPageChanged: (pageNumber) {
                  if (pageNumber == null) return;
                  setState(() => _paginaActual = pageNumber - 1);
                },
                onTextSelectionChange: (selections) {
                  final buf = StringBuffer();
                  for (final s in selections) {
                    buf.write(s.text);
                    buf.write(' ');
                  }
                  final nuevo = buf.toString().trim();
                  if (nuevo != _textoSeleccionado) {
                    setState(() => _textoSeleccionado = nuevo);
                  }
                },
                loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
                  return const Center(child: CircularProgressIndicator());
                },
                errorBannerBuilder: (context, error, stackTrace, documentRef) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Error al cargar PDF: $error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Barra contextual de selección ─────────────────────
          if (tieneSeleccion)
            Positioned(
              top: 12, left: 12, right: 12,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(children: [
                    const Icon(Icons.format_quote, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _textoSeleccionado,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copiar',
                      icon: const Icon(Icons.copy, color: Colors.white, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _textoSeleccionado));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copiado')),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Resaltar',
                      icon: const Icon(Icons.highlight, color: Colors.white, size: 18),
                      onPressed: () => _resaltarSeleccion(comoResaltado: true),
                    ),
                    IconButton(
                      tooltip: 'Guardar como nota',
                      icon: const Icon(Icons.sticky_note_2, color: Colors.white, size: 18),
                      onPressed: () => _resaltarSeleccion(comoResaltado: false),
                    ),
                  ]),
                ),
              ),
            ),

          // ── Indicador de notas en página ──────────────────────
          if (notasPagina.isNotEmpty && !tieneSeleccion)
            Positioned(
              top: 12, right: 12,
              child: GestureDetector(
                onTap: () => _mostrarPanelNotas(context, provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.sticky_note_2, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('${notasPagina.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),

          // ── Pomodoro flotante ─────────────────────────────────
          if (_pomodoroVisible)
            Positioned(
              top: tieneSeleccion ? 60 : 12,
              left: 12,
              child: _PomodoroWidget(
                tiempo: _formatPomodoro(),
                activo: _pomodoroActivo,
                onToggle: _togglePomodoro,
                onReset: _resetPomodoro,
                onClose: () => setState(() => _pomodoroVisible = false),
                progreso: 1 - (_pomodoroSegundos / (provider.pomodoroTrabajo * 60)),
              ),
            ),

          // ── Panel IA ──────────────────────────────────────────
          if (_aiVisible)
            Positioned(
              left: 0, right: 0, bottom: 72,
              child: _AIPanel(
                mensajes: _mensajes,
                cargando: _aiCargando,
                ctrl: _aiCtrl,
                scrollCtrl: _aiScrollCtrl,
                apiKey: provider.claudeApiKey,
                textoSeleccionado: _textoSeleccionado,
                onEnviar: _enviarPregunta,
                onClose: () => setState(() => _aiVisible = false),
                onConfigApiKey: () => _mostrarDialogoApiKey(context, provider),
                onLeer: (texto) {
                  setState(() => _aiVisible = false);
                  _leerTextoPersonalizado(texto);
                },
              ),
            ),

          // ── Bottom toolbar ────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomToolbar(
              leyendo: _leyendo,
              pomodoroVisible: _pomodoroVisible,
              aiVisible: _aiVisible,
              notasCount: notasPagina.length,
              onTTS: _toggleTTS,
              onNotas: () => _mostrarPanelNotas(context, provider),
              onPomodoro: () => setState(() => _pomodoroVisible = !_pomodoroVisible),
              onAI: () => setState(() {
                _aiVisible = !_aiVisible;
                if (_aiVisible) _scrollAI();
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Panel de notas ────────────────────────────────────────────
  void _mostrarPanelNotas(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _NotasPanel(
        pdf: _pdf,
        pagina: _paginaActual,
        provider: provider,
        onNotaGuardada: () {
          setState(() {});
          _guardarProgreso();
        },
        onLeer: (texto) {
          Navigator.pop(ctx);
          _leerTextoPersonalizado(texto);
        },
      ),
    );
  }

  void _mostrarDialogoApiKey(BuildContext context, AppProvider provider) {
    final ctrl = TextEditingController(text: provider.claudeApiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API Key de Claude'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'sk-ant-...',
            border: OutlineInputBorder(),
            helperText: 'Consíguela en console.anthropic.com',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              provider.setClaudeApiKey(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// ── Bottom toolbar ────────────────────────────────────────────
class _BottomToolbar extends StatelessWidget {
  final bool leyendo, pomodoroVisible, aiVisible;
  final int notasCount;
  final VoidCallback onTTS, onNotas, onPomodoro, onAI;

  const _BottomToolbar({
    required this.leyendo,
    required this.pomodoroVisible,
    required this.aiVisible,
    required this.notasCount,
    required this.onTTS,
    required this.onNotas,
    required this.onPomodoro,
    required this.onAI,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolBtn(
            icon: leyendo ? Icons.stop_circle : Icons.volume_up_outlined,
            label: leyendo ? 'Parar' : 'Escuchar',
            color: leyendo ? Colors.red : null,
            onTap: onTTS,
          ),
          _ToolBtn(
            icon: Icons.sticky_note_2_outlined,
            label: 'Notas${notasCount > 0 ? ' ($notasCount)' : ''}',
            color: notasCount > 0 ? theme.colorScheme.primary : null,
            onTap: onNotas,
          ),
          _ToolBtn(
            icon: Icons.timer_outlined,
            label: 'Pomodoro',
            color: pomodoroVisible ? Colors.deepOrange : null,
            onTap: onPomodoro,
          ),
          _ToolBtn(
            icon: Icons.auto_awesome_outlined,
            label: 'Preguntar IA',
            color: aiVisible ? Colors.purple : null,
            onTap: onAI,
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 9, color: c, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ── Pomodoro widget flotante ──────────────────────────────────
class _PomodoroWidget extends StatelessWidget {
  final String tiempo;
  final bool activo;
  final double progreso;
  final VoidCallback onToggle, onReset, onClose;
  const _PomodoroWidget({
    required this.tiempo, required this.activo, required this.progreso,
    required this.onToggle, required this.onReset, required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🍅', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(tiempo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(width: 4),
          InkWell(onTap: onClose, child: const Icon(Icons.close, color: Colors.white70, size: 14)),
        ]),
        const SizedBox(height: 6),
        SizedBox(
          width: 120,
          child: LinearProgressIndicator(
            value: progreso.clamp(0.0, 1.0),
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _PomBtn(icon: activo ? Icons.pause : Icons.play_arrow, onTap: onToggle),
          const SizedBox(width: 8),
          _PomBtn(icon: Icons.replay, onTap: onReset),
        ]),
      ]),
    );
  }
}

class _PomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PomBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );
}

// ── Panel IA ──────────────────────────────────────────────────
class _AIPanel extends StatelessWidget {
  final List<MensajeIA> mensajes;
  final bool cargando;
  final TextEditingController ctrl;
  final ScrollController scrollCtrl;
  final String apiKey;
  final String textoSeleccionado;
  final VoidCallback onEnviar, onClose, onConfigApiKey;
  final void Function(String) onLeer;

  const _AIPanel({
    required this.mensajes, required this.cargando, required this.ctrl,
    required this.scrollCtrl, required this.apiKey,
    required this.textoSeleccionado,
    required this.onEnviar, required this.onClose, required this.onConfigApiKey,
    required this.onLeer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, -3))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            const Icon(Icons.auto_awesome, size: 18, color: Colors.purple),
            const SizedBox(width: 6),
            const Text('Asistente IA', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            if (apiKey.isEmpty)
              TextButton.icon(
                onPressed: onConfigApiKey,
                icon: const Icon(Icons.key, size: 14),
                label: const Text('Configurar', style: TextStyle(fontSize: 12)),
              ),
            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose),
          ]),
        ),
        // Chip con texto seleccionado
        if (textoSeleccionado.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.format_quote, size: 12, color: Colors.purple),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    textoSeleccionado,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.purple, fontStyle: FontStyle.italic),
                  ),
                ),
              ]),
            ),
          ),
        // Mensajes
        Expanded(
          child: mensajes.isEmpty
              ? Center(
                  child: Text('Haz una pregunta sobre el documento.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                )
              : ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: mensajes.length + (cargando ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == mensajes.length) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(children: [SizedBox(width: 8), CircularProgressIndicator(strokeWidth: 2)]),
                      );
                    }
                    final msg = mensajes[i];
                    final esUser = msg.rol == 'user';
                    return Align(
                      alignment: esUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () => onLeer(msg.contenido),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: esUser
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg.contenido,
                              style: TextStyle(
                                fontSize: 12,
                                color: esUser ? Colors.white : theme.colorScheme.onSurface,
                              )),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Input
        Padding(
          padding: EdgeInsets.only(
            left: 12, right: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 8, top: 6),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                minLines: 1, maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onEnviar(),
                decoration: InputDecoration(
                  hintText: 'Pregunta, traduce, resume...',
                  hintStyle: const TextStyle(fontSize: 12),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              onPressed: cargando ? null : onEnviar,
              icon: cargando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send, size: 18),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Panel de notas ────────────────────────────────────────────
class _NotasPanel extends StatefulWidget {
  final EstudioPDF pdf;
  final int pagina;
  final AppProvider provider;
  final VoidCallback onNotaGuardada;
  final void Function(String) onLeer;

  const _NotasPanel({
    required this.pdf, required this.pagina, required this.provider,
    required this.onNotaGuardada, required this.onLeer,
  });

  @override
  State<_NotasPanel> createState() => _NotasPanelState();
}

class _NotasPanelState extends State<_NotasPanel> {
  final _ctrl = TextEditingController();
  String _colorSeleccionado = '#FFFF00';
  bool _esResaltado = false;

  static const _colores = {
    '#FFFF00': Color(0xFFFFFF00),
    '#FF6B6B': Color(0xFFFF6B6B),
    '#90EE90': Color(0xFF90EE90),
    '#87CEEB': Color(0xFF87CEEB),
    '#FFB347': Color(0xFFFFB347),
    '#DDA0DD': Color(0xFFDDA0DD),
  };

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _agregar() {
    if (_ctrl.text.trim().isEmpty) return;
    final nota = NotaPDF(
      pagina: widget.pagina,
      texto: _ctrl.text.trim(),
      colorHex: _colorSeleccionado,
      esResaltado: _esResaltado,
    );
    widget.pdf.notas.add(nota);
    _ctrl.clear();
    widget.onNotaGuardada();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notas = widget.pdf.notasDePagina(widget.pagina);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Column(children: [
        // Handle
        Center(child: Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Icon(Icons.sticky_note_2_outlined, size: 18),
            const SizedBox(width: 6),
            Text('Notas — Página ${widget.pagina + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const Spacer(),
            if (notas.isNotEmpty)
              TextButton.icon(
                onPressed: () => widget.onLeer(notas.map((n) => n.texto).join('. ')),
                icon: const Icon(Icons.volume_up, size: 14),
                label: const Text('Leer todo', style: TextStyle(fontSize: 12)),
              ),
          ]),
        ),
        // Notas existentes
        Expanded(
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              ...notas.map((n) => _NotaItem(
                nota: n,
                color: _colores[n.colorHex] ?? Colors.yellow,
                onEliminar: () {
                  widget.pdf.notas.removeWhere((x) => x.id == n.id);
                  widget.onNotaGuardada();
                  setState(() {});
                },
                onLeer: () => widget.onLeer(n.texto),
              )),
              const SizedBox(height: 12),
              // Selector de color
              Row(children: _colores.entries.map((e) => GestureDetector(
                onTap: () => setState(() => _colorSeleccionado = e.key),
                child: Container(
                  width: 28, height: 28, margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: e.value,
                    shape: BoxShape.circle,
                    border: _colorSeleccionado == e.key
                        ? Border.all(color: theme.colorScheme.primary, width: 3)
                        : null,
                  ),
                ),
              )).toList()),
              const SizedBox(height: 8),
              // Toggle resaltado/nota
              Row(children: [
                const Text('Tipo:', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Nota', style: TextStyle(fontSize: 11)),
                  selected: !_esResaltado,
                  onSelected: (_) => setState(() => _esResaltado = false),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Resaltado', style: TextStyle(fontSize: 11)),
                  selected: _esResaltado,
                  onSelected: (_) => setState(() => _esResaltado = true),
                ),
              ]),
              const SizedBox(height: 8),
              // Input
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _esResaltado
                          ? 'Texto a resaltar...'
                          : 'Escribe una nota sobre esta página...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: (_colores[_colorSeleccionado] ?? Colors.yellow).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _agregar,
                  icon: const Icon(Icons.add),
                ),
              ]),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ]),
    );
  }
}

class _NotaItem extends StatelessWidget {
  final NotaPDF nota;
  final Color color;
  final VoidCallback onEliminar, onLeer;

  const _NotaItem({
    required this.nota, required this.color,
    required this.onEliminar, required this.onLeer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(nota.esResaltado ? Icons.highlight : Icons.notes,
            size: 16, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Expanded(child: Text(nota.texto, style: const TextStyle(fontSize: 13))),
        InkWell(onTap: onLeer, child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.volume_up, size: 14, color: Colors.grey),
        )),
        InkWell(onTap: onEliminar, child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.close, size: 14, color: Colors.grey),
        )),
      ]),
    );
  }
}
