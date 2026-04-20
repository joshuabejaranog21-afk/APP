# Gestor de Materias

Aplicación Flutter para gestión académica de alumnos y maestros, con backend en Supabase.

---

## Funcionalidades actuales

- Modo alumno y modo maestro
- Materias, tareas, calificaciones y notas
- Visor de PDFs con IA (Claude), TTS, Pomodoro y selección/subrayado de texto (pdfrx)
- Horario semanal y estadísticas
- Búsqueda global
- Notificaciones locales
- Sincronización con Supabase (fallback local)

---

## Pendientes / Próximas funcionalidades

### Entrega de actividades con archivo

**Descripción:**
El maestro puede adjuntar un PDF de instrucciones al asignar una tarea. El alumno debe subir un archivo para marcarla como entregada. El maestro puede revisar cada entrega.

**Flujo maestro (`AsignarTareaScreen`):**
- Botón "Adjuntar PDF de instrucciones" → FilePicker → sube a Supabase Storage bucket `instrucciones/` → guarda URL en `Tarea.pdfInstruccionesUrl`
- Switch "Requiere entrega de archivo" → `Tarea.requiereEntrega = true`

**Flujo alumno (`TareasScreen`):**
- Si la tarea tiene `pdfInstruccionesUrl`, mostrar botón "Ver instrucciones" que abre el PDF
- Si tiene `requiereEntrega`, al tocar la tarea mostrar diálogo para subir archivo (PDF/imagen) en lugar de marcarla directamente como entregada
- Al subir, se crea un `EntregaAlumno` y se sube a Supabase Storage bucket `entregas/{tareaId}/{nombre}_{timestamp}`

**Flujo maestro (revisión en `GrupoDetailScreen`):**
- En la pestaña Tareas del grupo, cada tarea muestra badge "X/Y entregas"
- Al tocar: lista de alumnos con su archivo, fecha de entrega, estado (revisado/pendiente)
- Puede marcar como revisado y agregar comentario al alumno

**Modelos nuevos / cambios:**

```dart
// Agregar a tarea.dart
class EntregaAlumno {
  final String id;
  String alumnoNombre;
  String archivoUrl;        // URL en Supabase Storage
  String archivoNombre;
  DateTime fechaEntrega;
  bool revisado;
  String comentarioMaestro;
}

// Campos nuevos en Tarea:
String? pdfInstruccionesUrl;
bool requiereEntrega;           // default: false
List<EntregaAlumno> entregas;   // default: []
```

**Archivos a crear/modificar:**
- `lib/models/tarea.dart` — agregar `EntregaAlumno`, nuevos campos en `Tarea`
- `lib/services/api_service.dart` — agregar `EntregasStorageApi`
- `lib/providers/app_provider.dart` — agregar `agregarEntrega()`, `marcarEntregaRevisada()`
- `lib/screens/maestro/asignar_tarea_screen.dart` — picker de PDF + toggle requiere entrega
- `lib/screens/tareas/tareas_screen.dart` — botón ver PDF + diálogo subir archivo
- `lib/screens/maestro/grupo_detail_screen.dart` — pestaña de entregas por tarea
- `supabase_storage_setup.sql` — agregar buckets `instrucciones` y `entregas`
