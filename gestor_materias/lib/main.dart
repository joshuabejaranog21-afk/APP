import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/rol/rol_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  final provider = AppProvider();
  await provider.cargar();
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const GestorMateriasApp(),
    ),
  );
}

class GestorMateriasApp extends StatelessWidget {
  const GestorMateriasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().modoOscuro;
    return MaterialApp(
      title: 'Gestor de Materias',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      locale: const Locale('es', 'ES'),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: context.watch<AppProvider>().rolSeleccionado
          ? const HomeScreen()
          : const RolScreen(),
    );
  }
}
