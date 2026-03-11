import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/materia.dart';

class HorarioScreen extends StatelessWidget {
  const HorarioScreen({super.key});

  static const _horas = [
    '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final hoyDia = DateTime.now().weekday; // 1=Lun

    return Scaffold(
      appBar: AppBar(title: const Text('Horario Semanal')),
      body: provider.materias.isEmpty
          ? _empty(context)
          : Column(
              children: [
                // Cabecera días
                _DiaHeader(hoyDia: hoyDia),
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna de horas
                        _HorasColumn(),
                        // Columnas de días
                        ...List.generate(7, (diaIdx) {
                          final dia = diaIdx + 1;
                          return Expanded(
                            child: _DiaColumn(
                              dia: dia,
                              horas: _horas,
                              materias: provider.materias,
                              isHoy: dia == hoyDia,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_view_week_outlined,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('Agrega materias con horario\npara ver tu semana',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _DiaHeader extends StatelessWidget {
  final int hoyDia;
  const _DiaHeader({required this.hoyDia});

  static const _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: Row(
        children: [
          const SizedBox(width: 44), // espacio horas
          ...List.generate(7, (i) {
            final isHoy = (i + 1) == hoyDia;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: isHoy
                    ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: colorScheme.primary, width: 3),
                        ),
                      )
                    : null,
                child: Text(
                  _dias[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isHoy ? colorScheme.primary : null,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HorasColumn extends StatelessWidget {
  static const _horas = [
    '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Column(
        children: _horas
            .map((h) => SizedBox(
                  height: 60,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(h,
                          style: TextStyle(
                              fontSize: 9,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4))),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _DiaColumn extends StatelessWidget {
  final int dia;
  final List<String> horas;
  final List<Materia> materias;
  final bool isHoy;

  const _DiaColumn({
    required this.dia,
    required this.horas,
    required this.materias,
    required this.isHoy,
  });

  @override
  Widget build(BuildContext context) {
    // Reúne todos los bloques para este día
    final bloques = <_Bloque>[];
    for (final m in materias) {
      for (final h in m.horarios) {
        if (h.diaSemana == dia) {
          bloques.add(_Bloque(materia: m, horario: h));
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isHoy
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.04)
            : null,
        border: Border(
          left: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.4)),
        ),
      ),
      child: Stack(
        children: [
          // Líneas de hora
          Column(
            children: horas
                .map((_) => Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          // Bloques de clase
          ...bloques.map((b) => _BloqueWidget(bloque: b)),
        ],
      ),
    );
  }
}

class _BloqueWidget extends StatelessWidget {
  final _Bloque bloque;
  const _BloqueWidget({required this.bloque});

  @override
  Widget build(BuildContext context) {
    final color = Color(bloque.materia.colorValue);
    final top = _horaToOffset(bloque.horario.horaInicio);
    final bottom = _horaToOffset(bloque.horario.horaFin);
    final height = (bottom - top).clamp(30.0, 600.0);

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bloque.materia.nombre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
            if (height > 45 && bloque.materia.aula.isNotEmpty)
              Text(bloque.materia.aula,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  double _horaToOffset(String hora) {
    final parts = hora.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    // 07:00 = offset 0, cada hora = 60px
    return ((h - 7) * 60 + m).toDouble();
  }
}

class _Bloque {
  final Materia materia;
  final HorarioClase horario;
  const _Bloque({required this.materia, required this.horario});
}
