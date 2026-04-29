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
