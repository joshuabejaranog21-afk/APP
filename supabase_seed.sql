-- ================================================================
-- Gestor de Materias — Datos de prueba (Seed)
-- Paste this in: Supabase Dashboard → SQL Editor → Run
-- (Corre supabase_schema.sql PRIMERO si aún no lo has hecho)
-- ================================================================

-- ── MATERIAS ──────────────────────────────────────────────────
INSERT INTO materias (id, data) VALUES 
('mat-001', '{
  "id": "mat-001",
  "nombre": "Cálculo Diferencial",
  "profesor": "Dr. Ramírez Torres",
  "aula": "A-204",
  "colorValue": 4280391411,
  "icono": "calculate",
  "notaObjetivo": 8.0,
  "horarios": [
    {"diaSemana": 1, "horaInicio": "07:00", "horaFin": "09:00"},
    {"diaSemana": 3, "horaInicio": "07:00", "horaFin": "09:00"},
    {"diaSemana": 5, "horaInicio": "07:00", "horaFin": "08:00"}
  ]
}'),
('mat-002', '{
  "id": "mat-002",
  "nombre": "Programación Orientada a Objetos",
  "profesor": "Ing. López Mendoza",
  "aula": "Lab-B3",
  "colorValue": 4284513712,
  "icono": "code",
  "notaObjetivo": 9.0,
  "horarios": [
    {"diaSemana": 2, "horaInicio": "10:00", "horaFin": "12:00"},
    {"diaSemana": 4, "horaInicio": "10:00", "horaFin": "12:00"}
  ]
}'),
('mat-003', '{
  "id": "mat-003",
  "nombre": "Base de Datos",
  "profesor": "Mtra. García Soto",
  "aula": "Lab-B1",
  "colorValue": 4294944768,
  "icono": "storage",
  "notaObjetivo": 8.5,
  "horarios": [
    {"diaSemana": 1, "horaInicio": "12:00", "horaFin": "14:00"},
    {"diaSemana": 3, "horaInicio": "12:00", "horaFin": "14:00"}
  ]
}'),
('mat-004', '{
  "id": "mat-004",
  "nombre": "Inglés Técnico IV",
  "profesor": "Lic. Martínez Cruz",
  "aula": "C-101",
  "colorValue": 4283215696,
  "icono": "language",
  "notaObjetivo": 7.5,
  "horarios": [
    {"diaSemana": 2, "horaInicio": "08:00", "horaFin": "10:00"},
    {"diaSemana": 5, "horaInicio": "08:00", "horaFin": "10:00"}
  ]
}'),
('mat-005', '{
  "id": "mat-005",
  "nombre": "Estructuras de Datos",
  "profesor": "Dr. Hernández Ruiz",
  "aula": "Lab-A2",
  "colorValue": 4294198070,
  "icono": "account_tree",
  "notaObjetivo": 8.0,
  "horarios": [
    {"diaSemana": 3, "horaInicio": "14:00", "horaFin": "16:00"},
    {"diaSemana": 5, "horaInicio": "14:00", "horaFin": "16:00"}
  ]
}')
ON CONFLICT (id) DO NOTHING;

