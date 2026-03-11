import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

enum _ModoPomodoro { trabajo, descansoCorto, descansoLargo }

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  _ModoPomodoro _modo = _ModoPomodoro.trabajo;
  int _segundosRestantes = 25 * 60;
  bool _corriendo = false;
  int _rondas = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  static const _duraciones = {
    _ModoPomodoro.trabajo: 25 * 60,
    _ModoPomodoro.descansoCorto: 5 * 60,
    _ModoPomodoro.descansoLargo: 15 * 60,
  };

  static const _colores = {
    _ModoPomodoro.trabajo: Color(0xFFEF5350),
    _ModoPomodoro.descansoCorto: Color(0xFF26A69A),
    _ModoPomodoro.descansoLargo: Color(0xFF5C6BC0),
  };

  static const _etiquetas = {
    _ModoPomodoro.trabajo: 'Enfoque',
    _ModoPomodoro.descansoCorto: 'Descanso corto',
    _ModoPomodoro.descansoLargo: 'Descanso largo',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  int get _duracionTotal => _duraciones[_modo]!;

  void _iniciar() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_segundosRestantes <= 0) {
        _timer?.cancel();
        setState(() => _corriendo = false);
        _onFinish();
        return;
      }
      setState(() => _segundosRestantes--);
    });
    setState(() => _corriendo = true);
  }

  void _pausar() {
    _timer?.cancel();
    setState(() => _corriendo = false);
  }

  void _reiniciar() {
    _timer?.cancel();
    setState(() {
      _corriendo = false;
      _segundosRestantes = _duracionTotal;
    });
  }

  void _cambiarModo(_ModoPomodoro modo) {
    _timer?.cancel();
    setState(() {
      _modo = modo;
      _corriendo = false;
      _segundosRestantes = _duraciones[modo]!;
    });
  }

  void _onFinish() {
    if (_modo == _ModoPomodoro.trabajo) {
      setState(() => _rondas++);
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_modo == _ModoPomodoro.trabajo
            ? '¡Ronda completada!'
            : '¡Descanso terminado!'),
        content: Text(_modo == _ModoPomodoro.trabajo
            ? 'Llevas $_rondas ${_rondas == 1 ? 'ronda' : 'rondas'} completadas. ¿Tomar un descanso?'
            : '¿Listo para otra ronda de enfoque?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cambiarModo(_modo == _ModoPomodoro.trabajo
                  ? (_rondas % 4 == 0
                      ? _ModoPomodoro.descansoLargo
                      : _ModoPomodoro.descansoCorto)
                  : _ModoPomodoro.trabajo);
            },
            child: Text(_modo == _ModoPomodoro.trabajo
                ? 'Descansar'
                : 'Enfocarme'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reiniciar();
            },
            child: const Text('Quedarse'),
          ),
        ],
      ),
    );
  }

  String get _tiempoFormateado {
    final min = (_segundosRestantes ~/ 60).toString().padLeft(2, '0');
    final seg = (_segundosRestantes % 60).toString().padLeft(2, '0');
    return '$min:$seg';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final color = _colores[_modo]!;
    final progreso = 1 - (_segundosRestantes / _duracionTotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
        backgroundColor: color.withValues(alpha: 0.1),
      ),
      backgroundColor: color.withValues(alpha: 0.05),
      body: Column(
        children: [
          // Selector de modo
          Container(
            color: color.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _ModoPomodoro.values.map((m) {
                final sel = m == _modo;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _cambiarModo(m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? color : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _etiquetas[m]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sel
                              ? Colors.white
                              : color.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Contador de rondas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color:
                            i < (_rondas % 4) ? color : color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ronda ${(_rondas % 4) + 1} de 4',
                  style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),

                // Timer circular
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: progreso,
                        strokeWidth: 10,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (ctx, child) => Transform.scale(
                        scale: _corriendo
                            ? 1.0 + _pulseController.value * 0.02
                            : 1.0,
                        child: child,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _tiempoFormateado,
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              color: color,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            _etiquetas[_modo]!,
                            style: TextStyle(
                                color: color.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Controles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _reiniciar,
                      icon: const Icon(Icons.refresh),
                      iconSize: 32,
                      color: color.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: _corriendo ? _pausar : _iniciar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_corriendo ? Icons.pause : Icons.play_arrow,
                              size: 28),
                          const SizedBox(width: 8),
                          Text(_corriendo ? 'Pausar' : 'Iniciar',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: () {
                        final siguiente = _modo == _ModoPomodoro.trabajo
                            ? (_rondas % 4 == 3
                                ? _ModoPomodoro.descansoLargo
                                : _ModoPomodoro.descansoCorto)
                            : _ModoPomodoro.trabajo;
                        _cambiarModo(siguiente);
                      },
                      icon: const Icon(Icons.skip_next),
                      iconSize: 32,
                      color: color.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Total rondas
                Text(
                  'Total: $_rondas ${_rondas == 1 ? 'ronda completada' : 'rondas completadas'}',
                  style: TextStyle(
                      color: color.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Materia actual (si hay seleccionada)
          if (provider.materias.isNotEmpty)
            _MateriaSelector(provider: provider, color: color),
        ],
      ),
    );
  }
}

class _MateriaSelector extends StatefulWidget {
  final AppProvider provider;
  final Color color;
  const _MateriaSelector({required this.provider, required this.color});

  @override
  State<_MateriaSelector> createState() => _MateriaSelectorState();
}

class _MateriaSelectorState extends State<_MateriaSelector> {
  String? _materiaId;

  @override
  Widget build(BuildContext context) {
    final materia = _materiaId != null
        ? widget.provider.materiaById(_materiaId!)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.menu_book_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _materiaId,
              isExpanded: true,
              hint: const Text('Estudiando...'),
              underline: const SizedBox(),
              items: widget.provider.materias
                  .map((m) => DropdownMenuItem(
                      value: m.id, child: Text(m.nombre)))
                  .toList(),
              onChanged: (v) => setState(() => _materiaId = v),
            ),
          ),
          if (materia != null)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Color(materia.colorValue),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
