# Implementación de Llamadas a Servicios y Contenidos de la App Móvil
### Gestor de Tareas Escolares — Documentación Técnica

---

## Índice

1. [Arquitectura General](#1-arquitectura-general)
2. [Capa de Servicios de Contenido](#2-capa-de-servicios-de-contenido)
3. [Proveedor de Estado (AppProvider)](#3-proveedor-de-estado-appprovider)
4. [Persistencia Local — SharedPreferences](#4-persistencia-local--sharedpreferences)
5. [Flujo de Datos por Entidad](#5-flujo-de-datos-por-entidad)
6. [Panel del Maestro — Servicios de Grupo](#6-panel-del-maestro--servicios-de-grupo)
7. [Integración con Redes Sociales](#7-integración-con-redes-sociales)
8. [Compartir Tareas](#8-compartir-tareas)
9. [Perfil Público del Alumno](#9-perfil-público-del-alumno)
10. [Plan de Migración a Backend](#10-plan-de-migración-a-backend)

---

## 1. Arquitectura General

La aplicación **Gestor de Tareas Escolares** está desarrollada en **Flutter (Dart)** y sigue una arquitectura de tres capas:

```
┌─────────────────────────────────────────┐
│            UI Layer (Screens)           │
│  HomeScreen · MaestroScreen · Calendari │
│  Estadísticas · Pomodoro · Horario      │
├─────────────────────────────────────────┤
│         State Layer (Provider)          │
│         AppProvider (ChangeNotifier)    │
├─────────────────────────────────────────┤
│        Persistence Layer                │
│  SharedPreferences (JSON serializado)   │
└─────────────────────────────────────────┘
```

### Tecnologías utilizadas

| Paquete | Versión | Propósito |
|---|---|---|
| `flutter` | 3.x | Framework principal |
| `provider` | ^6.0.0 | Gestión de estado |
| `shared_preferences` | ^2.0.0 | Persistencia local |
| `uuid` | ^4.0.0 | Generación de IDs únicos |
| `intl` | ^0.19.0 | Formateo de fechas en español |
| `fl_chart` | ^0.66.0 | Gráficas de estadísticas |
| `share_plus` | ^7.0.0 | Compartir contenido en redes sociales |

---

## 2. Capa de Servicios de Contenido

### 2.1 Modelos de datos

Todos los modelos implementan serialización JSON bidireccional (`toJson` / `fromJson`):

```dart
// Ejemplo: Modelo Tarea
class Tarea {
  final String id;
  String titulo;
  String materiaId;
  DateTime fechaLimite;
  EstadoTarea estado;          // pendiente | enProgreso | entregada
  PrioridadTarea prioridad;    // baja | media | alta
  TipoActividad tipo;          // tarea | examen | quiz | proyecto | ...
  bool asignadoPorMaestro;     // bandera para tareas del maestro
  String? grupoId;             // referencia al grupo si aplica

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
    id: json['id'],
    titulo: json['titulo'],
    asignadoPorMaestro: json['asignadoPorMaestro'] == true,
    ...
  );
}
```

### 2.2 Entidades del sistema

| Entidad | Descripción | Relaciones |
|---|---|---|
| `Materia` | Asignatura con horarios | → Tarea, Nota, Calificacion |
| `Tarea` | Actividad con fecha límite | → Materia, Grupo (opcional) |
| `Nota` | Apunte por materia | → Materia |
| `Calificacion` | Nota ponderada | → Materia |
| `Grupo` | Grupo de alumnos del maestro | → AlumnoGrupo, Tarea, Anuncio |
| `AlumnoGrupo` | Alumno dentro de un grupo | → Grupo |
| `Anuncio` | Comunicado del maestro | → Grupo (opcional, null = todos) |

---

## 3. Proveedor de Estado (AppProvider)

El `AppProvider` es el corazón de la aplicación. Extiende `ChangeNotifier` y centraliza toda la lógica de negocio.

```dart
class AppProvider extends ChangeNotifier {
  List<Materia>      _materias       = [];
  List<Tarea>        _tareas         = [];
  List<Nota>         _notas          = [];
  List<Calificacion> _calificaciones = [];
  List<Grupo>        _grupos         = [];
  List<Anuncio>      _anuncios       = [];
  bool _esMaestro      = false;
  bool _rolSeleccionado = false;
}
```

### 3.1 Ciclo de vida de los datos

```
App Inicia
    │
    ▼
AppProvider.cargar()          ← Lee SharedPreferences
    │
    ▼
Datos en memoria (_materias, _tareas, ...)
    │
    ├── Usuario interactúa → agregarTarea() / editarGrupo() / ...
    │         │
    │         ├── Actualiza lista en memoria
    │         ├── notifyListeners()  ← Reconstruye UI
    │         └── _guardar()         ← Persiste en SharedPreferences
    │
    └── UI siempre lee del estado en memoria (sin llamadas async)
```

### 3.2 Métodos de servicio por entidad

#### Materias
```dart
Future<void> agregarMateria(Materia m)     // POST equivalente
Future<void> editarMateria(Materia m)      // PUT equivalente
Future<void> eliminarMateria(String id)    // DELETE equivalente
Materia? materiaById(String id)            // GET by ID
```

#### Tareas
```dart
Future<void> agregarTarea(Tarea t)
Future<void> editarTarea(Tarea t)
Future<void> cambiarEstadoTarea(String id, EstadoTarea estado)
Future<void> eliminarTarea(String id)

// Queries / filtros
List<Tarea> get tareasPendientes     // tareas sin entregar, ordenadas por fecha
List<Tarea> get tareasHoy            // tareas con fecha límite = hoy
List<Tarea> get tareasVencidas       // tareas con fechaLimite < hoy sin entregar
List<Tarea> tareasDeMateria(String materiaId)
List<Tarea> tareasDeGrupo(String grupoId)
```

#### Grupos y Alumnos
```dart
Future<void> agregarGrupo(Grupo g)
Future<void> editarGrupo(Grupo g)     // También actualiza la lista de alumnos
Future<void> eliminarGrupo(String id) // Elimina en cascada tareas y anuncios

// El alumno es parte del modelo Grupo (lista embebida)
grupo.alumnos.add(AlumnoGrupo(...))
await provider.editarGrupo(grupo)     // Persiste el cambio
```

---

## 4. Persistencia Local — SharedPreferences

Los datos se almacenan como cadenas JSON en el dispositivo. No requieren conexión a internet.

### 4.1 Claves de almacenamiento

| Clave | Tipo | Contenido |
|---|---|---|
| `materias` | `String` (JSON array) | Lista de materias |
| `tareas` | `String` (JSON array) | Lista de tareas |
| `notas` | `String` (JSON array) | Lista de notas |
| `calificaciones` | `String` (JSON array) | Lista de calificaciones |
| `grupos` | `String` (JSON array) | Grupos + alumnos embebidos |
| `anuncios` | `String` (JSON array) | Anuncios del maestro |
| `modoOscuro` | `bool` | Preferencia de tema |
| `esMaestro` | `bool` | Rol activo |
| `rolSeleccionado` | `bool` | Si el usuario ya eligió rol |

### 4.2 Proceso de guardado

```dart
Future<void> _guardar() async {
  final prefs = await SharedPreferences.getInstance();

  // Serializar cada lista a JSON y guardar
  await prefs.setString('materias',
      jsonEncode(_materias.map((m) => m.toJson()).toList()));

  await prefs.setString('grupos',
      jsonEncode(_grupos.map((g) => g.toJson()).toList()));
  // grupos incluye alumnos embebidos en su toJson()

  await prefs.setBool('esMaestro', _esMaestro);
}
```

### 4.3 Proceso de carga

```dart
Future<void> cargar() async {
  final prefs = await SharedPreferences.getInstance();

  final gJson = prefs.getString('grupos');
  if (gJson != null) {
    _grupos = (jsonDecode(gJson) as List)
        .map((e) => Grupo.fromJson(e))  // incluye AlumnoGrupo anidados
        .toList();
  }
}
```

---

## 5. Flujo de Datos por Entidad

### 5.1 Alumno agrega una tarea

```
TareaForm (UI)
    │ usuario llena el form
    ▼
_guardar() en TareaForm
    │ valida campos
    ▼
provider.agregarTarea(Tarea(...))
    │
    ├── _tareas.add(tarea)
    ├── notifyListeners() → HomeScreen, TareasScreen, CalendarioScreen se reconstruyen
    └── _guardar() → SharedPreferences actualizado
```

### 5.2 Maestro asigna tarea a un grupo

```
AsignarTareaScreen (UI)
    │ maestro selecciona materia, grupo, fecha, tipo
    ▼
provider.agregarTarea(Tarea(
  asignadoPorMaestro: true,
  grupoId: grupoSeleccionado,
  ...
))
    │
    └── La tarea aparece en:
        ├── Panel Maestro → Tab "Tareas"    (filtro: asignadoPorMaestro == true)
        └── App Alumno → Dashboard + Tareas (si está en ese grupo)
```

### 5.3 Maestro agrega alumno a grupo

```
GrupoDetailScreen
    │ maestro toca "Agregar alumno"
    ▼
_AgregarAlumnoDialog → retorna AlumnoGrupo
    │
    ▼
grupo.alumnos.add(alumnoGrupo)
provider.editarGrupo(grupo)
    │
    └── SharedPreferences["grupos"] actualizado con nuevo alumno embebido
```

---

## 6. Panel del Maestro — Servicios de Grupo

### 6.1 Pantallas del módulo Maestro

```
MaestroScreen
├── Tab "Grupos"
│   └── GrupoDetailScreen
│       ├── Grid de AlumnoCard (tarjetas con avatar + iniciales)
│       ├── Búsqueda de alumnos
│       └── Agregar / Eliminar alumno
├── Tab "Anuncios"
│   └── AnuncioForm (nuevo / editar)
└── Tab "Tareas"
    └── AsignarTareaScreen
```

### 6.2 Modelo AlumnoGrupo

```dart
class AlumnoGrupo {
  final String id;
  String nombre;
  String apellido;
  int colorValue;      // Color del avatar

  String get nombreCompleto => '$nombre $apellido';
  String get iniciales {
    // "Ana García" → "AG"
    return '${nombre[0]}${apellido[0]}'.toUpperCase();
  }
}
```

### 6.3 Vista de tarjetas de alumnos

Cada alumno se muestra como una tarjeta en un **GridView 2 columnas** con:
- Avatar circular con iniciales y color único
- Nombre y apellidos
- Botón eliminar (esquina superior derecha)
- Búsqueda en tiempo real por nombre

---

## 7. Integración con Redes Sociales

### 7.1 Paquete utilizado: `share_plus`

El paquete `share_plus` invoca el **menú nativo de compartir del sistema operativo**, lo que permite enviar contenido a cualquier app instalada: WhatsApp, Instagram, Telegram, Gmail, etc.

#### Instalación

```yaml
# pubspec.yaml
dependencies:
  share_plus: ^7.2.1
```

#### Uso básico

```dart
import 'package:share_plus/share_plus.dart';

// Compartir texto
await Share.share(
  '¡Tengo un examen de Matemáticas el 15 de abril! 📚',
  subject: 'Recordatorio de tarea',
);

// Compartir imagen + texto
await Share.shareXFiles(
  [XFile(imagePath)],
  text: 'Mi progreso en Gestor de Tareas 📊',
);
```

### 7.2 Permiso en Android

En `android/app/src/main/AndroidManifest.xml` no se requieren permisos adicionales para compartir texto. Para compartir imágenes se necesita acceso a archivos temporales (ya incluido por defecto en Android 10+).

---

## 8. Compartir Tareas

### 8.1 Descripción de la función

El alumno puede compartir una tarea específica como texto formateado. Al tocar "Compartir" en cualquier tarea, se abre el menú nativo del celular para enviarla a WhatsApp, Telegram, notas, etc.

### 8.2 Implementación

```dart
// lib/screens/tareas/tarea_share.dart

import 'package:share_plus/share_plus.dart';

class TareaShare {
  static Future<void> compartirTarea(Tarea tarea, Materia? materia) async {
    final fecha = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_ES')
        .format(tarea.fechaLimite);

    final prioridad = tarea.prioridad == PrioridadTarea.alta
        ? '🔴 Alta'
        : tarea.prioridad == PrioridadTarea.media
            ? '🟡 Media'
            : '🟢 Baja';

    final estado = tarea.estado == EstadoTarea.entregada
        ? '✅ Entregada'
        : tarea.estado == EstadoTarea.enProgreso
            ? '🔄 En progreso'
            : '⏳ Pendiente';

    final texto = '''
📚 *${tarea.titulo}*

📖 Materia: ${materia?.nombre ?? 'Sin materia'}
${tarea.tipo.emoji} Tipo: ${tarea.tipo.label}
📅 Fecha límite: $fecha
🚦 Prioridad: $prioridad
📌 Estado: $estado

${tarea.descripcion.isNotEmpty ? '📝 ${tarea.descripcion}\n' : ''}
_Compartido desde Gestor de Tareas_ 🎓
''';

    await Share.share(texto, subject: tarea.titulo);
  }
}
```

### 8.3 Botón en la tarjeta de tarea

```dart
// Dentro del widget TareaCard o TareaDetailScreen
IconButton(
  icon: const Icon(Icons.share_outlined),
  onPressed: () => TareaShare.compartirTarea(tarea, materia),
)
```

### 8.4 Flujo de compartir

```
Usuario toca ⬆ Share en una tarea
    │
    ▼
TareaShare.compartirTarea(tarea, materia)
    │ formatea el texto con emoji y datos
    ▼
Share.share(texto)
    │
    ▼
Sistema operativo abre menú nativo
    ├── WhatsApp → manda como mensaje
    ├── Instagram Stories → pega en historia
    ├── Telegram → manda a contacto/grupo
    ├── Gmail → abre composición de correo
    └── Notas / Clipboard → copia al portapapeles
```

---

## 9. Perfil Público del Alumno

### 9.1 Descripción

Cada alumno tiene una **tarjeta de perfil** que muestra su información académica y puede ser compartida como imagen. El maestro puede ver la tarjeta de cualquier alumno dentro de sus grupos.

### 9.2 Datos del perfil

```dart
class PerfilAlumno {
  // Información básica
  String nombre;
  String apellido;
  int colorValue;     // color del avatar
  String? fotoUrl;    // opcional

  // Estadísticas (calculadas del provider)
  int totalTareas;
  int tareasCompletadas;
  double progresoGeneral;         // completadas / total
  Map<String, double> promedios;  // materiaId → promedio
  int rachaActual;                // días consecutivos con actividad
}
```

### 9.3 Tarjeta de perfil — Diseño

```
┌─────────────────────────────┐
│  ●●  [Avatar "AG"]          │
│      Ana García López       │
│      6°A Matutino           │
├─────────────────────────────┤
│  Progreso General           │
│  ████████░░░░  72%          │
├─────────────────────────────┤
│  Materias                   │
│  Matemáticas    ████ 8.5    │
│  Programación   █████ 9.5   │
│  Inglés         ████ 9.0    │
├─────────────────────────────┤
│  ✅ 14 entregadas           │
│  ⏳ 4 pendientes            │
│  🔥 7 días de racha         │
├─────────────────────────────┤
│  [⬆ Compartir perfil]       │
└─────────────────────────────┘
```

### 9.4 Implementación de la pantalla

```dart
// lib/screens/perfil/perfil_screen.dart

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _compartirPerfil(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _AvatarHeader(provider: provider),
            _ProgresoGeneral(provider: provider),
            _PromediosPorMateria(provider: provider),
            _EstadisticasRapidas(provider: provider),
          ],
        ),
      ),
    );
  }

  Future<void> _compartirPerfil(BuildContext context, AppProvider provider) async {
    final completadas = provider.totalTareasCompletadas;
    final total = provider.tareas.length;
    final progreso = total > 0 ? (completadas / total * 100).toStringAsFixed(0) : '0';

    final materias = provider.materias.map((m) {
      final prom = provider.promedioMateria(m.id);
      return '${m.nombre}: ${prom.toStringAsFixed(1)}';
    }).join('\n');

    final texto = '''
🎓 *Mi Perfil Académico*

📊 Progreso General: $progreso%
✅ Tareas completadas: $completadas / $total

📚 *Promedios por Materia:*
$materias

_Compartido desde Gestor de Tareas_ ✨
''';

    await Share.share(texto, subject: 'Mi Perfil Académico');
  }
}
```

### 9.5 Vista del Maestro — Tarjetas de todos los alumnos

El maestro puede ver las tarjetas de todos sus alumnos desde `GrupoDetailScreen`. Cada tarjeta muestra:

- **Avatar** con iniciales y color único
- **Nombre completo**
- **Chip de grupo** al que pertenece
- Al tocar la tarjeta → abre el detalle del perfil del alumno

```dart
// GrupoDetailScreen → GridView de _AlumnoCard
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.85,
  ),
  itemBuilder: (ctx, i) => _AlumnoCard(
    alumno: alumnos[i],
    onTap: () => Navigator.push(ctx,
      MaterialPageRoute(builder: (_) =>
        AlumnoDetailScreen(alumno: alumnos[i]))),
  ),
)
```

---

## 10. Plan de Migración a Backend

Actualmente la app funciona **100% offline** con SharedPreferences. Para sincronizar datos entre dispositivos (maestro ↔ alumnos) se puede migrar a un backend.

### 10.1 Opción recomendada: Firebase

```
Firebase Firestore (base de datos en la nube)
    │
    ├── /grupos/{grupoId}
    │     ├── nombre, colorValue, descripcion
    │     └── /alumnos/{alumnoId} → subcolección
    │
    ├── /tareas/{tareaId}
    │     └── materiaId, grupoId, asignadoPorMaestro...
    │
    └── /anuncios/{anuncioId}
          └── titulo, cuerpo, grupoId, fijado...
```

### 10.2 Cambios mínimos necesarios

| Componente | Cambio |
|---|---|
| `AppProvider._guardar()` | Reemplazar `prefs.setString()` por `FirebaseFirestore.instance.collection().set()` |
| `AppProvider.cargar()` | Reemplazar `prefs.getString()` por `.snapshots().listen()` para tiempo real |
| Autenticación | Agregar `firebase_auth` con Google Sign-In |
| Modelos | Sin cambios (ya tienen `toJson/fromJson`) |

### 10.3 Autenticación social

```dart
// Login con Google (Firebase Auth)
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth?.accessToken,
  idToken: googleAuth?.idToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

### 10.4 Roadmap de implementación

| Fase | Descripción | Tiempo estimado |
|---|---|---|
| **Fase 1** (actual) | Datos locales, sin internet, un dispositivo | ✅ Completado |
| **Fase 2** | `share_plus` para compartir tareas y perfil | 1-2 días |
| **Fase 3** | Perfil público del alumno con tarjeta visual | 2-3 días |
| **Fase 4** | Firebase Auth (login con Google) | 3-4 días |
| **Fase 5** | Firestore — sincronización en la nube | 5-7 días |
| **Fase 6** | Notificaciones push (FCM) para anuncios del maestro | 3-4 días |

---

## Resumen

La aplicación implementa un patrón **Repository / Provider** donde:

1. **Los modelos** definen la estructura de datos y su serialización JSON.
2. **AppProvider** actúa como capa de servicio — expone métodos CRUD y queries.
3. **SharedPreferences** es el backend local — JSON serializado en disco del dispositivo.
4. **La UI** solo consume datos del Provider mediante `context.watch<AppProvider>()`, nunca accede al almacenamiento directamente.
5. **share_plus** conecta la app con el ecosistema de redes sociales del dispositivo sin necesidad de APIs externas.
6. **El perfil del alumno** y las **tarjetas del maestro** usan datos calculados en tiempo real del Provider.