-- ── TAREAS ────────────────────────────────────────────────────
-- estado: 0=pendiente, 1=enProgreso, 2=entregada
-- prioridad: 0=baja, 1=media, 2=alta
-- tipo: 0=tarea, 1=examen, 2=quiz, 3=proyecto, 4=exposicion, 5=laboratorio, 6=lectura, 7=otro
INSERT INTO tareas (id, data) VALUES
('tar-001', '{
  "id": "tar-001",
  "titulo": "Derivadas parciales — Ejercicios 3.1 al 3.5",
  "descripcion": "Resolver los ejercicios del capítulo 3 del libro de Stewart",
  "materiaId": "mat-001",
  "fechaLimite": "2026-04-18T23:59:00.000",
  "estado": 1,
  "prioridad": 2,
  "tipo": 0,
  "fechaCreacion": "2026-04-10T09:00:00.000",
  "notificado": false,
  "asignadoPorMaestro": false,
  "grupoId": null,
  "esRecurrente": false,
  "completadaEn": null,
  "subtareas": [
    {"titulo": "Ejercicio 3.1 (límites)", "completada": true},
    {"titulo": "Ejercicio 3.2 (regla de la cadena)", "completada": true},
    {"titulo": "Ejercicio 3.3 (implícita)", "completada": false},
    {"titulo": "Ejercicio 3.4 (máximos y mínimos)", "completada": false},
    {"titulo": "Ejercicio 3.5 (optimización)", "completada": false}
  ]
}'),
('tar-002', '{
  "id": "tar-002",
  "titulo": "Examen Parcial 2 — Cálculo",
  "descripcion": "Temas: derivadas, integrales básicas y regla de la cadena",
  "materiaId": "mat-001",
  "fechaLimite": "2026-04-22T08:00:00.000",
  "estado": 0,
  "prioridad": 2,
  "tipo": 1,
  "fechaCreacion": "2026-04-08T10:00:00.000",
  "notificado": false,
  "asignadoPorMaestro": true,
  "grupoId": null,
  "esRecurrente": false,
  "completadaEn": null,
  "subtareas": [
    {"titulo": "Repasar derivadas implícitas", "completada": false},
    {"titulo": "Practicar integrales por sustitución", "completada": false},
    {"titulo": "Revisar fórmulas trigonométricas", "completada": false}
  ]
}'),
('tar-003', '{
  "id": "tar-003",
  "titulo": "Proyecto Final — Sistema de Biblioteca",
  "descripcion": "Implementar un sistema CRUD con herencia, polimorfismo e interfaces",
  "materiaId": "mat-002",
  "fechaLimite": "2026-05-05T23:59:00.000",
  "estado": 1,
  "prioridad": 2,
  "tipo": 3,
  "fechaCreacion": "2026-04-01T08:00:00.000",
  "notificado": false,
  "asignadoPorMaestro": true,
  "grupoId": null,
  "esRecurrente": false,
  "completadaEn": null,
  "subtareas": [
    {"titulo": "Diseño de clases UML", "completada": true},
    {"titulo": "Clase Libro con herencia", "completada": true},
    {"titulo": "Clase Revista con herencia", "completada": false},
    {"titulo": "Interfaz Prestable", "completada": false},
    {"titulo": "CRUD completo con archivos", "completada": false},
    {"titulo": "Menú de usuario", "completada": false},
    {"titulo": "Pruebas y documentación", "completada": false}
  ]
}'),
('tar-004', '{
  "id": "tar-004",
  "titulo": "Normalización de base de datos — Taller",
  "descripcion": "Llevar el esquema del taller a 3FN y justificar cada paso",
  "materiaId": "mat-003",
  "fechaLimite": "2026-04-17T23:59:00.000",
  "estado": 0,
  "prioridad": 1,
  "tipo": 0,
  "fechaCreacion": "2026-04-12T11:00:00.000",
  "notificado": false,
  "asignadoPorMaestro": true,
  "grupoId": null,
  "esRecurrente": false,
  "completadaEn": null,
  "subtareas": [
    {"titulo": "1FN — eliminar grupos repetitivos", "completada": false},
    {"titulo": "2FN — eliminar dependencias parciales", "completada": false},
    {"titulo": "3FN — eliminar dependencias transitivas", "completada": false}
  ]
}'),
('tar-005', '{
  "id": "tar-005",
  "titulo": "Quiz de vocabulario técnico — Unit 7",
  "descripcion": "Vocabulario de redes y seguridad informática en inglés",
  "materiaId": "mat-004",
  "fechaLimite": "2026-04-16T10:00:00.000",
  "estado": 2,
  "prioridad": 1,
  "tipo": 2,
  "fechaCreacion": "2026-04-13T08:00:00.000",
  "notificado": false,
  "asignadoPorMaestro": true,
  "grupoId": null,
  "esRecurrente": false,
  "completadaEn": "2026-04-16T10:30:00.000",
  "subtareas": []
}'),
('tar-006', '{
  "id": "tar-006",
  "titulo": "Implementar Lista Enlazada en C++",
  "descripcion": "Operaciones: insertar, eliminar, buscar, invertir y detectar ciclos",
  "materiaId": "mat-005",
  "fechaLimite": "2026-04-24T23:59:00.000",
  "estado": 0,
  "prioridad": 2,
  "tipo": 5,
  "fechaCreacion": "2026-04-11T14:00:00.000",
  "notificado": false,
  "asignadoPorMaestro": false,
  "grupoId": null,
  "esRecurrente": false,
  "completadaEn": null,
  "subtareas": [
    {"titulo": "Estructura del nodo", "completada": false},
    {"titulo": "Insertar al inicio / final", "completada": false},
    {"titulo": "Eliminar por valor", "completada": false},
    {"titulo": "Búsqueda lineal", "completada": false},
    {"titulo": "Invertir lista", "completada": false},
    {"titulo": "Detectar ciclo (Floyd)", "completada": false}
  ]
}'),
('tar-007', '{
  "id": "tar-007",
  "titulo": "Lectura: Capítulo 5 — Árboles Binarios",
  "descripcion": "Leer y hacer resumen del capítulo 5 de Cormen",
  "materiaId": "mat-005",
  "fechaLimite": "2026-04-19T08:00:00.000",
  "estado": 0,
  "prioridad": 0,
  "tipo": 6,
  "fechaCreacion": "2026-04-14T09:00:00.000",
  "notificado": false,
  "asignadoPorMaestro": false,
  "grupoId": null,
  "esRecurrente": true,
  "completadaEn": null,
  "subtareas": []
}'),
('tar-008', '{
  "id": "tar-008",
  "titulo": "Consultas SQL avanzadas — Práctica 4",
  "descripcion": "JOINs, subconsultas y funciones de agregación",
  "materiaId": "mat-003",
  "fechaLimite": "2026-04-20T23:59:00.000",
  "estado": 2,
  "prioridad": 1,
  "tipo": 5,
  "fechaCreacion": "2026-04-07T12:00:00.000",
  "notificado": false,
  "asignadoPorMaestro": true,
  "grupoId": null,
  "esRecurrente": false,
  "completadaEn": "2026-04-14T20:15:00.000",
  "subtareas": [
    {"titulo": "INNER JOIN entre 3 tablas", "completada": true},
    {"titulo": "Subconsulta correlacionada", "completada": true},
    {"titulo": "GROUP BY + HAVING", "completada": true}
  ]
}')
ON CONFLICT (id) DO NOTHING;

