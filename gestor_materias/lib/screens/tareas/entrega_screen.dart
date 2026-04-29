import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/tarea.dart';
import '../../providers/app_provider.dart';

class EntregaScreen extends StatefulWidget {
  final Tarea tarea;
  const EntregaScreen({super.key, required this.tarea});

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  final _textoCtrl = TextEditingController();
  final List<String> _archivos = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    // Cargar entrega previa si existe
    final e = widget.tarea.entrega;
    if (e != null) {
      _textoCtrl.text = e.texto;
      _archivos.addAll(e.archivos);
    }
  }

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  Future<void> _adjuntarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
    );
    if (result == null) return;
    setState(() {
      for (final f in result.files) {
        final nombre = kIsWeb ? f.name : (f.path ?? f.name);
        if (!_archivos.contains(nombre)) _archivos.add(nombre);
      }
    });
  }

  Future<void> _entregar() async {
    if (_textoCtrl.text.trim().isEmpty && _archivos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega texto o un archivo antes de entregar')),
      );
      return;
    }
    setState(() => _guardando = true);

    final entrega = EntregaTarea(
      texto: _textoCtrl.text.trim(),
      archivos: List.from(_archivos),
    );

    final provider = context.read<AppProvider>();
    final tarea = widget.tarea;
    tarea.entrega = entrega;
    tarea.estado = EstadoTarea.entregada;
    tarea.completadaEn = DateTime.now();
    await provider.actualizarTarea(tarea);

    if (mounted) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Tarea entregada exitosamente'),
          ]),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final yaEntregada = widget.tarea.estado == EstadoTarea.entregada;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregar tarea'),
        actions: [
          if (!yaEntregada)
            TextButton.icon(
              icon: _guardando
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text('Entregar', style: TextStyle(color: Colors.white)),
              onPressed: _guardando ? null : _entregar,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info de la tarea ───────────────────────────
            _TareaInfoCard(tarea: widget.tarea),
            const SizedBox(height: 20),

            // ── Estado ────────────────────────────────────
            if (yaEntregada) ...[
              _EstadoEntregadaBanner(
                fecha: widget.tarea.completadaEn ?? DateTime.now(),
              ),
              const SizedBox(height: 20),
            ],

            // ── Respuesta escrita ──────────────────────────
            Text('Respuesta escrita', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (yaEntregada && _textoCtrl.text.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Sin respuesta escrita',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              )
            else
              TextField(
                controller: _textoCtrl,
                maxLines: 10,
                readOnly: yaEntregada,
                decoration: InputDecoration(
                  hintText: 'Escribe tu respuesta aquí...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
            const SizedBox(height: 24),

            // ── Archivos adjuntos ─────────────────────────
            Row(
              children: [
                Text('Archivos adjuntos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (!yaEntregada)
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Adjuntar'),
                    onPressed: _adjuntarArchivo,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (_archivos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Sin archivos adjuntos',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _archivos.length,
                separatorBuilder: (context, i) => const SizedBox(height: 6),
                itemBuilder: (_, i) => _ArchivoChip(
                  ruta: _archivos[i],
                  onEliminar: yaEntregada ? null : () => setState(() => _archivos.removeAt(i)),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      // ── FAB Entregar ──────────────────────────────────────
      floatingActionButton: yaEntregada
          ? null
          : FloatingActionButton.extended(
              heroTag: 'entrega_fab',
              onPressed: _guardando ? null : _entregar,
              icon: _guardando
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: const Text('Entregar'),
              backgroundColor: Colors.green.shade600,
            ),
    );
  }
}

// ── Tarjeta info tarea ────────────────────────────────────────
class _TareaInfoCard extends StatelessWidget {
  final Tarea tarea;
  const _TareaInfoCard({required this.tarea});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(tarea.tipo.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(tarea.titulo,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            if (tarea.descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(tarea.descripcion,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14,
                    color: tarea.estaVencida ? Colors.red : theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Entrega: ${_formatearFecha(tarea.fechaLimite)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: tarea.estaVencida ? Colors.red : theme.colorScheme.onSurfaceVariant,
                    fontWeight: tarea.estaVencida ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (tarea.estaVencida) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Vencida', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ── Banner entregada ──────────────────────────────────────────
class _EstadoEntregadaBanner extends StatelessWidget {
  final DateTime fecha;
  const _EstadoEntregadaBanner({required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entregada', style: TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.green.shade800)),
                Text(
                  'El ${fecha.day}/${fecha.month}/${fecha.year} a las ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip de archivo ───────────────────────────────────────────
class _ArchivoChip extends StatelessWidget {
  final String ruta;
  final VoidCallback? onEliminar;
  const _ArchivoChip({required this.ruta, this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final nombre = ruta.contains('/') || ruta.contains('\\')
        ? ruta.split(RegExp(r'[/\\]')).last
        : ruta;
    final esImagen = ['png', 'jpg', 'jpeg']
        .any((ext) => nombre.toLowerCase().endsWith(ext));
    final esPdf = nombre.toLowerCase().endsWith('.pdf');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            esPdf ? Icons.picture_as_pdf_rounded
                : esImagen ? Icons.image_outlined
                : Icons.insert_drive_file_outlined,
            size: 20,
            color: esPdf ? Colors.red.shade400 : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
          ),
          if (onEliminar != null)
            GestureDetector(
              onTap: onEliminar,
              child: Icon(Icons.close, size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
