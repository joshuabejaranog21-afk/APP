import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _modoRegistro = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _cargando = false;
  bool _passVisible = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nombreCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _cargando = true;
    });
    try {
      if (_modoRegistro) {
        await _register();
      } else {
        await _login();
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      final user = res.user;
      if (user != null) {
        final metaNombre = user.userMetadata?['nombre'] as String?;
        final nombre = (metaNombre != null && metaNombre.isNotEmpty)
            ? metaNombre
            : user.email?.split('@').first ?? 'Alumno';
        await context.read<AppProvider>().setUserInfo(nombre, user.email ?? '');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _traducir(e.message));
    } catch (_) {
      if (mounted) setState(() => _error = 'Sin conexión. Intenta de nuevo.');
    }
  }

  Future<void> _register() async {
    if (_nombreCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        data: {'nombre': _nombreCtrl.text.trim()},
      );
      if (!mounted) return;
      if (res.user != null) {
        await context.read<AppProvider>().setUserInfo(
          _nombreCtrl.text.trim(),
          _emailCtrl.text.trim(),
        );
      } else {
        setState(() => _error = 'Revisa tu correo para confirmar la cuenta');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _traducir(e.message));
    } catch (_) {
      if (mounted) setState(() => _error = 'Sin conexión. Intenta de nuevo.');
    }
  }

  Future<void> _sinCuenta() async {
    await context.read<AppProvider>().setUserInfo('Invitado', '');
  }

  String _traducir(String msg) {
    if (msg.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión';
    }
    if (msg.contains('User already registered')) {
      return 'Este correo ya está registrado';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Demasiados intentos. Espera un momento';
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── Logo ─────────────────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🎓', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Gestor de Materias',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                _modoRegistro
                    ? 'Crea tu cuenta y empieza hoy'
                    : 'Organiza tu vida académica',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // ── Form card ────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _modoRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 20),

                        // Nombre (solo registro)
                        if (_modoRegistro) ...[
                          TextField(
                            controller: _nombreCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo',
                              prefixIcon: Icon(Icons.person_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Email
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Contraseña
                        TextField(
                          controller: _passCtrl,
                          obscureText: !_passVisible,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_passVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(
                                  () => _passVisible = !_passVisible),
                            ),
                          ),
                          onSubmitted: _modoRegistro ? null : (_) => _submit(),
                        ),

                        // Confirmar contraseña (solo registro)
                        if (_modoRegistro) ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _confirmPassCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar contraseña',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ],

                        // Error
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: theme.colorScheme.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Botón submit
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _cargando ? null : _submit,
                            child: _cargando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : Text(_modoRegistro
                                    ? 'Crear cuenta'
                                    : 'Iniciar sesión'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Toggle login/registro ─────────────────────────
              TextButton(
                onPressed: () => setState(() {
                  _modoRegistro = !_modoRegistro;
                  _error = null;
                }),
                child: Text(
                  _modoRegistro
                      ? '¿Ya tienes cuenta? Inicia sesión'
                      : '¿No tienes cuenta? Regístrate',
                ),
              ),

              // ── Sin cuenta ────────────────────────────────────
              TextButton(
                onPressed: _cargando ? null : _sinCuenta,
                child: Text(
                  'Continuar sin cuenta',
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