-- ── CALIFICACIONES ────────────────────────────────────────────
-- nota y notaMaxima en escala 0–10; porcentaje = peso en la materia
INSERT INTO calificaciones (id, data) VALUES
('cal-001', '{
  "id": "cal-001",
  "nombre": "Parcial 1",
  "nota": 8.5,
  "notaMaxima": 10.0,
  "porcentaje": 30,
  "materiaId": "mat-001",
  "fecha": "2026-03-10T10:00:00.000"
}'),
('cal-002', '{
  "id": "cal-002",
  "nombre": "Tareas acumuladas",
  "nota": 9.2,
  "notaMaxima": 10.0,
  "porcentaje": 20,
  "materiaId": "mat-001",
  "fecha": "2026-03-28T10:00:00.000"
}'),
('cal-003', '{
  "id": "cal-003",
  "nombre": "Parcial 1",
  "nota": 9.5,
  "notaMaxima": 10.0,
  "porcentaje": 30,
  "materiaId": "mat-002",
  "fecha": "2026-03-12T10:00:00.000"
}'),
('cal-004', '{
  "id": "cal-004",
  "nombre": "Proyecto Parcial",
  "nota": 8.8,
  "notaMaxima": 10.0,
  "porcentaje": 20,
  "materiaId": "mat-002",
  "fecha": "2026-04-02T10:00:00.000"
}'),
('cal-005', '{
  "id": "cal-005",
  "nombre": "Parcial 1",
  "nota": 7.5,
  "notaMaxima": 10.0,
  "porcentaje": 30,
  "materiaId": "mat-003",
  "fecha": "2026-03-14T10:00:00.000"
}'),
('cal-006', '{
  "id": "cal-006",
  "nombre": "Práctica 1–3",
  "nota": 9.0,
  "notaMaxima": 10.0,
  "porcentaje": 25,
  "materiaId": "mat-003",
  "fecha": "2026-04-01T10:00:00.000"
}'),
('cal-007', '{
  "id": "cal-007",
  "nombre": "Examen oral",
  "nota": 8.0,
  "notaMaxima": 10.0,
  "porcentaje": 25,
  "materiaId": "mat-004",
  "fecha": "2026-03-20T10:00:00.000"
}'),
('cal-008', '{
  "id": "cal-008",
  "nombre": "Parcial 1",
  "nota": 9.0,
  "notaMaxima": 10.0,
  "porcentaje": 30,
  "materiaId": "mat-005",
  "fecha": "2026-03-18T10:00:00.000"
}')
ON CONFLICT (id) DO NOTHING;

