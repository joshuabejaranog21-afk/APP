<div align="center">

# 🎓 Gestor de Materias

### La plataforma académica todo-en-uno para alumnos, maestros y administradores

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.5-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Claude AI](https://img.shields.io/badge/Claude_AI-Anthropic-FF6B35?style=for-the-badge&logo=anthropic&logoColor=white)](https://anthropic.com)

<br/>

[![Android](https://img.shields.io/badge/Android-6.0+-3DDC84?style=flat-square&logo=android&logoColor=white)](https://android.com)
[![Web](https://img.shields.io/badge/Web-Chrome%20%7C%20Edge-4285F4?style=flat-square&logo=googlechrome&logoColor=white)](https://flutter.dev/web)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](CONTRIBUTING.md)

<br/>

> **Gestor de Materias** centraliza toda la vida académica en una sola app: organiza tus materias, entrega tareas, estudia con IA, califica como maestro y administra tu institución — todo desde Android o la web.

<br/>

[📖 Manual de Usuario](MANUAL_USUARIO.md) · [📄 Documento Técnico](DOCUMENTO_ACADEMICO.md) · [🐛 Reportar bug](https://github.com/tu-usuario/gestor-materias/issues) · [✨ Solicitar feature](https://github.com/tu-usuario/gestor-materias/issues)

</div>

---

## 📸 Vista previa

<div align="center">

| Login | Dashboard | Tareas |
|:-----:|:---------:|:------:|
| ![login](https://via.placeholder.com/200x400/6750A4/white?text=Login) | ![dashboard](https://via.placeholder.com/200x400/6750A4/white?text=Dashboard) | ![tareas](https://via.placeholder.com/200x400/6750A4/white?text=Tareas) |

| PDF + IA | Panel Maestro | Panel Admin |
|:--------:|:-------------:|:-----------:|
| ![pdf](https://via.placeholder.com/200x400/6750A4/white?text=PDF+%2B+IA) | ![maestro](https://via.placeholder.com/200x400/6750A4/white?text=Maestro) | ![admin](https://via.placeholder.com/200x400/6750A4/white?text=Admin) |

</div>

---

## ✨ ¿Qué hace esta app?

<table>
<tr>
<td width="50%">

### 👨‍🎓 Para el Alumno
- 📚 Gestiona tus **materias** con color, ícono y horario
- ✅ Crea y organiza **tareas** con subtareas y prioridades
- 📤 **Entrega** trabajos con texto o archivos adjuntos
- 📄 Lee **PDFs** y chatea con IA sobre el contenido
- 🔊 Escucha tus apuntes con **texto a voz**
- ⏱️ Técnica **Pomodoro** para sesiones de estudio
- 📅 **Calendario** con todas tus fechas límite
- 🕐 **Horario semanal** de clases

</td>
<td width="50%">

### 👨‍🏫 Para el Maestro
- 👥 Crea y gestiona **grupos** de alumnos
- 📢 Publica **anuncios** por grupo o para todos
- 📝 **Asigna tareas** a grupos completos
- ✔️ **Califica** entregas con slider 0–10
- 💬 Escribe **retroalimentación** personalizada
- 📊 Ve qué entregas están **pendientes** de calificar

### 🛡️ Para el Administrador
- 🏫 CRUD completo de **materias**
- 👥 Gestiona **grupos** y sus listas de alumnos
- 👨‍🏫 Registra **profesores** y asígnalos a materias
- 🎓 Administra **alumnos** y cámbialos de grupo

</td>
</tr>
</table>

---

## 🚀 Inicio rápido

### Prerrequisitos

```bash
flutter --version   # >= 3.10
dart --version      # >= 3.0
```

También necesitas:
- [Android Studio](https://developer.android.com/studio) con un emulador configurado
- Una cuenta gratuita en [Supabase](https://supabase.com)
- *(Opcional)* API Key de [Anthropic](https://console.anthropic.com) para el chat IA

---

### ⚡ Instalación en 4 pasos

**1. Clona el repo**
```bash
git clone https://github.com/tu-usuario/gestor-materias.git
cd gestor-materias/APP/gestor_materias
```

**2. Instala dependencias**
```bash
flutter pub get
```

**3. Configura Supabase**

Abre `lib/services/api_service.dart` y reemplaza las credenciales:
```dart
const String supabaseUrl     = 'https://TU_PROYECTO.supabase.co';
const String supabaseAnonKey = 'TU_ANON_KEY';
```

Luego ejecuta los scripts en el **SQL Editor** de Supabase:
```
📁 supabase_schema.sql        ← crea las tablas
📁 supabase_seed.sql          ← datos de prueba (opcional)
📁 supabase_storage_setup.sql ← configura el bucket de archivos
```

**4. Corre la app**
```bash
flutter run                   # detecta dispositivo automáticamente
flutter run -d emulator-5554  # emulador Android específico
flutter run -d chrome         # navegador web
flutter build apk --release   # genera el APK
```

---

## 🏗️ Arquitectura

El proyecto sigue una arquitectura **Clean por capas** con estado reactivo:

```
┌─────────────────────────────────────────────────────┐
│                    PRESENTACIÓN                     │
│  screens/ → 24 pantallas organizadas por módulo     │
└──────────────────────┬──────────────────────────────┘
                       │ watch / read
┌──────────────────────▼──────────────────────────────┐
│               LÓGICA DE NEGOCIO                     │
│  AppProvider (ChangeNotifier) — estado global       │
│  ~750 líneas · gestiona todos los modelos           │
└──────────────────────┬──────────────────────────────┘
                       │ call
┌──────────────────────▼──────────────────────────────┐
│                     DATOS                           │
│  ApiService → Supabase (PostgreSQL)                 │
│  SharedPreferences → persistencia local (offline)   │
│  ClaudeService → Anthropic API (IA)                 │
└─────────────────────────────────────────────────────┘
```

```
lib/
├── main.dart                       # Routing dinámico por rol
├── models/
│   ├── tarea.dart                  # Tarea + EntregaTarea + calificación
│   ├── materia.dart                # Materia + horario + calificaciones
│   ├── grupo.dart                  # Grupo + AlumnoGrupo
│   ├── profesor.dart               # Profesor
│   ├── nota.dart                   # Nota rápida
│   └── estudio_pdf.dart            # PDF + notas + historial IA
├── providers/
│   └── app_provider.dart           # Estado global · offline-first
├── screens/
│   ├── auth/         login_screen.dart
│   ├── admin/        admin_screen.dart
│   ├── maestro/      maestro_screen · calificar · asignar · grupos
│   ├── tareas/       tareas_screen · entrega_screen · tarea_form
│   ├── materias/     materias_screen · materia_detail · materia_form
│   ├── pdfs/         pdfs_screen · pdf_viewer_screen
│   ├── calendario/   calendario_screen
│   ├── horario/      horario_screen
│   ├── pomodoro/     pomodoro_screen
│   ├── perfil/       perfil_screen
│   └── rol/          rol_screen
├── services/
│   ├── api_service.dart            # CRUD completo con Supabase
│   ├── claude_service.dart         # Chat IA sobre PDFs
│   └── notification_service.dart   # Recordatorios locales
└── theme/
    └── app_theme.dart              # Material Design 3 · claro/oscuro
```

---

## 🔧 Stack tecnológico

<div align="center">

| Capa | Tecnología | Versión | Propósito |
|------|-----------|---------|-----------|
| **UI** | Flutter | 3.41 | Framework multiplataforma |
| **Lenguaje** | Dart | 3.x | Tipado fuerte, async/await |
| **Backend** | Supabase | 2.5 | PostgreSQL + Auth + Storage |
| **Estado** | Provider | 6.1 | ChangeNotifier reactivo |
| **PDF** | pdfrx | 1.0 | Render, selección, notas |
| **IA** | Claude API | claude-3 | Chat contextual en PDFs |
| **TTS** | flutter_tts | 4.0 | Lectura en voz alta |
| **Archivos** | file_picker | 8.0 | Adjuntar PDF, Word, imágenes |
| **Notifs** | local_notifications | 18 | Recordatorios de tareas |
| **Calendario** | table_calendar | 3.1 | Vista mensual interactiva |
| **Gráficas** | fl_chart | 0.69 | Estadísticas de estudio |
| **Gestos** | flutter_slidable | 3.1 | Deslizar para acciones |

</div>

---

## 🗄️ Base de datos

El proyecto incluye 3 scripts SQL listos para ejecutar en Supabase:

```bash
📄 supabase_schema.sql          # Estructura de tablas + RLS policies
📄 supabase_seed.sql            # Datos de prueba (materias, tareas, grupos)
📄 supabase_storage_setup.sql   # Bucket para archivos adjuntos
```

**Estrategia offline-first:** todos los datos se guardan localmente en `SharedPreferences` y se sincronizan con Supabase, permitiendo que la app funcione sin conexión.

---

## 🔐 Autenticación y roles

```
Supabase Auth (JWT)
        ↓
┌───────────────────────────────┐
│       Selección de Rol        │
├──────────┬──────────┬─────────┤
│  Alumno  │  Maestro │  Admin  │
│  🎓      │   👨‍🏫   │   🛡️   │
│HomeScreen│ Maestro  │ Admin   │
│          │  Screen  │ Screen  │
└──────────┴──────────┴─────────┘
```

---

## 📱 Compatibilidad

| Plataforma | Estado | Notas |
|-----------|--------|-------|
| 🤖 Android 6.0+ | ✅ Completo | APK 38.5 MB |
| 🌐 Chrome / Edge | ✅ Completo | Archivos en memoria |
| 🍎 iOS | 🔄 En desarrollo | Requiere firma de código |
| 🖥️ Windows | 🔄 En desarrollo | Próxima versión |

---

## 📂 Documentación

| Documento | Descripción |
|-----------|-------------|
| [📖 Manual de Usuario](MANUAL_USUARIO.md) | Guía paso a paso para cada rol |
| [📄 Documento Académico](DOCUMENTO_ACADEMICO.md) | Arquitectura, metodología, resultados y conclusiones |
| [🗃️ Schema SQL](../supabase_schema.sql) | Estructura completa de la base de datos |

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si quieres mejorar el proyecto:

1. Haz un **Fork** del repositorio
2. Crea una rama con tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Haz commit de tus cambios: `git commit -m 'feat: agregar nueva funcionalidad'`
4. Push a la rama: `git push origin feature/nueva-funcionalidad`
5. Abre un **Pull Request**

---

## 📖 Manual de Usuario

<details>
<summary><b>👆 Haz clic para expandir el Manual de Usuario completo</b></summary>

<br/>

### Índice del manual

1. [Introducción](#introducción)
2. [Requisitos del sistema](#requisitos-del-sistema)
3. [Inicio de sesión](#inicio-de-sesión)
4. [Selección de rol](#selección-de-rol)
5. [Rol Alumno](#rol-alumno)
6. [Rol Maestro](#rol-maestro)
7. [Rol Administrador](#rol-administrador)
8. [Cerrar sesión](#cerrar-sesión)

---

### Introducción

**Gestor de Materias** es una aplicación académica que permite a alumnos, maestros y administradores gestionar de forma centralizada toda la actividad escolar: tareas, materias, calificaciones, horarios, documentos PDF y más.

La app cuenta con tres roles diferenciados, cada uno con su propio panel adaptado a sus necesidades.

---

### Requisitos del sistema

| Plataforma | Requisito mínimo |
|-----------|-----------------|
| Android | Versión 6.0 (API 23) o superior |
| Web | Chrome 90+ o Edge 90+ |
| Conexión | Internet para autenticación y sincronización |

---

### Inicio de sesión

Al abrir la app por primera vez verás la pantalla de **inicio de sesión**.

**Iniciar sesión con cuenta existente**
1. Ingresa tu **correo electrónico** y **contraseña**
2. Toca **"Iniciar sesión"**

**Crear cuenta nueva**
1. Toca **"¿No tienes cuenta? Regístrate"**
2. Completa: nombre completo, correo y contraseña (mínimo 6 caracteres)
3. Confirma la contraseña y toca **"Crear cuenta"**

**Continuar sin cuenta**
- Toca **"Continuar sin cuenta"** para entrar como Invitado
- Los datos se guardarán solo en el dispositivo

---

### Selección de rol

Después de iniciar sesión, elige cómo deseas ingresar:

| Tarjeta | Descripción |
|---------|-------------|
| 🎓 **Soy Alumno** | Acceso al panel de gestión personal |
| 👨‍🏫 **Soy Maestro** | Acceso al panel de docente |
| 🛡️ **Administrador** | Acceso al panel de administración |

> Puedes cambiar de rol en cualquier momento cerrando sesión o usando el ícono ⇄ en los paneles de Maestro y Admin.

---

### Rol Alumno

#### Dashboard (Inicio)
La pantalla de inicio muestra:
- **Saludo personalizado** con tu nombre
- **Resumen** de tareas pendientes y materias activas
- **Frase del día** motivacional
- **Racha de estudio** si llevas días consecutivos estudiando

#### Materias
- **Agregar:** Toca **+** → ingresa nombre, profesor, aula, color, ícono y horario → Guardar
- **Editar:** Toca el ícono de lápiz dentro del detalle de la materia
- **Eliminar:** Desliza la materia a la izquierda en la lista

#### Tareas

**Crear tarea:**
1. Toca el botón **+**
2. Completa título, descripción, materia, fecha límite, prioridad y tipo
3. Agrega subtareas opcionales
4. Toca **"Guardar"**

**Estados de una tarea:**

| Ícono | Estado | Descripción |
|-------|--------|-------------|
| ⚪ | Pendiente | Recién creada |
| 🔵 | En progreso | Siendo trabajada |
| ✅ | Entregada | Completada |

**Entregar tarea:**
1. Dentro de la card, toca **"Entregar"**
2. Escribe tu respuesta (opcional)
3. Adjunta archivos PDF, Word o imágenes (opcional)
4. Toca el FAB verde **"Entregar"**

#### PDFs (Documentos)

| Función | Cómo usarla |
|---------|-------------|
| 📝 Agregar nota | Ícono de nota en barra inferior |
| 🔊 Escuchar texto | Selecciona texto → ícono de audio |
| 🤖 Preguntar a la IA | Selecciona texto → ícono de IA |
| ⏱️ Pomodoro | Ícono del temporizador |

#### Calendario
- Vista mensual con puntos de color por materia
- Toca un día para ver las tareas de esa fecha

#### Pomodoro
1. Ve a la pantalla **Pomodoro** desde el menú
2. Toca **▶ Iniciar** — por defecto 25 min trabajo / 5 min descanso
3. Configura los tiempos en **Ajustes del Pomodoro**

#### Perfil
- Activa/desactiva el **modo oscuro**
- Configura la **API Key de Claude** para el chat IA
- Consulta tu **racha de estudio**
- Toca **"Cerrar sesión"** para salir

---

### Rol Maestro

#### Tab Grupos
1. FAB → **"Nuevo grupo"**
2. Ingresa nombre, color y descripción
3. Agrega alumnos con nombre y apellido

#### Tab Anuncios
1. FAB → **"Nuevo anuncio"**
2. Escribe título y contenido
3. Selecciona grupo destinatario (o todos)
4. Activa **"Fijado"** para que aparezca siempre primero

#### Tab Tareas
- FAB → **"Asignar tarea"** → selecciona grupo, fecha y descripción

#### Tab Calificar
1. Toca una tarea entregada
2. Lee la respuesta del alumno y archivos adjuntos
3. Mueve el slider para la **calificación** (0 – 10)
4. Escribe **retroalimentación** (opcional)
5. Toca **"Guardar calificación"**

---

### Rol Administrador

#### Tab Materias
- **Agregar:** FAB → nombre, profesor, aula → Agregar
- **Editar:** Tres puntos → Editar
- **Eliminar:** Tres puntos → Eliminar

#### Tab Grupos
- Vista expandible con lista de alumnos por grupo
- **Nuevo grupo:** FAB → nombre y descripción

#### Tab Profesores
- **Agregar:** FAB → nombre, correo, especialidad
- **Asignar materia:** Tres puntos → "Asignar materia" → selecciona materia
- **Editar / Eliminar:** Tres puntos → opción correspondiente

#### Tab Alumnos
- **Agregar:** FAB → nombre, apellido y grupo
- **Cambiar de grupo:** Tres puntos → "Cambiar grupo"
- **Editar / Eliminar:** Tres puntos → opción correspondiente

---

### Cerrar sesión

1. Ve a **Perfil** (última pestaña)
2. Desplázate al final
3. Toca **"Cerrar sesión"** y confirma

</details>

---

## 📄 Documento Técnico Académico

<details>
<summary><b>👆 Haz clic para expandir el Documento Técnico Académico completo</b></summary>

<br/>

> **Institución:** Universidad de Monterrey · **Carrera:** Ingeniería en Sistemas de Información · **Fecha:** Abril 2025 · **Autor:** Joshua Béjar

---

### Resumen

El presente documento describe el diseño, desarrollo e implementación de **Gestor de Materias**, una aplicación móvil y web multiplataforma orientada a la gestión académica integral. La aplicación fue construida con Flutter y Dart, empleando Supabase como backend en la nube, y ofrece tres roles diferenciados: Alumno, Maestro y Administrador. Entre sus funcionalidades principales destacan la gestión de materias y tareas, entrega de trabajos con archivos adjuntos, calificación docente, visualización de PDFs con anotaciones e inteligencia artificial, y un panel administrativo completo.

**Palabras clave:** Flutter, Dart, Supabase, gestión académica, aplicación móvil, inteligencia artificial, roles de usuario, entrega de tareas, calificación.

---

### 1. Introducción

En el contexto educativo actual, la gestión de actividades académicas representa un reto significativo para alumnos, docentes y administradores. La necesidad de centralizar información como materias, tareas, calificaciones, horarios y documentos de estudio en una sola plataforma motivó el desarrollo de **Gestor de Materias**.

Esta aplicación fue desarrollada con **Flutter**, framework de código abierto de Google que permite compilar para Android, iOS y web desde una única base de código en Dart. El backend se apoya en **Supabase**, plataforma basada en PostgreSQL que ofrece autenticación, almacenamiento y APIs REST.

---

### 2. Planteamiento del problema

Los estudiantes universitarios frecuentemente enfrentan:
- **Desorganización:** tareas en múltiples apps o cuadernos sin centralizar
- **Falta de visibilidad:** sin vista unificada de fechas límite
- **Desconexión alumno-maestro:** sin canal centralizado para entregas y calificaciones
- **Gestión administrativa deficiente:** sin herramientas para administrar materias, grupos y profesores

---

### 3. Objetivos

**General:** Desarrollar una aplicación móvil y web multiplataforma que centralice la gestión académica para alumnos, maestros y administradores.

**Específicos:**
- Implementar autenticación segura con Supabase Auth
- Gestión completa (CRUD) de materias, tareas y calificaciones
- Sistema de entrega de tareas con texto y archivos adjuntos
- Visor de PDF con anotaciones e inteligencia artificial
- Panel de maestro para calificar entregas
- Panel administrativo para gestionar la estructura académica
- Compatibilidad con Android y web desde una sola base de código

---

### 4. Marco teórico

**Flutter y Dart:** SDK de desarrollo de Google que compila a código nativo con alto rendimiento. Su arquitectura de widgets reactivos permite construir interfaces declarativas eficientes.

**Patrón Provider:** `AppProvider` extiende `ChangeNotifier` y centraliza todos los datos. Las pantallas observan cambios con `context.watch<AppProvider>()` y se reconstruyen automáticamente.

**Supabase:** Alternativa open-source a Firebase sobre PostgreSQL. Proporciona Auth (JWT), Database con RLS, Storage de archivos y Realtime.

**Arquitectura Clean (simplificada):** Presentación (`screens/`) → Lógica de negocio (`providers/`) → Datos (`models/`, `services/`).

---

### 5. Arquitectura del sistema

```
┌──────────────────────────────────────────────┐
│                CLIENTE FLUTTER               │
│   Alumno Panel · Maestro Panel · Admin Panel │
│              AppProvider (Estado)            │
│   ApiService · ClaudeService · NotifService  │
└───────────────┬──────────────────────────────┘
                │
     ┌──────────┴──────────┐
     ▼                     ▼
Supabase                Claude API
(PostgreSQL+Auth)       (Anthropic)
```

**Flujo de datos:**
1. Usuario interactúa con pantalla Flutter
2. Pantalla llama método en `AppProvider`
3. Provider actualiza estado local → `ApiService` → Supabase
4. `notifyListeners()` reconstruye pantallas

---

### 6. Modelos de datos principales

```dart
// Tarea con entrega y calificación
class Tarea {
  String id, titulo, descripcion, materiaId;
  EstadoTarea estado;        // pendiente | enProgreso | entregada
  PrioridadTarea prioridad;  // baja | media | alta
  List<SubtareaItem> subtareas;
  EntregaTarea? entrega;     // texto + archivos + calificación
}

// Entrega con calificación docente
class EntregaTarea {
  String texto;
  List<String> archivos;
  double? calificacion;      // 0.0 – 10.0, null = sin calificar
  String retroalimentacion;
  DateTime? fechaCalificacion;
}

// PDF con notas e historial de IA
class EstudioPDF {
  String id, titulo, rutaLocal;
  List<NotaPDF> notas;
  List<MensajeIA> historialIA;
  Uint8List? bytes;          // web-only (in-memory)
}
```

---

### 7. Módulos implementados

| Módulo | Archivos | Funcionalidades clave |
|--------|---------|----------------------|
| Auth | `login_screen.dart` | Login, registro, sesión persistente, invitado |
| Materias | `materias_screen`, `materia_detail`, `materia_form` | CRUD, horario, calificaciones, notas |
| Tareas | `tareas_screen`, `tarea_form`, `entrega_screen` | CRUD, subtareas, entrega archivos |
| PDFs | `pdfs_screen`, `pdf_viewer_screen` | Visor, notas, TTS, IA, Pomodoro |
| Maestro | `maestro_screen`, `calificar_entrega` | Grupos, anuncios, calificación |
| Admin | `admin_screen` | Materias, grupos, profesores, alumnos |
| Calendario | `calendario_screen` | Vista mensual, tareas por día |
| Pomodoro | `pomodoro_screen` | Timer configurable, racha de estudio |

---

### 8. Metodología

Desarrollo ágil incremental en 4 fases:

| Fase | Semanas | Actividades |
|------|---------|-------------|
| Análisis y diseño | 1–2 | Requerimientos, esquema BD, stack |
| Núcleo | 3–5 | Auth, materias, tareas, calendario |
| Funcionalidades avanzadas | 6–8 | PDFs + IA, panel maestro, entregas |
| Admin y documentación | 9–10 | Panel admin, pruebas, docs |

---

### 9. Resultados

| Funcionalidad | Estado |
|--------------|--------|
| Autenticación Supabase Auth | ✅ Completo |
| Gestión materias / tareas | ✅ Completo |
| Entrega de tareas (texto + archivos) | ✅ Completo |
| Calificación con retroalimentación | ✅ Completo |
| Visor PDF con notas y TTS | ✅ Completo |
| Chat IA sobre documentos | ✅ Completo |
| Panel Admin (4 módulos) | ✅ Completo |
| Compatibilidad Android + Web | ✅ Completo |

**Métricas:** ~8,500 líneas Dart · 32 archivos `.dart` · 24 pantallas · APK 38.5 MB

---

### 10. Análisis de resultados

- **Estado:** Provider + ChangeNotifier efectivo a esta escala. Persistencia offline-first garantiza funcionamiento sin internet.
- **IA:** Claude API integrada directamente en el flujo de estudio reduce fricción para obtener ayuda contextual.
- **Roles:** Routing dinámico en `main.dart` separa claramente las responsabilidades de cada actor.
- **Multiplataforma:** Solo se necesitaron adaptaciones mínimas para web vs Android (manejo de archivos con `kIsWeb`).

**Desafíos resueltos:**

| Problema | Solución |
|---------|---------|
| `path` no disponible en web | `kIsWeb` + `file.bytes` en lugar de `file.path` |
| NDK corrompido en emulador | Eliminar caché, usar NDK 28.2 ya instalado |
| `y` colisionaba con operador AND | Cambiar operador AND a `&&` |
| Emulador con poca RAM crasheaba | Ejecutar en modo `--release` |

---

### 11. Discusión

Frente a alternativas como Google Classroom o Moodle, Gestor de Materias se diferencia por:
- **Visor de PDF integrado** con IA conversacional
- **Timer Pomodoro** nativo para técnicas de estudio basadas en evidencia
- **Offline-first:** funciona sin internet
- **Sin infraestructura propia:** usa Supabase cloud como backend listo para usar

**Limitaciones:** iOS no soportado (requiere firma de código) · Chat IA requiere API Key de pago · PDFs en web no persisten entre sesiones del navegador.

**Trabajo futuro:** Notificaciones push remotas · Soporte iOS · Exportación de calificaciones a PDF/Excel · Integración con LMS (Moodle, Canvas).

---

### 12. Conclusiones

El desarrollo de **Gestor de Materias** validó que Flutter es un framework maduro para aplicaciones educativas multiplataforma. El patrón Provider resultó adecuado para la escala del proyecto. Supabase aceleró el desarrollo del backend sin sacrificar seguridad. La integración de Claude AI enriqueció la funcionalidad del visor de PDFs. La arquitectura de roles diferenciados demostró ser escalable y mantenible.

---

### 13. Referencias

- Flutter Documentation (2025). *Flutter — Build apps for any screen*. flutter.dev
- Supabase (2025). *Supabase Docs*. supabase.com/docs
- Anthropic (2025). *Claude API Documentation*. docs.anthropic.com
- Martin, R. C. (2017). *Clean Architecture*. Prentice Hall.
- Google Material Design (2025). *Material Design 3*. m3.material.io

</details>

---

## 👨‍💻 Autor

<div align="center">

**Joshua Béjar**  
Ingeniería en Sistemas de Información  
Universidad de Monterrey · 2025

[![Email](https://img.shields.io/badge/Email-1200455%40alumno.um.edu.mx-red?style=flat-square&logo=gmail)](mailto:1200455@alumno.um.edu.mx)

</div>

---

## 📄 Licencia

```
MIT License — Copyright (c) 2025 Joshua Béjar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software...
```

<div align="center">

Hecho con ❤️ y Flutter · Universidad de Monterrey · 2025

⭐ Si te fue útil, dale una estrella al repo

</div>
