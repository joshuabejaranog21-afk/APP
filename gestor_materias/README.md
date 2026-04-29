# 🎓 Gestor de Materias

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" />
  <img src="https://img.shields.io/badge/Supabase-2.5-green?logo=supabase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web-lightgrey" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" />
</p>

> Aplicación móvil y web para la gestión académica completa: materias, tareas, calificaciones, PDFs, horarios y más — con soporte para tres roles: **Alumno**, **Maestro** y **Administrador**.

---

## ✨ Características principales

| Módulo | Descripción |
|--------|-------------|
| 🔐 **Autenticación** | Login / registro con Supabase Auth |
| 📚 **Materias** | CRUD con color, ícono, horario y notas |
| ✅ **Tareas** | Prioridades, subtareas, recurrencia y entrega de archivos |
| 📅 **Calendario** | Vista mensual con tareas por día |
| 🕐 **Horario** | Vista semanal de clases |
| 📄 **PDFs** | Lector con notas, resaltado, TTS y chat con IA (Claude) |
| ⏱️ **Pomodoro** | Temporizador de estudio configurable |
| 👨‍🏫 **Panel Maestro** | Grupos, anuncios, asignación y calificación de tareas |
| 🛡️ **Panel Admin** | Gestión de materias, grupos, profesores y alumnos |
| 🌙 **Modo oscuro** | Tema claro/oscuro persistente |

---

## 🚀 Instalación

### Requisitos

- Flutter `>=3.10`
- Dart `>=3.0`
- Android SDK (para Android) o navegador moderno (para web)
- Cuenta en [Supabase](https://supabase.com)

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/gestor-materias.git
cd gestor-materias/APP/gestor_materias
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Supabase

En `lib/services/api_service.dart` actualiza con tus credenciales:

```dart
const String supabaseUrl     = 'https://TU_PROYECTO.supabase.co';
const String supabaseAnonKey = 'TU_ANON_KEY';
```

Ejecuta los scripts SQL en el dashboard de Supabase (SQL Editor):

```
supabase_schema.sql   ← estructura de tablas
supabase_seed.sql     ← datos de prueba (opcional)
```

### 4. Correr la app

```bash
# Android (emulador o dispositivo físico)
flutter run -d android

# Web
flutter run -d chrome

# Generar APK release
flutter build apk --release
```

---

## 🏗️ Arquitectura del proyecto

```
lib/
├── main.dart                      # Punto de entrada y routing principal
├── models/                        # Modelos de datos
│   ├── tarea.dart                 # Tarea, EntregaTarea, SubtareaItem
│   ├── materia.dart               # Materia con horario y calificaciones
│   ├── grupo.dart                 # Grupo y AlumnoGrupo
│   ├── profesor.dart              # Profesor
│   ├── nota.dart                  # Nota rápida
│   └── estudio_pdf.dart           # PDF con notas, historial IA
├── providers/
│   └── app_provider.dart          # Estado global (ChangeNotifier + SharedPreferences)
├── screens/                       # Pantallas organizadas por módulo
│   ├── auth/                      # Login y registro
│   ├── admin/                     # Panel de administrador
│   ├── maestro/                   # Panel de maestro
│   ├── tareas/                    # Tareas y entregas
│   ├── materias/                  # Materias y detalle
│   ├── pdfs/                      # Visor de PDFs
│   ├── calendario/                # Calendario
│   ├── horario/                   # Horario semanal
│   ├── pomodoro/                  # Timer Pomodoro
│   ├── perfil/                    # Perfil de usuario
│   └── rol/                       # Selección de rol
├── services/
│   ├── api_service.dart           # CRUD con Supabase
│   ├── claude_service.dart        # Integración Claude AI
│   └── notification_service.dart  # Notificaciones locales
└── theme/
    └── app_theme.dart             # Tema Material 3
```

---

## 👥 Roles de usuario

### 👨‍🎓 Alumno
- Gestionar materias, tareas y calificaciones personales
- Entregar tareas con texto y archivos adjuntos
- Leer PDFs con anotaciones, texto a voz y asistente IA
- Timer Pomodoro y calendario de actividades

### 👨‍🏫 Maestro
- Crear y gestionar grupos de alumnos
- Asignar tareas y publicar anuncios
- Calificar entregas con retroalimentación escrita

### 🛡️ Administrador
- Crear y editar materias
- Administrar grupos y asignar alumnos
- Registrar profesores y asignarles materias

---

## 🔧 Stack tecnológico

| Tecnología | Versión | Uso |
|-----------|---------|-----|
| **Flutter** | 3.41 | Framework UI multiplataforma |
| **Dart** | 3.x | Lenguaje de programación |
| **Supabase** | 2.5 | Base de datos PostgreSQL + Auth |
| **Provider** | 6.1 | Gestión de estado reactivo |
| **pdfrx** | 1.0 | Visualización y selección de PDFs |
| **Claude AI** | API | Chat inteligente sobre documentos |
| **flutter_tts** | 4.0 | Texto a voz en español |
| **flutter_local_notifications** | 18 | Recordatorios de tareas |
| **table_calendar** | 3.1 | Calendario interactivo |
| **fl_chart** | 0.69 | Gráficas de estadísticas |

---

## 📱 Compatibilidad

| Plataforma | Estado |
|-----------|--------|
| Android 6.0+ | ✅ Soportado |
| Web (Chrome / Edge) | ✅ Soportado |
| iOS | 🔄 En desarrollo |
| Windows Desktop | 🔄 En desarrollo |

---

## 📂 Base de datos

El proyecto incluye los siguientes scripts SQL:

| Archivo | Descripción |
|---------|-------------|
| `supabase_schema.sql` | Crea todas las tablas y políticas RLS |
| `supabase_seed.sql` | Inserta datos de prueba |
| `supabase_storage_setup.sql` | Configura el bucket de almacenamiento |

---

## 📄 Documentación adicional

- [Manual de Usuario](MANUAL_USUARIO.md)
- [Documento Técnico Académico](DOCUMENTO_ACADEMICO.md)

---

## 📄 Licencia

MIT © 2025 — Ingeniería en Sistemas de Información