-- ── NOTAS ─────────────────────────────────────────────────────
-- colorValue: 0xFFFFF9C4 = amarillo, 0xFFE8F5E9 = verde, 0xFFE3F2FD = azul
INSERT INTO notas (id, data) VALUES
('not-001', '{
  "id": "not-001",
  "titulo": "Reglas de derivación",
  "contenido": "• Regla de la potencia: d/dx[xⁿ] = nxⁿ⁻¹\n• Regla del producto: (uv)'' = u''v + uv''\n• Regla del cociente: (u/v)'' = (u''v − uv'')/v²\n• Regla de la cadena: d/dx[f(g(x))] = f''(g(x))·g''(x)\n• Derivada de eˣ = eˣ\n• Derivada de ln(x) = 1/x\n• Derivada de sen(x) = cos(x)\n• Derivada de cos(x) = −sen(x)",
  "materiaId": "mat-001",
  "fechaCreacion": "2026-03-05T10:00:00.000",
  "fechaModificacion": "2026-04-10T15:30:00.000",
  "colorValue": 4294967236
}'),
('not-002', '{
  "id": "not-002",
  "titulo": "Principios de POO",
  "contenido": "Los 4 pilares de la Programación Orientada a Objetos:\n\n1. ENCAPSULAMIENTO — ocultar estado interno, exponer solo métodos públicos\n2. HERENCIA — una clase hija reutiliza atributos y métodos de la clase padre\n3. POLIMORFISMO — una misma operación se comporta distinto según el objeto\n4. ABSTRACCIÓN — modelar solo los aspectos relevantes del problema\n\nUML básico:\n- (-) privado  (+) público  (#) protegido",
  "materiaId": "mat-002",
  "fechaCreacion": "2026-03-10T11:00:00.000",
  "fechaModificacion": "2026-04-05T09:00:00.000",
  "colorValue": 4289591785
}'),
('not-003', '{
  "id": "not-003",
  "titulo": "Formas normales — resumen",
  "contenido": "1FN: sin grupos repetitivos, valores atómicos\n2FN: en 1FN + sin dependencias parciales (todo atributo depende de TODA la clave)\n3FN: en 2FN + sin dependencias transitivas (no-primo → no-primo)\nBCNF: para toda dependencia X→Y, X es superclave\n\nPasos prácticos:\n1. Identificar clave primaria\n2. Buscar dependencias funcionales\n3. Descomponer hasta eliminar anomalías",
  "materiaId": "mat-003",
  "fechaCreacion": "2026-03-15T12:00:00.000",
  "fechaModificacion": "2026-04-12T18:00:00.000",
  "colorValue": 4293848252
}'),
('not-004', '{
  "id": "not-004",
  "titulo": "Vocabulario Unit 7 — Networking",
  "contenido": "firewall → cortafuegos / firewall\nbandwidth → ancho de banda\nlatency → latencia\nthroughput → rendimiento\npacket → paquete\nrouter → enrutador\nswitch → conmutador\nsubnet → subred\nVPN → Red Privada Virtual\nencryption → cifrado\nauthentication → autenticación",
  "materiaId": "mat-004",
  "fechaCreacion": "2026-04-13T08:30:00.000",
  "fechaModificacion": "2026-04-13T08:30:00.000",
  "colorValue": 4294967236
}'),
('not-005', '{
  "id": "not-005",
  "titulo": "Complejidad algorítmica",
  "contenido": "Notación Big-O más comunes:\nO(1)       — constante       ej: acceso a array\nO(log n)   — logarítmica     ej: búsqueda binaria\nO(n)       — lineal          ej: búsqueda lineal\nO(n log n) — linealítmica    ej: merge sort, heap sort\nO(n²)      — cuadrática      ej: bubble sort, insertion sort\nO(2ⁿ)      — exponencial     ej: subconjuntos\n\nRegla: siempre analizar el PEOR caso (worst-case).",
  "materiaId": "mat-005",
  "fechaCreacion": "2026-03-20T14:00:00.000",
  "fechaModificacion": "2026-04-11T16:00:00.000",
  "colorValue": 4289591785
}')
ON CONFLICT (id) DO NOTHING;

