# 📖 Manual de Usuario — Gestor de Materias

**Versión:** 1.0  
**Plataforma:** Android / Web  
**Fecha:** Abril 2025

---

## Índice

1. [Introducción](#1-introducción)
2. [Requisitos del sistema](#2-requisitos-del-sistema)
3. [Inicio de sesión](#3-inicio-de-sesión)
4. [Selección de rol](#4-selección-de-rol)
5. [Rol Alumno](#5-rol-alumno)
6. [Rol Maestro](#6-rol-maestro)
7. [Rol Administrador](#7-rol-administrador)
8. [Cerrar sesión](#8-cerrar-sesión)

---

## 1. Introducción

**Gestor de Materias** es una aplicación académica que permite a alumnos, maestros y administradores gestionar de forma centralizada toda la actividad escolar: tareas, materias, calificaciones, horarios, documentos PDF y más.

La app cuenta con tres roles diferenciados, cada uno con su propio panel adaptado a sus necesidades.

---

## 2. Requisitos del sistema

| Plataforma | Requisito mínimo |
|-----------|-----------------|
| Android | Versión 6.0 (API 23) o superior |
| Web | Chrome 90+ o Edge 90+ |
| Conexión | Internet para autenticación y sincronización |

---

## 3. Inicio de sesión

Al abrir la app por primera vez verás la pantalla de **inicio de sesión**.

### Iniciar sesión con cuenta existente
1. Ingresa tu **correo electrónico** y **contraseña**
2. Toca **"Iniciar sesión"**

### Crear cuenta nueva
1. Toca **"¿No tienes cuenta? Regístrate"**
2. Completa: nombre completo, correo y contraseña (mínimo 6 caracteres)
3. Confirma la contraseña y toca **"Crear cuenta"**

### Continuar sin cuenta
- Toca **"Continuar sin cuenta"** para entrar como Invitado
- Los datos se guardarán solo en el dispositivo

---

## 4. Selección de rol

Después de iniciar sesión, elige cómo deseas ingresar:

| Tarjeta | Descripción |
|---------|-------------|
| 🎓 **Soy Alumno** | Acceso al panel de gestión personal |
| 👨‍🏫 **Soy Maestro** | Acceso al panel de docente |
| 🛡️ **Administrador** | Acceso al panel de administración |

> Puedes cambiar de rol en cualquier momento cerrando sesión o usando el ícono ⇄ en los paneles de Maestro y Admin.

---

## 5. Rol Alumno

### 5.1 Dashboard (Inicio)

La pantalla de inicio muestra:
- **Saludo personalizado** con tu nombre
- **Resumen** de tareas pendientes y materias activas
- **Frase del día** motivacional
- **Racha de estudio** si llevas días consecutivos estudiando
- **Acceso rápido** para agregar tareas

### 5.2 Materias

**Ver materias:** La pantalla lista todas tus materias con color, ícono y horario.

**Agregar materia:**
1. Toca el botón **+**
2. Ingresa nombre, profesor, aula, color e ícono
3. Define el horario semanal
4. Toca **"Guardar"**

**Detalle de materia:**
- Toca cualquier materia para ver sus tareas, calificaciones y notas
- Toca el ícono de lápiz para editar
- Desliza a la izquierda sobre la materia para eliminarla

### 5.3 Tareas

**Crear tarea:**
1. Toca el botón **+** (naranja)
2. Completa título, descripción, materia, fecha límite, prioridad y tipo
3. Agrega subtareas si lo necesitas
4. Toca **"Guardar"**

**Estados de una tarea:**
- ⚪ **Pendiente** — recién creada
- 🔵 **En progreso** — en proceso
- ✅ **Entregada** — completada

**Cambiar estado:** Toca el ícono circular a la izquierda del título de la tarea.

**Entregar tarea:**
1. Dentro de la card de la tarea, toca el botón **"Entregar"**
2. Escribe tu respuesta en el cuadro de texto (opcional)
3. Toca **"Adjuntar"** para subir archivos PDF, Word o imágenes (opcional)
4. Toca el botón verde **"Entregar"** o el FAB

**Filtros disponibles:** Pendientes / En progreso / Entregadas — usa las pestañas en la parte superior.

### 5.4 PDFs (Documentos)

**Agregar PDF:**
1. Ve a la pestaña **PDFs**
2. Toca **"Subir PDF"**
3. Selecciona el archivo desde tu dispositivo

**Leer un PDF:**
- Toca el documento para abrirlo
- Navega con gestos de deslizamiento entre páginas

**Funciones del visor:**
| Función | Cómo usarla |
|---------|-------------|
| 📝 Agregar nota | Toca el ícono de nota en la barra inferior |
| 🔊 Escuchar texto | Selecciona texto y toca el ícono de audio |
| 🤖 Preguntar a la IA | Selecciona texto y toca el ícono de IA |
| ⏱️ Pomodoro | Toca el ícono del temporizador |

### 5.5 Calendario

- Vista mensual con puntos de color indicando tareas por día
- Toca un día para ver las tareas de esa fecha
- Los colores corresponden a las materias

### 5.6 Horario

- Vista semanal (Lunes a Domingo)
- Las clases se muestran según el horario configurado en cada materia

### 5.7 Pomodoro

1. Ve a la pantalla **Pomodoro** desde el menú lateral
2. Toca **▶ Iniciar** para comenzar el temporizador
3. Por defecto: 25 min trabajo / 5 min descanso
4. Configura los tiempos en **Ajustes del Pomodoro**

### 5.8 Perfil

- Ve y edita tu nombre
- Activa/desactiva el **modo oscuro**
- Consulta tu **racha de estudio** y estadísticas
- Configura la **API Key de Claude** para el chat con IA
- Toca **"Cerrar sesión"** para salir

---

## 6. Rol Maestro

### 6.1 Tab Grupos

**Crear grupo:**
1. Toca el FAB **"Nuevo grupo"**
2. Ingresa nombre, color y descripción
3. Agrega alumnos con nombre y apellido
4. Toca **"Guardar"**

**Ver detalle de grupo:** Toca el grupo para ver sus alumnos y tareas asignadas.

### 6.2 Tab Anuncios

**Publicar anuncio:**
1. Toca el FAB **"Nuevo anuncio"**
2. Escribe el título y contenido
3. Selecciona el grupo destinatario (o déjalo en blanco para todos)
4. Activa **"Fijado"** si quieres que aparezca siempre al inicio
5. Toca **"Publicar"**

### 6.3 Tab Tareas

- Lista todas las tareas asignadas por el maestro
- Toca **"Asignar tarea"** (FAB) para crear una nueva
- Selecciona el grupo, fecha límite, tipo y descripción

### 6.4 Tab Calificar

- Muestra todas las tareas entregadas por los alumnos
- Las **pendientes de calificar** aparecen primero (en naranja)
- Las **ya calificadas** aparecen debajo (en verde)

**Calificar una entrega:**
1. Toca la tarea entregada
2. Lee la respuesta escrita y los archivos adjuntos del alumno
3. Mueve el slider para establecer la **calificación** (0 – 10)
4. O toca uno de los botones rápidos: 0, 5, 6, 7, 8, 9, 10
5. Escribe **retroalimentación** para el alumno (opcional)
6. Toca **"Guardar calificación"**

---

## 7. Rol Administrador

### 7.1 Tab Materias

- Lista todas las materias registradas en el sistema
- **Agregar:** Toca el FAB → ingresa nombre, profesor y aula
- **Editar:** Toca los tres puntos (...) → "Editar"
- **Eliminar:** Toca los tres puntos (...) → "Eliminar"

### 7.2 Tab Grupos

- Vista expandible que muestra cada grupo y su lista de alumnos
- **Nuevo grupo:** Toca el FAB → nombre y descripción
- **Editar grupo:** Ícono de lápiz en la tarjeta
- **Eliminar grupo:** Ícono de basura en la tarjeta

### 7.3 Tab Profesores

- Lista todos los profesores registrados
- **Agregar:** Toca el FAB → nombre, correo y especialidad
- **Editar:** Tres puntos → "Editar"
- **Asignar materia:** Tres puntos → "Asignar materia" → selecciona la materia
- **Eliminar:** Tres puntos → "Eliminar"

### 7.4 Tab Alumnos

- Lista todos los alumnos de todos los grupos
- **Agregar alumno:**
  1. Toca el FAB **"Nuevo alumno"**
  2. Ingresa nombre, apellido y selecciona el grupo
  3. Toca **"Agregar"**
- **Editar:** Tres puntos → "Editar"
- **Cambiar de grupo:** Tres puntos → "Cambiar grupo" → selecciona el nuevo grupo
- **Eliminar:** Tres puntos → "Eliminar"

---

## 8. Cerrar sesión

Desde cualquier rol:
1. Ve a **Perfil** (icono de persona, última pestaña en Alumno)
2. Desplázate hasta el final
3. Toca **"Cerrar sesión"**
4. Confirma en el diálogo

Al cerrar sesión serás redirigido a la pantalla de login.

---

*Manual generado para Gestor de Materias v1.0 — Abril 2025*
