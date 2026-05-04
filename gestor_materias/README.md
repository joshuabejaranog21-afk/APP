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
[![Lines of Code](https://img.shields.io/badge/Lines_of_Code-8500+-blueviolet?style=flat-square)](lib/)
[![Screens](https://img.shields.io/badge/Pantallas-24-orange?style=flat-square)](lib/screens/)

<br/>

> **Gestor de Materias** centraliza toda la vida académica en una sola app: organiza tus materias, entrega tareas, estudia con IA, califica como maestro y administra tu institución — todo desde Android o la web, en tiempo real.

<br/>

</div>

---

## 📸 Vista previa

<div align="center">

| Login | Dashboard | Tareas | PDF + IA |
|:-----:|:---------:|:------:|:--------:|
| ![login](https://via.placeholder.com/160x320/6750A4/white?text=Login) | ![dashboard](https://via.placeholder.com/160x320/6750A4/white?text=Dashboard) | ![tareas](https://via.placeholder.com/160x320/6750A4/white?text=Tareas) | ![pdf](https://via.placeholder.com/160x320/6750A4/white?text=PDF+IA) |

| Panel Maestro | Calificar | Panel Admin | Exportar PDF |
|:-------------:|:---------:|:-----------:|:------------:|
| ![maestro](https://via.placeholder.com/160x320/4CAF50/white?text=Maestro) | ![calificar](https://via.placeholder.com/160x320/4CAF50/white?text=Calificar) | ![admin](https://via.placeholder.com/160x320/E91E63/white?text=Admin) | ![export](https://via.placeholder.com/160x320/FF9800/white?text=Export+PDF) |

</div>

---

## ✨ Características

<table>
<tr>
<td width="50%">

### 👨‍🎓 Para el Alumno
- 📚 Gestión completa de **materias** con color, ícono y horario semanal
- ✅ **Tareas** con subtareas, prioridades, tipos y recurrencia
- 📤 **Entrega** de trabajos con texto y archivos adjuntos
- 📄 **Visor de PDFs** con anotaciones por página y resaltado
- 🔊 **Texto a voz** para escuchar apuntes y notas
- 🤖 **Chat IA** (Claude) sobre fragmentos de documentos
- ⏱️ **Timer Pomodoro** integrado en el visor de PDFs
- 📅 **Calendario** mensual interactivo con tareas por día
- 🕐 **Horario semanal** generado automáticamente
- 📊 **Exportar calificaciones** a PDF y compartir
- 🔥 **Racha de estudio** y estadísticas personales
- 🌙 **Modo oscuro** con tema Material Design 3

</td>
<td width="50%">

### 👨‍🏫 Para el Maestro
- 👥 Crear y gestionar **grupos** de alumnos
- 📢 Publicar **anuncios** fijados por grupo o general
- 📝 **Asignar tareas** a grupos completos con fecha límite
- ✔️ **Calificar entregas** con slider 0–10 en tiempo real
- 💬 **Retroalimentación** escrita personalizada por alumno
- 📋 Vista separada de **pendientes** y **calificadas**
- 🔔 **Sincronización en tiempo real** via Supabase Realtime

### 🛡️ Para el Administrador
- 🏫 CRUD completo de **materias** (nombre, profesor, aula)
- 👥 Gestionar **grupos** con lista expandible de alumnos
- 👨‍🏫 Registrar **profesores** y asignarlos a materias
- 🎓 Administrar **alumnos** y cambiarlos entre grupos
- ➕ Crear alumnos nuevos con asignación directa de grupo

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
- [Android Studio](https://developer.android.com/studio) con un emulador configurado (API 23+)
- Una cuenta gratuita en [Supabase](https://supabase.com)
- *(Opcional)* API Key de [Anthropic](https://console.anthropic.com) para activar el chat con IA

---

### ⚡ Instalación en 4 pasos

**1. Clona el repositorio**
```bash
git clone https://github.com/tu-usuario/gestor-materias.git
cd gestor-materias/APP/gestor_materias
```

**2. Instala dependencias**
```bash
flutter pub get
```

**3. Configura Supabase**

Abre `lib/services/api_service.dart` y reemplaza con tus credenciales:
```dart
const String supabaseUrl     = 'https://TU_PROYECTO.supabase.co';
const String supabaseAnonKey = 'TU_ANON_KEY';
```

Ejecuta los scripts en el **SQL Editor** de Supabase (en este orden):
```
📄 supabase_schema.sql          ← crea tablas y políticas RLS
📄 supabase_seed.sql            ← datos de prueba (opcional)
📄 supabase_storage_setup.sql   ← configura el bucket de archivos
```

**4. Corre la app**
```bash
flutter run                    # detecta dispositivo automáticamente
flutter run -d emulator-5554   # emulador Android específico
flutter run -d chrome          # navegador web
flutter build apk --release    # genera APK optimizado (~38 MB)
```

---

## 🏗️ Arquitectura del sistema

El proyecto sigue una arquitectura **Clean por capas** con estado reactivo y sincronización en tiempo real:

```
┌───────────────────────────────────────────────────────────┐
│                      PRESENTACIÓN                         │
│     24 pantallas Flutter organizadas por módulo           │
│  screens/auth · admin · maestro · tareas · materias       │
│  pdfs · calendario · horario · pomodoro · perfil          │
└──────────────────────────┬────────────────────────────────┘
                           │  context.watch / context.read
┌──────────────────────────▼────────────────────────────────┐
│                   LÓGICA DE NEGOCIO                       │
│        AppProvider extends ChangeNotifier                 │
│    Estado global · offline-first · ~800 líneas            │
│  Gestiona: Materias · Tareas · PDFs · Grupos · Profesores │
└──────────┬───────────────────────────┬────────────────────┘
           │ ApiService                │ Realtime channels
┌──────────▼──────────┐   ┌───────────▼───────────────────┐
│   Supabase          │   │   Supabase Realtime           │
│  PostgreSQL + Auth  │   │  Live sync: tareas, anuncios  │
│  Storage + RLS      │   │  grupos, calificaciones        │
└─────────────────────┘   └───────────────────────────────┘
           │
┌──────────▼──────────┐   ┌─────────────────────┐
│  SharedPreferences  │   │   Claude API        │
│  Persistencia local │   │  Chat IA en PDFs    │
│  Offline-first      │   │  (Anthropic)        │
└─────────────────────┘   └─────────────────────┘
```

### Estructura de carpetas

```
lib/
├── main.dart                        # Routing dinámico por rol + Realtime init
├── models/
│   ├── tarea.dart                   # Tarea · EntregaTarea · SubtareaItem
│   ├── materia.dart                 # Materia · HorarioClase
│   ├── grupo.dart                   # Grupo · AlumnoGrupo
│   ├── profesor.dart                # Profesor
│   ├── nota.dart                    # Nota · Calificacion
│   └── estudio_pdf.dart             # EstudioPDF · NotaPDF · MensajeIA
├── providers/
│   └── app_provider.dart            # Estado global · CRUD · Realtime · Export
├── screens/
│   ├── auth/          login_screen.dart
│   ├── admin/         admin_screen.dart (Materias · Grupos · Profesores · Alumnos)
│   ├── maestro/       maestro_screen · calificar_entrega · asignar_tarea · grupos
│   ├── tareas/        tareas_screen · entrega_screen · tarea_form
│   ├── materias/      materias_screen · materia_detail · materia_form
│   ├── pdfs/          pdfs_screen · pdf_viewer_screen
│   ├── calendario/    calendario_screen
│   ├── horario/       horario_screen
│   ├── pomodoro/      pomodoro_screen
│   ├── perfil/        perfil_screen
│   ├── busqueda/      busqueda_screen
│   └── rol/           rol_screen
├── services/
│   ├── api_service.dart             # CRUD completo Supabase
│   ├── claude_service.dart          # Chat IA con contexto del PDF
│   ├── export_service.dart          # Generación de PDFs (calificaciones)
│   └── notification_service.dart    # Recordatorios locales
└── theme/
    └── app_theme.dart               # Material Design 3 · claro/oscuro
```

---

## 🔧 Stack tecnológico

<div align="center">

| Capa | Tecnología | Versión | Propósito |
|------|-----------|---------|-----------|
| **UI** | Flutter | 3.41 | Framework UI multiplataforma |
| **Lenguaje** | Dart | 3.x | Tipado fuerte, null-safety, async/await |
| **Backend** | Supabase | 2.5 | PostgreSQL + Auth JWT + Storage |
| **Realtime** | Supabase Realtime | 2.5 | Sincronización en vivo vía WebSocket |
| **Estado** | Provider | 6.1 | ChangeNotifier reactivo |
| **PDF viewer** | pdfrx | 1.0 | Render nativo, selección, notas |
| **PDF export** | pdf + printing | 3.11 | Generación y compartir PDF |
| **IA** | Claude API | claude-3 | Chat contextual sobre documentos |
| **TTS** | flutter_tts | 4.0 | Lectura en voz alta en español |
| **Archivos** | file_picker | 8.0 | Adjuntar PDF, Word, imágenes |
| **Notificaciones** | local_notifications | 18 | Recordatorios de tareas |
| **Calendario** | table_calendar | 3.1 | Vista mensual interactiva |
| **Gráficas** | fl_chart | 0.69 | Estadísticas de estudio |
| **Gestos** | flutter_slidable | 3.1 | Deslizar para acciones rápidas |
| **Persistencia** | shared_preferences | 2.3 | Almacenamiento local offline |
| **Compartir** | share_plus | 10.0 | Compartir archivos y texto |

</div>

---

## 🗄️ Base de datos

### Esquema PostgreSQL (Supabase)

```sql
-- Todas las tablas usan JSONB para máxima flexibilidad
materias       (id TEXT PRIMARY KEY, data JSONB)
tareas         (id TEXT PRIMARY KEY, data JSONB)
calificaciones (id TEXT PRIMARY KEY, data JSONB)
notas          (id TEXT PRIMARY KEY, data JSONB)
grupos         (id TEXT PRIMARY KEY, data JSONB)
anuncios       (id TEXT PRIMARY KEY, data JSONB)

-- RLS: cada usuario solo accede a sus propios datos
CREATE POLICY "own_data" ON materias
  FOR ALL USING (auth.uid() = user_id);
```

### Estrategia offline-first

```
Usuario crea / edita dato
         ↓
AppProvider actualiza estado en memoria
         ↓
SharedPreferences.save()     ← inmediato, funciona sin internet
         ↓
ApiService → Supabase        ← async, en background
         ↓
Realtime → otros dispositivos ← push automático
```

Los scripts SQL incluidos:

| Archivo | Descripción |
|---------|-------------|
| `supabase_schema.sql` | Tablas, índices y políticas RLS |
| `supabase_seed.sql` | Materias, tareas y grupos de prueba |
| `supabase_storage_setup.sql` | Bucket para archivos adjuntos |

---

## 🔐 Autenticación y control de roles

```
┌──────────────────────────────────────────────┐
│            Supabase Auth (JWT)               │
│  signInWithPassword · signUp · currentSession│
└──────────────────┬───────────────────────────┘
                   ↓
        ┌──────────────────┐
        │  Selección Rol   │
        └──┬──────┬──────┬─┘
           ↓      ↓      ↓
       Alumno  Maestro  Admin
       🎓      👨‍🏫     🛡️
       Home    Maestro  Admin
       Screen  Screen   Screen
```

La sesión se restaura automáticamente al iniciar la app:
```dart
final session = Supabase.instance.client.auth.currentSession;
if (session != null) {
  _isAuthenticated = true;
  _userName = session.user.userMetadata?['nombre'] ?? email;
}
```

---

## 📱 Compatibilidad

| Plataforma | Estado | Detalles |
|-----------|--------|---------|
| 🤖 **Android 6.0+** | ✅ Completo | APK 38.5 MB · NDK 28.2 |
| 🌐 **Chrome / Edge** | ✅ Completo | Archivos en memoria · offline limitado |

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas!

1. Haz un **Fork** del repositorio
2. Crea tu rama: `git checkout -b feature/mi-feature`
3. Commit: `git commit -m 'feat: descripción del cambio'`
4. Push: `git push origin feature/mi-feature`
5. Abre un **Pull Request**

---

---

# 📖 Manual de Usuario

> Versión 1.0 · Abril 2025 · Plataforma: Android / Web

---

## Índice

1. [Introducción](#introducción)
2. [Requisitos del sistema](#requisitos-del-sistema)
3. [Inicio de sesión y registro](#inicio-de-sesión-y-registro)
4. [Selección de rol](#selección-de-rol)
5. [Rol Alumno — Guía completa](#rol-alumno--guía-completa)
6. [Rol Maestro — Guía completa](#rol-maestro--guía-completa)
7. [Rol Administrador — Guía completa](#rol-administrador--guía-completa)
8. [Cerrar sesión](#cerrar-sesión)

---

## Introducción

**Gestor de Materias** es una aplicación académica que permite a alumnos, maestros y administradores gestionar de forma centralizada toda la actividad escolar: tareas, materias, calificaciones, horarios, documentos PDF, entregas y calificaciones.

La app cuenta con **tres roles diferenciados**, cada uno con su propio panel adaptado a sus necesidades, y se sincroniza en tiempo real entre dispositivos usando Supabase.

---

## Requisitos del sistema

| Plataforma | Versión mínima |
|-----------|---------------|
| Android | 6.0 (API 23) o superior |
| Web | Chrome 90+ o Microsoft Edge 90+ |
| Conexión | Internet para autenticación y sincronización en tiempo real |
| Almacenamiento | 100 MB disponibles (Android) |

---

## Inicio de sesión y registro

Al abrir la app verás la pantalla de inicio de sesión con tres opciones:

### Iniciar sesión con cuenta existente
1. Ingresa tu **correo electrónico**
2. Ingresa tu **contraseña**
3. Toca **"Iniciar sesión"**
4. Si los datos son correctos, se te redirige a la selección de rol

### Crear cuenta nueva
1. Toca **"¿No tienes cuenta? Regístrate"**
2. Ingresa tu **nombre completo**
3. Ingresa tu **correo electrónico**
4. Crea una **contraseña** (mínimo 6 caracteres)
5. Confirma la contraseña
6. Toca **"Crear cuenta"**

### Continuar sin cuenta (Invitado)
- Toca **"Continuar sin cuenta"**
- Entras como **Invitado** — todos los datos se guardan localmente en el dispositivo
- No hay sincronización con la nube en este modo

---

## Selección de rol

Después de autenticarte, elige con qué perfil deseas trabajar:

| Opción | Color | Descripción |
|--------|-------|-------------|
| 🎓 **Soy Alumno** | Morado | Panel personal de gestión académica |
| 👨‍🏫 **Soy Maestro** | Verde | Panel docente con grupos y calificación |
| 🛡️ **Administrador** | Rosa/Fucsia | Panel de administración institucional |

> **Tip:** Puedes cambiar de rol en cualquier momento tocando el ícono **⇄** en la barra superior del panel de Maestro o Admin, o desde **Perfil → Cerrar sesión**.

---

## Rol Alumno — Guía completa

### Dashboard (pantalla de inicio)

La pantalla principal muestra un resumen de tu actividad académica:

| Elemento | Descripción |
|---------|-------------|
| **Saludo** | Tu nombre tomado del perfil (`"Hola, Joshua! 👋"`) |
| **Fecha y día** | Día de la semana y fecha actual |
| **Frase del día** | Frase motivacional que cambia cada día |
| **Tarjetas de resumen** | Tareas pendientes y materias activas |
| **Racha de estudio** | Días consecutivos con actividad registrada |
| **Próximas tareas** | Las tareas más urgentes por vencer |
| **FAB +** | Agregar una nueva tarea rápidamente |

---

### Materias

La pestaña **Materias** muestra todas tus materias con colores e íconos personalizados.

#### Agregar una materia
1. Toca el botón flotante **+**
2. Completa el formulario:
   - **Nombre** de la materia
   - **Profesor** a cargo
   - **Aula** donde se imparte
   - **Color** representativo (paleta de 12 colores)
   - **Ícono** descriptivo
   - **Nota objetivo** (calificación meta)
   - **Horario**: días y horas de cada sesión
3. Toca **"Guardar"**

#### Editar una materia
- Entra al detalle de la materia → toca el ícono de **lápiz** ✏️

#### Eliminar una materia
- En la lista de materias: **desliza a la izquierda** sobre la materia → toca el ícono de basura

#### Detalle de materia
Al tocar una materia verás:
- **Promedio actual** calculado automáticamente
- **Calificaciones** registradas con peso y fecha
- **Tareas** asociadas a esa materia
- **Notas** y apuntes rápidos

---

### Tareas

#### Crear una tarea
1. Toca el botón **+** en la pestaña Tareas o en el Dashboard
2. Completa:
   - **Título** descriptivo
   - **Descripción** detallada (opcional)
   - **Materia** a la que pertenece
   - **Fecha límite** con hora exacta
   - **Prioridad**: baja / media / alta
   - **Tipo**: tarea, examen, quiz, proyecto, exposición, laboratorio, lectura, otro
   - **Subtareas**: lista de pasos a completar (opcional)
   - **Recurrente**: si se repite semanalmente
3. Toca **"Guardar"**

#### Estados de una tarea

| Estado | Ícono | Significado |
|--------|-------|-------------|
| **Pendiente** | ⚪ | Recién creada, sin iniciar |
| **En progreso** | 🔵 | Siendo trabajada activamente |
| **Entregada** | ✅ | Completada y entregada |

**Cambiar estado:** Toca el ícono circular a la izquierda del título en la card.

#### Entregar una tarea
1. En la card de la tarea, toca el botón **"Entregar"**
2. Aparece la pantalla de entrega con:
   - **Información** de la tarea (título, descripción, fecha límite)
   - **Cuadro de texto** para escribir tu respuesta (opcional)
   - **Botón Adjuntar** para subir archivos (PDF, Word, imágenes)
3. Toca el FAB verde **"Entregar"** o el botón en la barra superior
4. La tarea cambia automáticamente a estado **Entregada** ✅

#### Ver entrega previa
- Si ya entregaste, el botón cambia a **"Ver entrega"** (verde)
- Muestra la fecha de entrega, respuesta escrita y archivos adjuntos

#### Filtros y ordenamiento
- **Pestañas:** Pendientes / En progreso / Entregadas
- **Ordenar** por: fecha límite, prioridad o tipo de actividad
- **Deslizar** la card a la izquierda para opciones: Editar / Eliminar / Completar

---

### PDFs (Documentos de Estudio)

#### Agregar un PDF
1. Ve a la pestaña **PDFs**
2. Si no hay documentos, toca **"Subir PDF"** o el FAB
3. Selecciona el archivo desde tu dispositivo (Android) o elige el archivo (web)
4. El PDF aparece en la lista con su nombre y fecha

#### Leer un PDF
- Toca el documento para abrirlo en el visor
- **Navega** con deslizamiento entre páginas
- La **página actual** se guarda automáticamente al cerrar

#### Funciones del visor de PDFs

| Función | Cómo acceder | Descripción |
|---------|-------------|-------------|
| 📝 **Agregar nota** | Barra inferior → ícono nota | Escribe una anotación para esa página |
| 🖍️ **Ver notas** | Ícono de notas | Muestra todas las notas de la página actual |
| 🔊 **Leer en voz alta** | Selecciona texto → ícono audio | Lee el texto seleccionado con TTS |
| 🔊 **Leer notas** | Sin selección → ícono audio | Lee las notas de la página si no hay texto seleccionado |
| 🤖 **Preguntar a la IA** | Selecciona texto → ícono IA | Abre el chat con Claude AI sobre ese fragmento |
| ⏱️ **Pomodoro** | Ícono de reloj | Inicia el temporizador de estudio |
| 💬 **Historial IA** | Panel lateral | Ve toda la conversación con la IA |

#### Chat con IA (Claude)
1. **Selecciona texto** en el PDF
2. Toca el ícono de IA 🤖
3. El fragmento aparece como contexto
4. Escribe tu pregunta: `"¿Qué significa esto?"`, `"Resúmelo"`, `"Da un ejemplo"`
5. La IA responde basándose en el texto seleccionado
6. El historial se guarda automáticamente

> **Nota:** Necesitas configurar tu API Key de Claude en **Perfil → API Key de Claude** para usar esta función.

---

### Calendario

- Vista **mensual** con puntos de colores en días que tienen tareas
- Los colores corresponden a las materias de cada tarea
- **Toca un día** para ver la lista de tareas de esa fecha
- Toca una tarea en el calendario para ver su detalle
- **FAB +** para agregar una tarea con esa fecha preseleccionada

---

### Horario semanal

- Vista de **Lunes a Domingo** con bloques de tiempo por materia
- Se genera automáticamente desde el horario configurado en cada materia
- Los bloques muestran el nombre de la materia, aula y hora
- Colores consistentes con cada materia

---

### Timer Pomodoro

La técnica Pomodoro divide el estudio en intervalos con descansos:

1. Ve al menú lateral → **Pomodoro**, o ábrelo desde el visor de PDFs
2. Toca **▶ Iniciar** para comenzar
3. Trabaja durante el tiempo de trabajo (default: 25 min)
4. Descansa en el descanso corto (default: 5 min)
5. Después de 4 ciclos, toma un descanso largo (default: 15 min)

#### Configurar tiempos
En la pantalla Pomodoro: toca **Ajustes** →
- **Tiempo de trabajo:** 1–60 minutos
- **Descanso corto:** 1–30 minutos
- **Descanso largo:** 5–60 minutos

Cada sesión completada suma a tu **racha de estudio**.

---

### Perfil

La pantalla de Perfil muestra tu información y configuración global:

| Elemento | Descripción |
|---------|-------------|
| **Avatar** | Inicial de tu nombre en círculo de color |
| **Nombre** | Nombre completo del perfil |
| **Email** | Correo de la cuenta |
| **Racha** | Días consecutivos de estudio |
| **Modo oscuro** | Toggle para cambiar entre tema claro y oscuro |
| **API Key Claude** | Configura tu clave para el chat IA en PDFs |
| **Exportar PDF** | Genera un reporte completo de calificaciones |
| **Cerrar sesión** | Sale de la cuenta con confirmación |

#### Exportar calificaciones a PDF
1. En **Perfil**, toca **"Exportar calificaciones PDF"**
2. Se genera automáticamente un reporte con:
   - Resumen general con promedio global
   - Tabla de todas las materias con promedio y meta
   - Detalle de evaluaciones por materia
   - Tareas calificadas por los maestros
3. Se abre el menú de compartir: WhatsApp, email, Google Drive, etc.

---

## Rol Maestro — Guía completa

El panel del Maestro tiene **4 pestañas** en la barra superior.

---

### Tab 1 — Grupos

Gestiona los grupos de alumnos a tu cargo.

#### Crear un grupo
1. Toca el FAB **"Nuevo grupo"**
2. Ingresa:
   - **Nombre** del grupo (ej: "6°A Matutino")
   - **Descripción** (ej: "32 alumnos - Turno matutino")
   - **Color** representativo
3. En el detalle del grupo, agrega alumnos con nombre y apellido
4. Toca **"Guardar"**

#### Ver detalle de un grupo
- Toca el grupo para ver:
  - Lista completa de alumnos
  - Tareas asignadas a ese grupo
  - Anuncios publicados para ese grupo

---

### Tab 2 — Anuncios

Publica comunicados para tus grupos.

#### Crear un anuncio
1. Toca el FAB **"Nuevo anuncio"**
2. Completa:
   - **Título** del anuncio
   - **Contenido** del mensaje
   - **Grupo destinatario** (o déjalo vacío para todos)
   - **Fijado** ✓ para que aparezca siempre al inicio de la lista
3. Toca **"Publicar"**

Los anuncios se sincronizan en tiempo real — los alumnos los ven inmediatamente.

---

### Tab 3 — Tareas

Visualiza y crea tareas asignadas a grupos.

#### Asignar una tarea
1. Toca el FAB **"Asignar tarea"**
2. Selecciona:
   - **Grupo** destinatario
   - **Título** y descripción
   - **Fecha límite**
   - **Tipo y prioridad**
3. Toca **"Asignar"**

La tarea aparece automáticamente en el panel de todos los alumnos del grupo.

---

### Tab 4 — Calificar

Vista completa de entregas para calificar.

#### Cómo está organizada la lista

| Sección | Color | Descripción |
|---------|-------|-------------|
| **Por calificar** | 🟠 Naranja | Entregas recibidas sin calificación |
| **Calificadas** | 🟢 Verde | Entregas ya evaluadas |

Las entregas más recientes aparecen primero dentro de cada sección.

#### Calificar una entrega
1. Toca la card de la tarea entregada
2. Verás la pantalla de calificación con:
   - **Info de la tarea** (tipo, descripción, fecha límite)
   - **Entrega del alumno**: texto y archivos adjuntos
   - **Slider de calificación** de 0.0 a 10.0
   - **Botones rápidos**: 0, 5, 6, 7, 8, 9, 10
   - **Campo de retroalimentación** para comentarios
3. Ajusta la calificación con el slider o los botones rápidos
4. Escribe comentarios de retroalimentación (opcional)
5. Toca **"Guardar calificación"** o el FAB

El color del FAB cambia según la calificación:
- 🟢 Verde: 9–10
- 🔵 Azul: 7–8
- 🟠 Naranja: 6
- 🔴 Rojo: 0–5

La calificación se muestra al alumno en su pantalla de **"Ver entrega"**.

---

## Rol Administrador — Guía completa

El panel del Administrador tiene **4 pestañas**.

---

### Tab 1 — Materias

Gestión completa del catálogo de materias.

| Acción | Cómo hacerlo |
|--------|-------------|
| **Agregar materia** | FAB → nombre, profesor, aula → **Agregar** |
| **Editar materia** | Tres puntos ⋮ → **Editar** → modifica → **Guardar** |
| **Eliminar materia** | Tres puntos ⋮ → **Eliminar** → confirma |

---

### Tab 2 — Grupos

Vista expandible de todos los grupos con sus alumnos.

- **Ver alumnos:** Toca el grupo para expandirlo
- **Nuevo grupo:** FAB → nombre y descripción → **Agregar**
- **Editar grupo:** Ícono ✏️ en la tarjeta del grupo
- **Eliminar grupo:** Ícono 🗑️ → confirma en el diálogo

---

### Tab 3 — Profesores

Registro y asignación de profesores a materias.

| Acción | Pasos |
|--------|-------|
| **Agregar** | FAB → nombre, correo, especialidad → **Agregar** |
| **Editar** | ⋮ → Editar → modifica → **Guardar** |
| **Asignar materia** | ⋮ → "Asignar materia" → selecciona la materia de la lista |
| **Eliminar** | ⋮ → Eliminar → confirma |

Al asignar una materia, el nombre del profesor se vincula automáticamente a ella.

---

### Tab 4 — Alumnos

Vista de todos los alumnos registrados en el sistema, ordenados alfabéticamente.

| Acción | Pasos |
|--------|-------|
| **Agregar alumno** | FAB → nombre, apellido, grupo → **Agregar** |
| **Editar** | ⋮ → Editar → modifica nombre/apellido → **Guardar** |
| **Cambiar grupo** | ⋮ → "Cambiar grupo" → selecciona nuevo grupo |
| **Eliminar** | ⋮ → Eliminar → confirma |

Cada alumno muestra el grupo al que pertenece con su ícono de grupo.

---

## Cerrar sesión

Desde cualquier rol:

1. Ve a la pestaña **Perfil** (ícono de persona, en Alumno es la última pestaña)
2. Desplázate hasta el final de la pantalla
3. Toca el botón rojo **"Cerrar sesión"**
4. Confirma tocando **"Cerrar sesión"** en el diálogo

Al cerrar sesión:
- Se limpia el estado local de autenticación y rol
- Se cierra la sesión en Supabase
- Se redirige a la pantalla de login

---

---

# 📄 Documento Técnico Académico

> **Institución:** Universidad de Monterrey  
> **Carrera:** Ingeniería en Sistemas de Información  
> **Materia:** Desarrollo de Aplicaciones Móviles  
> **Fecha:** Abril 2025 · **Autor:** Joshua Béjar

---

## Resumen

El presente documento describe el diseño, desarrollo e implementación de **Gestor de Materias**, una aplicación móvil y web multiplataforma orientada a la gestión académica integral. La aplicación fue construida con Flutter y Dart, empleando Supabase como backend en la nube con sincronización en tiempo real. Ofrece tres roles diferenciados — Alumno, Maestro y Administrador — y entre sus funcionalidades principales destacan la gestión de materias y tareas, entrega de trabajos con archivos adjuntos, calificación docente con retroalimentación, visualización de PDFs con anotaciones e inteligencia artificial, exportación de calificaciones a PDF y un panel administrativo completo.

**Palabras clave:** Flutter, Dart, Supabase, Supabase Realtime, gestión académica, aplicación móvil, inteligencia artificial, Claude AI, roles de usuario, entrega de tareas, calificación, exportación PDF.

---

## 1. Introducción

En el contexto educativo actual, la gestión de actividades académicas representa un reto significativo para todos los actores del proceso educativo. Los estudiantes deben rastrear tareas en múltiples plataformas, los maestros carecen de herramientas unificadas para calificar y comunicarse, y los administradores no tienen visibilidad centralizada de la estructura académica.

**Gestor de Materias** nació para resolver esta fragmentación. Desarrollada con **Flutter** — framework multiplataforma de Google — y **Supabase** como backend, la app integra en un solo lugar todo lo necesario para la vida académica: desde la organización personal del alumno hasta la calificación docente y la administración institucional.

---

## 2. Planteamiento del problema

| Actor | Problema identificado |
|-------|----------------------|
| **Alumno** | Tareas dispersas en múltiples apps, sin visión unificada de fechas límite |
| **Maestro** | Sin herramienta centralizada para recibir entregas y calificar |
| **Administrador** | Gestión manual de materias, grupos y asignaciones de profesores |
| **Institución** | Sin sincronización en tiempo real entre los actores del sistema |

---

## 3. Objetivos

### Objetivo general
Desarrollar una aplicación móvil y web multiplataforma que centralice la gestión académica para los tres actores del proceso educativo.

### Objetivos específicos
- Implementar autenticación segura y persistente con Supabase Auth (JWT)
- Gestión completa CRUD de materias, tareas, calificaciones y grupos
- Sistema de entrega de tareas con soporte de texto y archivos adjuntos
- Visor de PDF con anotaciones, texto a voz e inteligencia artificial
- Panel docente con calificación y retroalimentación en tiempo real
- Exportación de calificaciones a PDF compartible
- Sincronización en tiempo real con Supabase Realtime (WebSocket)
- Panel administrativo completo con 4 módulos de gestión
- Compatibilidad multiplataforma (Android + Web) desde una sola base de código

---

## 4. Marco teórico

### Flutter y Dart
Flutter es el SDK de desarrollo de interfaces de usuario de Google. Utiliza el lenguaje Dart y compila a código nativo ARM para móvil y a JavaScript/WebAssembly para web. Su arquitectura de **widgets reactivos** permite construir UIs declarativas que se actualizan automáticamente cuando el estado cambia.

### Patrón Provider (ChangeNotifier)
El proyecto utiliza el patrón **Provider** para gestión de estado global. `AppProvider` extiende `ChangeNotifier` y centraliza todos los datos de la aplicación (~800 líneas). Las pantallas observan cambios mediante `context.watch<AppProvider>()` y se reconstruyen solo cuando es necesario, optimizando el rendimiento.

### Supabase
Supabase es una plataforma de backend open-source construida sobre PostgreSQL. Proporciona:
- **Auth:** sistema de autenticación con tokens JWT
- **Database:** PostgreSQL con Row Level Security (RLS)
- **Storage:** almacenamiento de archivos en la nube
- **Realtime:** suscripciones a cambios en la base de datos via WebSocket

### Arquitectura offline-first
La app implementa persistencia en dos capas: primero guarda en `SharedPreferences` (local, instantáneo), luego sincroniza con Supabase (remoto, async). Esto garantiza que la app funcione sin conexión y sincronice cuando hay internet.

### Supabase Realtime
Los cambios en tablas críticas (tareas, anuncios, grupos, calificaciones) se propagan en tiempo real a todos los dispositivos conectados usando canales WebSocket de Supabase. Cuando un maestro califica una tarea, el alumno la ve inmediatamente.

---

## 5. Arquitectura del sistema

```
┌────────────────────────────────────────────────────────┐
│                    CLIENTE FLUTTER                     │
│                                                        │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐   │
│  │   Alumno    │  │   Maestro   │  │    Admin     │   │
│  │   Panel     │  │   Panel     │  │    Panel     │   │
│  └──────┬──────┘  └──────┬──────┘  └──────┬───────┘   │
│         └───────────────┼──────────────────┘           │
│                         │                              │
│              ┌──────────▼──────────┐                   │
│              │    AppProvider      │                   │
│              │  ChangeNotifier     │                   │
│              │  Estado Global      │                   │
│              └──────────┬──────────┘                   │
│                         │                              │
│   ┌─────────────────────┼─────────────────────┐        │
│   │                     │                     │        │
│   ▼                     ▼                     ▼        │
│ ApiService          ClaudeService         ExportService │
│ (CRUD)              (IA Chat)             (PDF Gen.)   │
│                                                        │
│   Realtime Channels (WebSocket)                        │
│   tareas · anuncios · grupos · calificaciones          │
└────────────────────────────────────────────────────────┘
         │                          │
┌────────▼────────┐        ┌────────▼────────┐
│    Supabase     │        │   Claude API    │
│  PostgreSQL     │        │   (Anthropic)   │
│  Auth JWT       │        │   claude-3      │
│  Storage        │        └─────────────────┘
│  Realtime WS    │
└─────────────────┘
```

### Flujo de datos
1. Usuario interactúa con pantalla Flutter
2. Pantalla llama método en `AppProvider` via `context.read<AppProvider>()`
3. Provider actualiza estado en memoria + `SharedPreferences` (sync)
4. `ApiService` sincroniza con Supabase (async, no bloquea UI)
5. `notifyListeners()` reconstruye todas las pantallas suscritas
6. Realtime propaga cambios a otros dispositivos conectados

---

## 6. Modelos de datos

### Modelo Tarea (con entrega y calificación)
```dart
class Tarea {
  final String id;
  String titulo, descripcion, materiaId;
  DateTime fechaLimite;
  EstadoTarea estado;         // pendiente | enProgreso | entregada
  PrioridadTarea prioridad;   // baja | media | alta
  TipoActividad tipo;         // tarea | examen | quiz | proyecto...
  List<SubtareaItem> subtareas;
  EntregaTarea? entrega;
  bool asignadoPorMaestro, esRecurrente;
  DateTime? completadaEn;
}

class EntregaTarea {
  String texto;
  List<String> archivos;
  DateTime fecha;
  double? calificacion;       // 0.0 – 10.0, null = sin calificar
  String retroalimentacion;
  DateTime? fechaCalificacion;
}
```

### Modelo EstudioPDF (con notas e IA)
```dart
class EstudioPDF {
  final String id;
  String titulo, rutaLocal;
  String? urlSupabase;
  List<NotaPDF> notas;
  List<MensajeIA> historialIA;
  int ultimaPagina, totalPaginas;
  Uint8List? bytes;            // web-only: in-memory
}
```

### Modelo Profesor
```dart
class Profesor {
  final String id;
  String nombre, email, especialidad;
}
```

### Modelo Grupo con Alumnos
```dart
class Grupo {
  final String id;
  String nombre, descripcion;
  int colorValue;
  List<AlumnoGrupo> alumnos;
}

class AlumnoGrupo {
  final String id;
  String nombre, apellido;
  int colorValue;
}
```

---

## 7. Módulos implementados

| Módulo | Archivos | Funcionalidades clave |
|--------|---------|----------------------|
| **Auth** | `login_screen.dart` | Login, registro, sesión JWT persistente, modo invitado |
| **Materias** | `materias_screen`, `materia_detail`, `materia_form` | CRUD, horario semanal, calificaciones ponderadas, notas |
| **Tareas** | `tareas_screen`, `tarea_form`, `entrega_screen` | CRUD, 8 tipos, subtareas, recurrencia, entrega multimedia |
| **PDFs** | `pdfs_screen`, `pdf_viewer_screen` | Render nativo, anotaciones, TTS, chat IA, Pomodoro integrado |
| **Maestro** | `maestro_screen`, `calificar_entrega`, `asignar_tarea` | Grupos, anuncios fijados, calificación con retroalimentación |
| **Admin** | `admin_screen` | 4 módulos: materias, grupos, profesores, alumnos |
| **Calendario** | `calendario_screen` | Vista mensual, tareas por día, creación rápida |
| **Horario** | `horario_screen` | Vista semanal auto-generada desde materias |
| **Pomodoro** | `pomodoro_screen` | Timer configurable, racha de días, registro de estudio |
| **Perfil** | `perfil_screen` | Modo oscuro, API Key IA, exportar PDF, cerrar sesión |
| **Export** | `export_service.dart` | Generación PDF con `pdf` package, compartir vía `share_plus` |
| **Realtime** | `app_provider.dart` | Canales WebSocket para 4 tablas críticas |

---

## 8. Metodología

Desarrollo ágil incremental en **4 sprints de 2–3 semanas**:

### Sprint 1 — Análisis y diseño (Semanas 1–2)
- Identificación de requerimientos funcionales y no funcionales
- Definición de los 3 roles y sus 47 casos de uso
- Diseño del esquema de base de datos en Supabase
- Selección y justificación del stack tecnológico
- Configuración del proyecto Flutter y dependencias iniciales

### Sprint 2 — Núcleo de la aplicación (Semanas 3–5)
- Implementación de autenticación con Supabase Auth
- Módulo de gestión de materias con CRUD y horarios
- Módulo de tareas con subtareas, prioridades y recordatorios
- Dashboard del alumno con resumen y racha de estudio
- Calendario mensual y horario semanal

### Sprint 3 — Funcionalidades avanzadas (Semanas 6–8)
- Integración del visor de PDFs con pdfrx
- Sistema de anotaciones y texto a voz (TTS)
- Chat con Claude AI (Anthropic) sobre documentos
- Panel del Maestro: grupos, anuncios y asignación de tareas
- Sistema de entrega de tareas con soporte multimedia
- Panel de calificación docente con slider y retroalimentación

### Sprint 4 — Admin, Realtime y documentación (Semanas 9–10)
- Panel Administrador con 4 módulos completos
- Modelo Profesor con asignación a materias
- Sincronización en tiempo real con Supabase Realtime
- Exportación de calificaciones a PDF
- Pruebas en emulador Android y navegador web
- Redacción de documentación técnica y manual de usuario

### Herramientas de desarrollo

| Herramienta | Propósito |
|------------|-----------|
| VS Code + Claude Code | IDE y asistencia con IA |
| Android Studio | Emulador Android (API 37) |
| Supabase Dashboard | Administración de BD y Auth |
| Git + GitHub | Control de versiones |
| Flutter DevTools | Depuración y análisis de rendimiento |

---

## 9. Resultados

### Funcionalidades implementadas

| Funcionalidad | Estado | Notas |
|--------------|--------|-------|
| Autenticación con Supabase Auth | ✅ Completo | Login, registro, JWT |
| Gestión de materias (CRUD) | ✅ Completo | Horario, color, ícono |
| Gestión de tareas con subtareas | ✅ Completo | 8 tipos, recurrencia |
| Entrega de tareas multimedia | ✅ Completo | Texto + archivos |
| Calificación docente | ✅ Completo | Slider + retroalimentación |
| Visor PDF con anotaciones | ✅ Completo | Notas por página |
| Chat IA en PDFs (Claude) | ✅ Completo | Contexto del fragmento |
| Texto a voz (TTS) | ✅ Completo | Español |
| Timer Pomodoro | ✅ Completo | Configurable |
| Calendario interactivo | ✅ Completo | Mensual |
| Horario semanal | ✅ Completo | Auto-generado |
| Exportación a PDF | ✅ Completo | Calificaciones |
| Sincronización Realtime | ✅ Completo | WebSocket |
| Panel Admin (4 módulos) | ✅ Completo | CRUD completo |
| Modo oscuro | ✅ Completo | Persistente |
| Compatibilidad Android | ✅ Completo | API 23+ |
| Compatibilidad Web | ✅ Completo | Chrome/Edge |

### Métricas del proyecto

| Métrica | Valor |
|---------|-------|
| Líneas de código Dart | ~8,500 |
| Archivos `.dart` | 32 |
| Pantallas implementadas | 24 |
| Modelos de datos | 6 |
| Dependencias externas | 18 |
| Tamaño APK release | 38.5 MB |
| Canales Realtime activos | 4 |
| Tablas en Supabase | 6 |

---

## 10. Análisis de resultados

### Gestión de estado
La implementación con **Provider + ChangeNotifier** resultó efectiva para la escala del proyecto. El `AppProvider` centraliza toda la lógica de negocio y es accesible desde cualquier widget sin pasar props manualmente. La persistencia en dos capas (local + Supabase) garantiza que la app funcione sin conexión y sincronice al reconectar.

### Integración de IA
Claude AI se integró directamente en el flujo de estudio del visor de PDF. El contexto del fragmento seleccionado se envía junto con la pregunta del usuario, lo que permite respuestas altamente relevantes. El historial de conversación se persiste por documento, permitiendo retomar el contexto en sesiones futuras.

### Sincronización en tiempo real
Supabase Realtime usa WebSockets para propagar cambios en la base de datos. Cuando un maestro califica una entrega, la calificación aparece en el dispositivo del alumno sin necesidad de recargar. Esto mejora significativamente la experiencia en entornos donde múltiples actores usan la app simultáneamente.

### Compatibilidad multiplataforma
La única adaptación necesaria entre Android y Web fue el manejo de archivos: Android usa `dart:io` con rutas de sistema de archivos, mientras que Web usa `Uint8List` (bytes en memoria). La detección se hace con `kIsWeb` en tiempo de ejecución, sin código separado por plataforma.

### Desafíos técnicos resueltos

| Desafío | Causa | Solución |
|---------|-------|---------|
| `path` no disponible en web | `dart:io` no soporta web | `kIsWeb` check + `file.bytes` |
| NDK corrompido en emulador | Descarga incompleta | Eliminar caché + usar NDK 28.2 |
| Variable `y` como operador AND | Conflicto léxico en el traductor | Cambiar AND a `&&` |
| Emulador crasheaba por memoria | Poco RAM en emulador | Ejecutar en modo `--release` |
| Sesión Supabase no restaurada | Inicialización asíncrona | Verificar `currentSession` en `cargar()` |
| `_suscribir` con underscore | Lint de Dart | Renombrar a `suscribir` |

---

## 11. Discusión

### Comparación con soluciones existentes

| Característica | Google Classroom | Moodle | Gestor de Materias |
|---------------|-----------------|--------|-------------------|
| Visor PDF integrado | ❌ | ❌ | ✅ |
| Chat IA en documentos | ❌ | ❌ | ✅ |
| Timer Pomodoro | ❌ | ❌ | ✅ |
| Exportar calificaciones PDF | ✅ | ✅ | ✅ |
| Offline-first | ❌ | ❌ | ✅ |
| Realtime sincronización | ✅ | ❌ | ✅ |
| Infraestructura propia | No | Sí | No |
| Costo | Gratis | Variable | Gratis |
| Curva de aprendizaje | Baja | Alta | Baja |

### Implicaciones pedagógicas
- La IA integrada en el visor de PDFs reduce la fricción para obtener ayuda, manteniendo al estudiante en contexto
- El Pomodoro integrado aplica técnicas de gestión del tiempo basadas en evidencia científica
- El sistema de racha de estudio aplica gamificación para motivar la constancia
- Las calificaciones con retroalimentación en tiempo real cierran el ciclo enseñanza-aprendizaje más rápido

---

## 12. Conclusiones

El desarrollo de **Gestor de Materias** demostró que es posible construir una plataforma académica completa y de calidad profesional usando Flutter y Supabase como stack principal.

**Conclusiones técnicas:**
- Flutter demostró ser un framework maduro para apps educativas multiplataforma, con excelente rendimiento en Android y Web
- El patrón Provider + ChangeNotifier es suficiente para proyectos de esta escala sin necesidad de soluciones más complejas (Riverpod, BLoC)
- Supabase simplificó enormemente el backend, eliminando la necesidad de un servidor propio
- La integración de Claude AI añadió un valor diferenciador significativo al visor de PDFs
- Supabase Realtime transformó la app de single-user a collaborative sin cambios mayores en la arquitectura

**Conclusiones pedagógicas:**
- La centralización de herramientas reduce la carga cognitiva del alumno
- La retroalimentación docente en tiempo real mejora el ciclo de aprendizaje
- Las funciones de organización (Pomodoro, racha, calendario) promueven hábitos de estudio saludables

---

## 13. Referencias

- Flutter Documentation (2025). *Flutter — Build apps for any screen*. https://flutter.dev/docs
- Google. (2025). *Dart programming language*. https://dart.dev
- Supabase. (2025). *Supabase Docs — Realtime, Auth, Storage*. https://supabase.com/docs
- Anthropic. (2025). *Claude API Documentation*. https://docs.anthropic.com
- Martin, R. C. (2017). *Clean Architecture: A Craftsman's Guide to Software Structure and Design*. Prentice Hall.
- Google Material Design. (2025). *Material Design 3*. https://m3.material.io
- Cirill, F. (1992). *The Pomodoro Technique*. FC Garage.
- Fowler, M. (2002). *Patterns of Enterprise Application Architecture*. Addison-Wesley.

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

Se concede permiso, de forma gratuita, a cualquier persona que obtenga
una copia de este software y archivos de documentación asociados, para
utilizar el software sin restricciones, incluyendo los derechos de usar,
copiar, modificar, fusionar, publicar, distribuir, sublicenciar y/o
vender copias del software.
```

<div align="center">

Hecho con ❤️ y Flutter · Universidad de Monterrey · 2025

⭐ Si te fue útil, dale una estrella al repo

</div>
