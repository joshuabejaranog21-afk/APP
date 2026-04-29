import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class RolScreen extends StatelessWidget {
  const RolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school,
                  size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                '¿Cómo deseas ingresar?',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes cambiar de rol en cualquier momento',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _RolCard(
                icon: Icons.person_outline,
                titulo: 'Soy Alumno',
                descripcion: 'Gestiona tus tareas, materias y calendario',
                color: theme.colorScheme.primary,
                onTap: () => _seleccionar(context, false),
              ),
              const SizedBox(height: 16),
              _RolCard(
                icon: Icons.co_present_outlined,
                titulo: 'Soy Maestro',
                descripcion: 'Crea grupos, asigna tareas y publica anuncios',
                color: const Color(0xFF4CAF50),
                onTap: () => _seleccionar(context, true),
              ),
              const SizedBox(height: 16),
              _RolCard(
                icon: Icons.admin_panel_settings_outlined,
                titulo: 'Administrador',
                descripcion: 'Gestiona materias, grupos y profesores',
                color: const Color(0xFFE91E63),
                onTap: () => context.read<AppProvider>().setRolAdmin(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionar(BuildContext context, bool esMaestro) async {
    await context.read<AppProvider>().setRol(esMaestro);
  }
}

class _RolCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  const _RolCard({
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(descripcion,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