-- ── GRUPOS ────────────────────────────────────────────────────
INSERT INTO grupos (id, data) VALUES
('grp-001', '{
  "id": "grp-001",
  "nombre": "Equipo Proyecto BD",
  "colorValue": 4294944768,
  "descripcion": "Grupo para coordinar el proyecto final de Base de Datos",
  "alumnos": [
    {"id": "alu-01", "nombre": "Joshua",   "apellido": "Béjar",    "colorValue": 4280391411},
    {"id": "alu-02", "nombre": "Valeria",  "apellido": "Ríos",     "colorValue": 4284513712},
    {"id": "alu-03", "nombre": "Miguel",   "apellido": "Sandoval", "colorValue": 4283215696},
    {"id": "alu-04", "nombre": "Fernanda", "apellido": "Castro",   "colorValue": 4294198070}
  ]
}'),
('grp-002', '{
  "id": "grp-002",
  "nombre": "Estudio Cálculo",
  "colorValue": 4280391411,
  "descripcion": "Sesiones de estudio para el parcial 2",
  "alumnos": [
    {"id": "alu-01", "nombre": "Joshua",  "apellido": "Béjar",   "colorValue": 4280391411},
    {"id": "alu-05", "nombre": "Andrés",  "apellido": "Torres",  "colorValue": 4284513712},
    {"id": "alu-06", "nombre": "Daniela", "apellido": "Morales", "colorValue": 4294944768}
  ]
}')
ON CONFLICT (id) DO NOTHING;

-- ── ANUNCIOS ──────────────────────────────────────────────────
INSERT INTO anuncios (id, data) VALUES
('ann-001', '{
  "id": "ann-001",
  "titulo": "Cambio de salón — Cálculo jueves",
  "cuerpo": "La clase del jueves 17 de abril se moverá al salón B-302 por mantenimiento en A-204. Lleguen puntual.",
  "grupoId": null,
  "fecha": "2026-04-14T18:00:00.000",
  "fijado": true
}'),
('ann-002', '{
  "id": "ann-002",
  "titulo": "Entrega proyecto BD — recordatorio",
  "cuerpo": "Recuerden subir el repositorio de GitHub antes del domingo 5 de mayo a las 23:59. El link de entrega está en el classroom.",
  "grupoId": "grp-001",
  "fecha": "2026-04-15T09:00:00.000",
  "fijado": false
}'),
('ann-003', '{
  "id": "ann-003",
  "titulo": "Asesoría extra — Estructuras de Datos",
  "cuerpo": "El Dr. Hernández abrió asesorías los viernes de 16:00 a 18:00 en el Lab-A2. Sin cita previa.",
  "grupoId": null,
  "fecha": "2026-04-13T12:00:00.000",
  "fijado": false
}')
ON CONFLICT (id) DO NOTHING;
