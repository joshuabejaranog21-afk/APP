# Documento Técnico Académico
## Gestor de Materias — Aplicación Móvil y Web para Gestión Académica

**Institución:** Universidad de Monterrey  
**Carrera:** Ingeniería en Sistemas de Información  
**Materia:** Desarrollo de Aplicaciones Móviles  
**Fecha:** Abril 2025  
**Autores:** Joshua Béjar

---

## Índice

1. [Introducción](#1-introducción)
2. [Planteamiento del problema](#2-planteamiento-del-problema)
3. [Objetivos](#3-objetivos)
4. [Marco teórico](#4-marco-teórico)
5. [Arquitectura del sistema](#5-arquitectura-del-sistema)
6. [Modelos de datos](#6-modelos-de-datos)
7. [Módulos y funcionalidades](#7-módulos-y-funcionalidades)
8. [Tecnologías utilizadas](#8-tecnologías-utilizadas)
9. [Base de datos](#9-base-de-datos)
10. [Seguridad y autenticación](#10-seguridad-y-autenticación)
11. [Pruebas](#11-pruebas)
12. [Conclusiones](#12-conclusiones)
13. [Referencias](#13-referencias)

---

## 1. Introducción

En el contexto educativo actual, la gestión de actividades académicas representa un reto significativo para alumnos, docentes y administradores. La necesidad de centralizar información como materias, tareas, calificaciones, horarios y documentos de estudio en una sola plataforma motivó el desarrollo de **Gestor de Materias**.

Esta aplicación fue desarrollada con **Flutter**, un framework de código abierto de Google que permite compilar para Android, iOS y web desde una única base de código en Dart. El backend se apoya en **Supabase**, una plataforma de base de datos en la nube basada en PostgreSQL que ofrece autenticación, almacenamiento y APIs REST de forma nativa.

---

## 2. Planteamiento del problema

Los estudiantes universitarios frecuentemente enfrentan:

- **Desorganización:** tareas anotadas en múltiples apps o cuadernos
- **Falta de visibilidad:** dificultad para ver todas las fechas límite en un solo lugar
- **Desconexión alumno-maestro:** ausencia de un canal centralizado para entregas y calificaciones
- **Gestión administrativa deficiente:** sin herramientas unificadas para administrar materias, grupos y profesores

Gestor de Materias resuelve estos problemas mediante una plataforma integral con roles diferenciados para cada actor del proceso educativo.

---

## 3. Objetivos

### Objetivo general
Desarrollar una aplicación móvil y web multiplataforma que centralice la gestión académica para alumnos, maestros y administradores educativos.

### Objetivos específicos
- Implementar autenticación segura con Supabase Auth
- Permitir la gestión completa (CRUD) de materias, tareas y calificaciones
- Desarrollar un sistema de entrega de tareas con texto y archivos adjuntos
- Integrar un visor de PDF con anotaciones y asistente de inteligencia artificial
- Implementar un panel de maestro para calificar entregas
- Crear un panel administrativo para gestionar la estructura académica
- Garantizar compatibilidad con Android y web

---

## 4. Marco teórico

### 4.1 Flutter y Dart
Flutter es un SDK de desarrollo de interfaces de usuario creado por Google. Utiliza Dart como lenguaje de programación y compila el código a código nativo, lo que permite un alto rendimiento en múltiples plataformas. La arquitectura de widgets reactivos de Flutter permite construir interfaces declarativas eficientes.

### 4.2 Patrón Provider (ChangeNotifier)
El proyecto utiliza el patrón **Provider** para la gestión de estado global. `AppProvider` extiende `ChangeNotifier` y centraliza todos los datos de la aplicación. Las pantallas observan cambios mediante `context.watch<AppProvider>()` y se reconstruyen automáticamente cuando el estado cambia.

### 4.3 Supabase
Supabase es una alternativa de código abierto a Firebase, construida sobre PostgreSQL. Proporciona:
- **Auth:** sistema de autenticación con JWT
- **Database:** PostgreSQL con Row Level Security (RLS)
- **Storage:** almacenamiento de archivos en la nube
- **Realtime:** suscripciones en tiempo real (WebSocket)

### 4.4 Arquitectura Clean (simplificada)
El proyecto sigue una arquitectura por capas:
- **Presentación:** pantallas Flutter (`screens/`)
- **Lógica de negocio:** providers (`providers/`)
- **Datos:** modelos y servicios (`models/`, `services/`)

---

## 5. Arquitectura del sistema

```
┌─────────────────────────────────────────────────┐
│                  CLIENTE FLUTTER                │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │  Alumno  │  │  Maestro │  │    Admin     │  │
│  │  Panel   │  │  Panel   │  │    Panel     │  │
│  └────┬─────┘  └────┬─────┘  └──────┬───────┘  │
│       └─────────────┴────────────────┘          │
│                     │                           │
│            ┌────────▼────────┐                  │
│            │   AppProvider   │                  │
│            │ (Estado Global) │                  │
│            └────────┬────────┘                  │
│                     │                           │
│      ┌──────────────┼──────────────┐            │
│      │              │              │            │
│  ┌───▼───┐    ┌─────▼─────┐  ┌────▼────┐       │
│  │  API  │    │  Claude   │  │ Notif.  │       │
│  │Service│    │  Service  │  │ Service │       │
│  └───┬───┘    └─────┬─────┘  └─────────┘       │
└──────┼───────────────┼─────────────────────────┘
       │               │
┌──────▼───────┐ ┌─────▼──────┐
│  Supabase    │ │ Claude API │
│ (PostgreSQL) │ │(Anthropic) │
└──────────────┘ └────────────┘
```

### Flujo de datos
1. El usuario interactúa con una pantalla Flutter
2. La pantalla llama a un método del `AppProvider`
3. El provider actualiza el estado local y llama al `ApiService`
4. El `ApiService` ejecuta operaciones en Supabase
5. El provider notifica a los listeners con `notifyListeners()`
6. Las pantallas se reconstruyen con los nuevos datos

---

## 6. Modelos de datos

### Tarea
```dart
class Tarea {
  String id, titulo, descripcion, materiaId;
  DateTime fechaLimite, fechaCreacion;
  EstadoTarea estado;         // pendiente | enProgreso | entregada
  PrioridadTarea prioridad;   // baja | media | alta
  TipoActividad tipo;         // tarea | examen | quiz | proyecto...
  List<SubtareaItem> subtareas;
  EntregaTarea? entrega;
  bool asignadoPorMaestro, esRecurrente;
}
```

### EntregaTarea
```dart
class EntregaTarea {
  String texto;
  List<String> archivos;
  DateTime fecha;
  double? calificacion;       // 0.0 – 10.0
  String retroalimentacion;
  DateTime? fechaCalificacion;
}
```

### Materia
```dart
class Materia {
  String id, nombre, profesor, aula, icono;
  int colorValue;
  double notaObjetivo;
  List<HorarioMateria> horarios;
  List<Calificacion> calificaciones;
}
```

### EstudioPDF
```dart
class EstudioPDF {
  String id, titulo, rutaLocal;
  String? urlSupabase;
  List<NotaPDF> notas;
  List<MensajeIA> historialIA;
  int ultimaPagina, totalPaginas;
  Uint8List? bytes;             // web-only
}
```

### Profesor
```dart
class Profesor {
  String id, nombre, email, especialidad;
}
```

### AlumnoGrupo
```dart
class AlumnoGrupo {
  String id, nombre, apellido;
  int colorValue;
}
```

---

## 7. Módulos y funcionalidades

### 7.1 Autenticación (`screens/auth/`)
- Login con email y contraseña via Supabase Auth
- Registro de nuevos usuarios con metadata (nombre)
- Modo invitado (sin cuenta, datos locales)
- Persistencia de sesión en `SharedPreferences`
- Restauración automática de sesión activa de Supabase

### 7.2 Gestión de Materias (`screens/materias/`)
- CRUD completo de materias con validación
- Selección de color con paleta de 12 colores
- Selección de ícono representativo
- Configuración de horario por días y horas
- Registro de calificaciones parciales con promedio automático
- Notas rápidas por materia

### 7.3 Gestión de Tareas (`screens/tareas/`)
- Creación con 8 tipos de actividad, 3 niveles de prioridad y fecha límite
- Subtareas con checkbox individual
- Tareas recurrentes (clonan automáticamente a 7 días)
- Filtrado por estado (pendiente / en progreso / entregada)
- Ordenamiento por fecha, prioridad o tipo
- Deslizar para completar, editar o eliminar (flutter_slidable)
- Notificaciones locales con recordatorio 1 hora antes

### 7.4 Entrega de Tareas (`screens/tareas/entrega_screen.dart`)
- Respuesta escrita con campo de texto multilínea
- Adjuntar múltiples archivos (PDF, Word, imágenes)
- Compatibilidad web (usa `bytes`) y nativa (usa `path`)
- Vista de entrega previa con estado y fecha
- Marca automáticamente la tarea como "Entregada"

### 7.5 Visor de PDFs (`screens/pdfs/`)
- Carga de PDFs desde el almacenamiento local
- Compatible con web (bytes en memoria) y Android (ruta de archivo)
- Anotaciones por página con 4 colores
- Selección de texto con barra de acciones
- Texto a voz (TTS) del texto seleccionado o las notas
- Chat con IA (Claude API) sobre fragmentos seleccionados
- Timer Pomodoro integrado en el visor
- Persistencia de página actual y notas

### 7.6 Calendario (`screens/calendario/`)
- Calendario mensual interactivo (table_calendar)
- Puntos de color por materia en días con tareas
- Vista de tareas del día seleccionado
- Agregar tareas directamente desde el calendario

### 7.7 Horario (`screens/horario/`)
- Vista semanal con bloques de tiempo
- Generado automáticamente desde los horarios de cada materia
- Colores consistentes con la materia correspondiente

### 7.8 Pomodoro (`screens/pomodoro/`)
- Temporizador configurable (trabajo / descanso corto / descanso largo)
- Notificación al terminar cada ciclo
- Registro automático de sesiones de estudio
- Contador de racha de días estudiados

### 7.9 Panel Maestro (`screens/maestro/`)
- **Grupos:** CRUD con lista de alumnos
- **Anuncios:** publicación con opción de fijar y filtrar por grupo
- **Tareas asignadas:** vista de tareas creadas para grupos
- **Calificar:** lista de entregas pendientes y calificadas, con slider y retroalimentación

### 7.10 Panel Administrador (`screens/admin/`)
- **Materias:** CRUD completo
- **Grupos:** CRUD con lista expandible de alumnos
- **Profesores:** CRUD con asignación de materias
- **Alumnos:** CRUD con asignación y cambio de grupo

---

## 8. Tecnologías utilizadas

| Dependencia | Versión | Propósito |
|------------|---------|-----------|
| `flutter` | 3.41 | Framework UI |
| `provider` | 6.1.2 | Gestión de estado |
| `supabase_flutter` | 2.5.0 | Backend y autenticación |
| `shared_preferences` | 2.3.2 | Persistencia local |
| `pdfrx` | 1.0.106 | Visor de PDFs |
| `flutter_tts` | 4.0.2 | Texto a voz |
| `file_picker` | 8.0.0 | Selector de archivos |
| `flutter_local_notifications` | 18.0.1 | Notificaciones push locales |
| `table_calendar` | 3.1.2 | Calendario interactivo |
| `fl_chart` | 0.69.0 | Gráficas y estadísticas |
| `flutter_slidable` | 3.1.1 | Gestos deslizables en listas |
| `google_fonts` | 6.2.1 | Tipografía |
| `uuid` | 4.4.2 | Generación de IDs únicos |
| `http` | 1.2.1 | Peticiones HTTP (Claude API) |
| `intl` | 0.20.2 | Internacionalización y fechas |
| `path_provider` | 2.1.3 | Rutas de almacenamiento |
| `share_plus` | 10.0.0 | Compartir contenido |
| `percent_indicator` | 4.2.3 | Indicadores de progreso |

---

## 9. Base de datos

### Diseño del esquema

La base de datos está alojada en Supabase (PostgreSQL). Las tablas principales almacenan datos en formato JSONB para máxima flexibilidad:

```sql
-- Tablas principales
materias    (id TEXT PRIMARY KEY, data JSONB)
tareas      (id TEXT PRIMARY KEY, data JSONB)
calificaciones (id TEXT PRIMARY KEY, data JSONB)
notas       (id TEXT PRIMARY KEY, data JSONB)
grupos      (id TEXT PRIMARY KEY, data JSONB)
anuncios    (id TEXT PRIMARY KEY, data JSONB)
```

### Estrategia de persistencia

El proyecto utiliza **persistencia en dos capas**:

1. **Local (SharedPreferences):** todos los datos se serializan a JSON y se guardan localmente para funcionamiento offline
2. **Remoto (Supabase):** sincronización con la base de datos en la nube para respaldo y acceso multi-dispositivo

```
Usuario interactúa
        ↓
AppProvider actualiza estado en memoria
        ↓
SharedPreferences.save() — guardado local inmediato
        ↓
ApiService.sync() — sincronización con Supabase
```

### Seguridad con RLS

Supabase implementa **Row Level Security (RLS)** para que cada usuario solo pueda acceder a sus propios datos:

```sql
-- Ejemplo de política RLS
CREATE POLICY "Users can only access own data"
ON materias
FOR ALL
USING (auth.uid() = user_id);
```

---

## 10. Seguridad y autenticación

### Flujo de autenticación
```
Pantalla Login
     ↓
Supabase.auth.signInWithPassword(email, password)
     ↓
JWT Token (almacenado automáticamente por Supabase SDK)
     ↓
AppProvider.setUserInfo(nombre, email)
     ↓
Routing → pantalla principal según rol
```

### Restauración de sesión
Al iniciar la app, `AppProvider.cargar()` verifica si existe una sesión activa en Supabase:
```dart
final session = Supabase.instance.client.auth.currentSession;
if (session != null) {
  _isAuthenticated = true;
  _userName = session.user.userMetadata?['nombre'] ?? email;
}
```

### Protección de rutas
El routing principal en `main.dart` verifica el estado de autenticación antes de mostrar cualquier pantalla:
```dart
home: !provider.isAuthenticated
    ? LoginScreen()
    : !provider.rolSeleccionado
        ? RolScreen()
        : provider.esAdmin ? AdminScreen()
        : provider.esMaestro ? MaestroScreen()
        : HomeScreen()
```

---

## 11. Pruebas

### Pruebas realizadas

| Módulo | Escenario | Resultado |
|--------|----------|-----------|
| Autenticación | Login con credenciales válidas | ✅ Correcto |
| Autenticación | Login con contraseña incorrecta | ✅ Muestra error |
| Autenticación | Registro con correo duplicado | ✅ Muestra error |
| Tareas | Crear tarea con todos los campos | ✅ Correcto |
| Tareas | Entregar tarea con archivo PDF | ✅ Correcto |
| Tareas | Cambiar estado con deslizamiento | ✅ Correcto |
| PDFs | Cargar PDF en Android | ✅ Correcto |
| PDFs | Cargar PDF en web (bytes) | ✅ Correcto |
| PDFs | TTS sobre texto seleccionado | ✅ Correcto |
| Maestro | Calificar entrega con slider | ✅ Correcto |
| Admin | Crear alumno y asignar a grupo | ✅ Correcto |
| Admin | Cambiar alumno de grupo | ✅ Correcto |
| Persistencia | Datos disponibles sin conexión | ✅ Correcto |
| Modo oscuro | Cambio de tema en tiempo real | ✅ Correcto |

### Dispositivos de prueba
- Emulador Android (API 37 — Android 14)
- Microsoft Edge (web)

---

## 12. Conclusiones

El desarrollo de **Gestor de Materias** permitió aplicar de forma práctica conceptos fundamentales de desarrollo de software multiplataforma:

- **Flutter** demostró ser un framework maduro y eficiente para construir aplicaciones con alta calidad visual en múltiples plataformas desde una única base de código.

- El patrón **Provider con ChangeNotifier** resultó adecuado para la escala del proyecto, permitiendo una gestión de estado reactiva sin complejidad innecesaria.

- **Supabase** ofrece una solución backend completa con autenticación, base de datos y almacenamiento, acelerando significativamente el desarrollo sin sacrificar seguridad.

- La integración de **Claude AI** de Anthropic enriqueció la funcionalidad del visor de PDFs, permitiendo a los estudiantes interactuar con el contenido de sus documentos de forma inteligente.

- La arquitectura de roles diferenciados (Alumno, Maestro, Administrador) demostró ser escalable y mantenible, con cada módulo bien delimitado y fácil de extender.

**Trabajo futuro:**
- Notificaciones push remotas con Firebase Cloud Messaging
- Soporte iOS completo
- Modo colaborativo en tiempo real (Supabase Realtime)
- Exportación de calificaciones a PDF/Excel
- Integración con plataformas LMS (Moodle, Canvas)

---

## 13. Referencias

- Flutter Documentation. (2025). *Flutter — Build apps for any screen*. https://flutter.dev/docs
- Google. (2025). *Dart programming language*. https://dart.dev
- Supabase. (2025). *Supabase Docs*. https://supabase.com/docs
- Anthropic. (2025). *Claude API Documentation*. https://docs.anthropic.com
- Rivest, R. (1992). *The MD5 Message-Digest Algorithm*. RFC 1321.
- Martin, R. C. (2017). *Clean Architecture: A Craftsman's Guide to Software Structure and Design*. Prentice Hall.
- Google Material Design. (2025). *Material Design 3*. https://m3.material.io

---

*Documento generado para Gestor de Materias v1.0 — Ingeniería en Sistemas de Información — Abril 2025*
