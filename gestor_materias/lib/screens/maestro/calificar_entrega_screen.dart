import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tarea.dart';
import '../../providers/app_provider.dart';

class CalificarEntregaScreen extends StatefulWidget {
  final Tarea tarea;
  const CalificarEntregaScreen({super.key, required this.tarea});

  @override
  State<CalificarEntregaScreen> createState() => _CalificarEntregaScreenState();
}

class _CalificarEntregaScreenState extends State<CalificarEntregaScreen> {
  final _retroCtrl = TextEditingController();
  double _calificacion = 10.0;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final e = widget.tarea.entrega;
    if (e != null) {
      _calificacion = e.calificacion ?? 10.0;
      _retroCtrl.text = e.retroalimentacion;
    }
  }

  @override
  void dispose() {
    _retroCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarCalificacion() async {
    setState(() => _guardando = true);
    final tarea = widget.tarea;
    final entrega = tarea.entrega ?? EntregaTarea();
    entrega.calificacion = _calificacion;
    entrega.retroalimentacion = _retroCtrl.text.trim();
    entrega.fechaCalificacion = DateTime.now();
    tarea.entrega = entrega;

    await context.read<AppProvider>().actualizarTarea(tarea);

    if (mounted) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Calificación guardada: ${_calificacion.toStringAsFixed(1)}'),
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
    final entrega = widget.tarea.entrega;
    final yaCalificada = entrega?.calificada ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificar entrega'),
        actions: [
          TextButton.icon(
            icon: _guardando
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded, color: Colors.white),
            label: const Text('Guardar', style: TextStyle(color: Colors.white)),
            onPressed: _guardando ? null : _guardarCalificacion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info tarea ──────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(widget.tarea.tipo.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(widget.tarea.titulo,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    if (widget.tarea.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(widget.tarea.descripcion,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Entrega del alumno ──────────────────────────
            Text('Entrega del alumno',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            if (entrega == null)
              _EmptyEntrega()
            else ...[
              // Fecha de entrega
              _InfoChip(
                icon: Icons.access_time,
                texto: 'Entregada el ${_formatFecha(entrega.fecha)}',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              // Respuesta escrita
              if (entrega.texto.isNotEmpty) ...[
                Text('Respuesta escrita',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(entrega.texto, style: const TextStyle(fontSize: 14)),
                ),
                const SizedBox(height: 12),
              ] else
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InfoChip(
                    icon: Icons.text_fields,
                    texto: 'Sin respuesta escrita',
                    color: Colors.grey,
                  ),
                ),

              // Archivos adjuntos
              if (entrega.archivos.isNotEmpty) ...[
                Text('Archivos adjuntos',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                ...entrega.archivos.map((ruta) {
                  final nombre = ruta.contains('/') || ruta.contains('\\')
                      ? ruta.split(RegExp(r'[/\\]')).last
                      : ruta;
                  final esPdf = nombre.toLowerCase().endsWith('.pdf');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        Icon(esPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_outlined,
                            size: 18, color: esPdf ? Colors.red.shade400 : theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(nombre, style: const TextStyle(fontSize: 13),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ],

            const Divider(height: 32),

            // ── Calificación ────────────────────────────────
            Text('Calificación',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Número grande
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: _calificacion, end: _calificacion),
                duration: const Duration(milliseconds: 200),
                builder: (ctx, val, child) => Text(
                  _calificacion.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: _colorCalificacion(_calificacion),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Slider
            Slider(
              value: _calificacion,
              min: 0,
              max: 10,
              divisions: 20,
              label: _calificacion.toStringAsFixed(1),
              activeColor: _colorCalificacion(_calificacion),
              onChanged: (v) => setState(() => _calificacion = v),
            ),

            // Botones rápidos
            Wrap(
              spacing: 8,
              children: [0.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0].map((v) =>
                ChoiceChip(
                  label: Text(v.toStringAsFixed(0)),
                  selected: _calificacion == v,
                  selectedColor: _colorCalificacion(v).withValues(alpha: 0.2),
                  onSelected: (_) => setState(() => _calificacion = v),
                ),
              ).toList(),
            ),
            const SizedBox(height: 24),

            // Retroalimentación
            Text('Retroalimentación',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _retroCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escribe comentarios para el alumno...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),

            // Fecha calificación previa
            if (yaCalificada && entrega?.fechaCalificacion != null) ...[
              const SizedBox(height: 12),
              _InfoChip(
                icon: Icons.history,
                texto: 'Calificado el ${_formatFecha(entrega!.fechaCalificacion!)}',
                color: Colors.orange,
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'calificar_fab',
        onPressed: _guardando ? null : _guardarCalificacion,
        icon: _guardando
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save_rounded),
        label: const Text('Guardar calificación'),
        backgroundColor: _colorCalificacion(_calificacion),
      ),
    );
  }

  Color _colorCalificacion(double c) {
    if (c >= 9) return Colors.green.shade600;
    if (c >= 7) return Colors.blue.shade600;
    if (c >= 6) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _formatFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _EmptyEntrega extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.inbox_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        const Text('El alumno aún no ha entregado esta tarea'),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color color;
  const _InfoChip({required this.icon, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
