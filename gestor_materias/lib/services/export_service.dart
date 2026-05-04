import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/materia.dart';
import '../models/nota.dart';
import '../models/tarea.dart';

class ExportService {
  // ── Exportar reporte completo ──────────────────────────────
  static Future<Uint8List> generarReporteCompleto({
    required String nombreAlumno,
    required List<Materia> materias,
    required List<Calificacion> calificaciones,
    required List<Tarea> tareas,
  }) async {
    final pdf = pw.Document();
    final font     = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => _encabezado(nombreAlumno, fontBold),
      footer: (ctx) => _pie(ctx, font),
      build: (ctx) => [
        pw.SizedBox(height: 16),
        _resumenGeneral(materias, calificaciones, font, fontBold),
        pw.SizedBox(height: 24),
        ...materias.map((m) {
          final cals = calificaciones.where((c) => c.materiaId == m.id).toList();
          final tars = tareas.where((t) =>
              t.materiaId == m.id && t.estado == EstadoTarea.entregada).toList();
          return _bloqueMateria(m, cals, tars, font, fontBold);
        }),
      ],
    ));

    return pdf.save();
  }

  // ── Exportar una sola materia ──────────────────────────────
  static Future<Uint8List> generarReporteMateria({
    required String nombreAlumno,
    required Materia materia,
    required List<Calificacion> calificaciones,
    required List<Tarea> tareas,
  }) async {
    final pdf = pw.Document();
    final font     = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final cals = calificaciones.where((c) => c.materiaId == materia.id).toList();
    final tars = tareas.where((t) =>
        t.materiaId == materia.id && t.estado == EstadoTarea.entregada).toList();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => _encabezado(nombreAlumno, fontBold),
      footer: (ctx) => _pie(ctx, font),
      build: (ctx) => [
        pw.SizedBox(height: 16),
        _bloqueMateria(materia, cals, tars, font, fontBold),
      ],
    ));

    return pdf.save();
  }

  // ── Compartir / previsualizar ──────────────────────────────
  static Future<void> compartir(Uint8List bytes, String nombre) async =>
      Printing.sharePdf(bytes: bytes, filename: '$nombre.pdf');

  static Future<void> previsualizar(Uint8List bytes) async =>
      Printing.layoutPdf(onLayout: (_) async => bytes);

  // ── Encabezado y pie ──────────────────────────────────────
  static pw.Widget _encabezado(String alumno, pw.Font bold) =>
      pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Reporte de Calificaciones',
                  style: pw.TextStyle(font: bold, fontSize: 17,
                      color: PdfColors.deepPurple700)),
              pw.SizedBox(height: 2),
              pw.Text('Alumno: $alumno',
                  style: pw.TextStyle(font: bold, fontSize: 11)),
            ]),
            pw.Text(_fmtFecha(DateTime.now()),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      );

  static pw.Widget _pie(pw.Context ctx, pw.Font font) =>
      pw.Container(
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Gestor de Materias',
                style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500)),
            pw.Text('Pág. ${ctx.pageNumber}/${ctx.pagesCount}',
                style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500)),
          ],
        ),
      );

  // ── Resumen general ────────────────────────────────────────
  static pw.Widget _resumenGeneral(List<Materia> materias,
      List<Calificacion> cals, pw.Font font, pw.Font bold) {
    double totalPonderado = 0;
    int totalMaterias = 0;

    final filas = materias.map((m) {
      final mc = cals.where((c) => c.materiaId == m.id).toList();
      final prom = _promedio(mc);
      totalPonderado += prom;
      totalMaterias++;
      return (materia: m, promedio: prom, cals: mc);
    }).toList();

    final promGeneral = totalMaterias == 0 ? 0.0 : totalPonderado / totalMaterias;

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
          color: PdfColors.deepPurple50,
          borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Resumen General',
              style: pw.TextStyle(font: bold, fontSize: 13, color: PdfColors.deepPurple800)),
          pw.RichText(text: pw.TextSpan(children: [
            pw.TextSpan(text: 'Promedio global: ',
                style: pw.TextStyle(font: font, fontSize: 11)),
            pw.TextSpan(text: promGeneral.toStringAsFixed(1),
                style: pw.TextStyle(font: bold, fontSize: 16,
                    color: _pdfColor(promGeneral))),
          ])),
        ]),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey200),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1.2),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.deepPurple100),
              children: ['Materia', 'Promedio', 'Objetivo', 'Estado']
                  .map((h) => _th(h, bold)).toList(),
            ),
            ...filas.map((f) => pw.TableRow(children: [
                  _td(f.materia.nombre, font),
                  _tdColor(f.promedio.toStringAsFixed(1), bold, _pdfColor(f.promedio)),
                  _td((f.materia.notaObjetivo ?? 7.0).toStringAsFixed(1), font),
                  _tdColor(
                    f.promedio >= (f.materia.notaObjetivo ?? 7.0) ? '✓ Meta' : '✗ Bajo',
                    bold,
                    f.promedio >= (f.materia.notaObjetivo ?? 7.0)
                        ? PdfColors.green700 : PdfColors.red700,
                  ),
                ])),
          ],
        ),
      ]),
    );
  }

  // ── Bloque por materia ─────────────────────────────────────
  static pw.Widget _bloqueMateria(Materia m, List<Calificacion> cals,
      List<Tarea> tareas, pw.Font font, pw.Font bold) {
    final prom = _promedio(cals);

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      // Header materia
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.deepPurple700,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(6), topRight: pw.Radius.circular(6)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(m.nombre,
                style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.white)),
            pw.Text('Prof. ${m.profesor}  |  ${m.aula}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey200)),
          ],
        ),
      ),

      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey200),
          borderRadius: const pw.BorderRadius.only(
            bottomLeft: pw.Radius.circular(6), bottomRight: pw.Radius.circular(6)),
        ),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // Promedio
          pw.Row(children: [
            pw.Text('Promedio actual: ',
                style: pw.TextStyle(font: font, fontSize: 10)),
            pw.Text(prom.toStringAsFixed(2),
                style: pw.TextStyle(font: bold, fontSize: 14,
                    color: _pdfColor(prom))),
            pw.Text('  /  Meta: ${(m.notaObjetivo ?? 7.0).toStringAsFixed(1)}',
                style: pw.TextStyle(font: font, fontSize: 9,
                    color: PdfColors.grey600)),
          ]),

          if (cals.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Evaluaciones', style: pw.TextStyle(font: bold, fontSize: 10,
                color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey200),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: ['Evaluación', 'Nota', 'Peso', 'Fecha']
                      .map((h) => _th(h, bold, size: 9)).toList(),
                ),
                ...cals.map((c) => pw.TableRow(children: [
                      _td(c.nombre, font, size: 9),
                      _tdColor('${c.nota}/${c.notaMaxima}', bold,
                          _pdfColor(c.nota), size: 9),
                      _td('${c.porcentaje.toStringAsFixed(0)}%', font, size: 9),
                      _td(_fmtFecha(c.fecha), font, size: 9),
                    ])),
              ],
            ),
          ],

          if (tareas.any((t) => t.entrega?.calificada == true)) ...[
            pw.SizedBox(height: 8),
            pw.Text('Tareas calificadas', style: pw.TextStyle(font: bold, fontSize: 10,
                color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey200),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(3),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: ['Tarea', 'Cal.', 'Retroalimentación']
                      .map((h) => _th(h, bold, size: 9)).toList(),
                ),
                ...tareas
                    .where((t) => t.entrega?.calificada == true)
                    .map((t) => pw.TableRow(children: [
                          _td(t.titulo, font, size: 9),
                          _tdColor(t.entrega!.calificacion!.toStringAsFixed(1),
                              bold, _pdfColor(t.entrega!.calificacion!), size: 9),
                          _td(
                              t.entrega!.retroalimentacion.isEmpty
                                  ? '—'
                                  : t.entrega!.retroalimentacion,
                              font, size: 9),
                        ])),
              ],
            ),
          ],
        ]),
      ),

      pw.SizedBox(height: 18),
    ]);
  }

  // ── Helpers ────────────────────────────────────────────────
  static double _promedio(List<Calificacion> cals) {
    if (cals.isEmpty) return 0.0;
    double sumPond = 0, sumPeso = 0;
    for (final c in cals) {
      sumPond += (c.nota / c.notaMaxima) * 10 * c.porcentaje;
      sumPeso += c.porcentaje;
    }
    return sumPeso == 0 ? 0.0 : sumPond / sumPeso;
  }

  static pw.Widget _th(String t, pw.Font bold, {double size = 10}) =>
      pw.Padding(padding: const pw.EdgeInsets.all(5),
          child: pw.Text(t, style: pw.TextStyle(font: bold, fontSize: size)));

  static pw.Widget _td(String t, pw.Font font, {double size = 10}) =>
      pw.Padding(padding: const pw.EdgeInsets.all(5),
          child: pw.Text(t, style: pw.TextStyle(font: font, fontSize: size)));

  static pw.Widget _tdColor(String t, pw.Font font, PdfColor color,
          {double size = 10}) =>
      pw.Padding(padding: const pw.EdgeInsets.all(5),
          child: pw.Text(t,
              style: pw.TextStyle(font: font, fontSize: size, color: color)));

  static PdfColor _pdfColor(double n) {
    if (n >= 9) return PdfColors.green700;
    if (n >= 7) return PdfColors.blue700;
    if (n >= 6) return PdfColors.orange700;
    return PdfColors.red700;
  }

  static String _fmtFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
