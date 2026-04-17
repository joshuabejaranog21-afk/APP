import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../models/estudio_pdf.dart';
import '../../providers/app_provider.dart';
import 'pdf_viewer_screen.dart';

class PDFsScreen extends StatelessWidget {
  const PDFsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pdfs = provider.pdfs;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos PDF'),
        actions: [
          if (provider.claudeApiKey.isEmpty)
            IconButton(
              icon: const Icon(Icons.key_outlined),
              tooltip: 'Configurar API key de Claude',
              onPressed: () => _mostrarDialogoApiKey(context, provider),
            ),
        ],
      ),
      body: pdfs.isEmpty
          ? _EmptyState(onAgregar: () => _subirPDF(context, provider))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pdfs.length,
              itemBuilder: (context, i) => _PDFCard(
                pdf: pdfs[i],
                provider: provider,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PDFViewerScreen(pdf: pdfs[i]),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _subirPDF(context, provider),
        icon: const Icon(Icons.upload_file),
        label: const Text('Subir PDF'),
      ),
    );
  }

  Future<void> _subirPDF(BuildContext context, AppProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    final srcPath = result.files.single.path!;
    final nombre = result.files.single.name
        .replaceAll('.pdf', '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // Copy to app documents directory so it persists
    final docsDir = await getApplicationDocumentsDirectory();
    final pdfsDir = Directory('${docsDir.path}/pdfs');
    if (!await pdfsDir.exists()) await pdfsDir.create(recursive: true);

    final destPath = '${pdfsDir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(srcPath).copy(destPath);

    final pdf = EstudioPDF(titulo: nombre, rutaLocal: destPath);
    // ignore: use_build_context_synchronously
    if (!context.mounted) return;
    await provider.agregarPDF(pdf);

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => PDFViewerScreen(pdf: pdf)),
    );
  }

  Future<void> _mostrarDialogoApiKey(BuildContext context, AppProvider provider) async {
    final ctrl = TextEditingController(text: provider.claudeApiKey);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API Key de Claude'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Necesitas una API key de Anthropic para usar el asistente IA.\n'
              'Consíguela en console.anthropic.com',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'sk-ant-...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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

// ── Card del PDF ──────────────────────────────────────────────
class _PDFCard extends StatelessWidget {
  final EstudioPDF pdf;
  final AppProvider provider;
  final VoidCallback onTap;

  const _PDFCard({required this.pdf, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materia = pdf.materiaId != null ? provider.materiaById(pdf.materiaId!) : null;
    final color = materia != null ? Color(materia.colorValue) : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48, height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.picture_as_pdf, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pdf.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (materia != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(materia.nombre,
                                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          '${pdf.notas.length} notas  •  '
                          'p.${pdf.ultimaPagina + 1}${pdf.totalPaginas > 0 ? '/${pdf.totalPaginas}' : ''}',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat("d MMM yyyy", 'es_ES').format(pdf.fechaAgregado),
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'materia') _asignarMateria(context, provider, pdf);
                  if (v == 'renombrar') _renombrar(context, provider, pdf);
                  if (v == 'eliminar') {
                    await provider.eliminarPDF(pdf.id);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'materia', child: Text('Asignar materia')),
                  const PopupMenuItem(value: 'renombrar', child: Text('Renombrar')),
                  const PopupMenuItem(
                    value: 'eliminar',
                    child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _asignarMateria(BuildContext context, AppProvider provider, EstudioPDF pdf) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('Asignar materia', style: TextStyle(fontWeight: FontWeight.w700))),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Sin materia'),
            onTap: () {
              provider.actualizarPDF(pdf..materiaId = null);
              Navigator.pop(ctx);
            },
          ),
          ...provider.materias.map((m) => ListTile(
            leading: CircleAvatar(backgroundColor: Color(m.colorValue), radius: 10),
            title: Text(m.nombre),
            onTap: () {
              provider.actualizarPDF(pdf..materiaId = m.id);
              Navigator.pop(ctx);
            },
          )),
        ],
      ),
    );
  }

  void _renombrar(BuildContext context, AppProvider provider, EstudioPDF pdf) {
    final ctrl = TextEditingController(text: pdf.titulo);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(controller: ctrl, autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.actualizarPDF(pdf..titulo = ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAgregar;
  const _EmptyState({required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 72,
                color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('Aún no hay documentos',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Sube un PDF para leerlo, tomar notas,\nescucharlo y preguntarle a la IA.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.upload_file),
              label: const Text('Subir primer PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
