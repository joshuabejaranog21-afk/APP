-- ============================================================
-- GESTOR DE TAREAS ESCOLARES — Schema PostgreSQL
-- Ejecutar en pgAdmin: Query Tool → Run (F5)
-- ============================================================

-- Crear base de datos (ejecutar separado si no existe)
-- CREATE DATABASE gestor_tareas;

-- ─── Extensión para UUIDs ────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── Limpiar tablas si existen (para re-ejecución) ──────────
DROP TABLE IF EXISTS calificaciones   CASCADE;
DROP TABLE IF EXISTS notas            CASCADE;
DROP TABLE IF EXISTS tareas           CASCADE;
DROP TABLE IF EXISTS horarios_clase   CASCADE;
DROP TABLE IF EXISTS materias         CASCADE;
DROP TABLE IF EXISTS anuncios         CASCADE;
DROP TABLE IF EXISTS alumnos_grupo    CASCADE;
DROP TABLE IF EXISTS grupos           CASCADE;
DROP TABLE IF EXISTS usuarios         CASCADE;

-- ============================================================
-- TABLA: usuarios
-- ============================================================
CREATE TABLE usuarios (
  id           VARCHAR(36)  PRIMARY KEY DEFAULT gen_random_uuid()::text,
  nombre       VARCHAR(100) NOT NULL,
  apellido     VARCHAR(100) NOT NULL DEFAULT '',
  email        VARCHAR(150) UNIQUE,
  es_maestro   BOOLEAN      NOT NULL DEFAULT FALSE,
  color_value  INTEGER      NOT NULL DEFAULT 437460223, -- 0xFF6C63FF
  creado_en    TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: materias
-- ============================================================
CREATE TABLE materias (
  id            VARCHAR(36)  PRIMARY KEY,
  usuario_id    VARCHAR(36)  REFERENCES usuarios(id) ON DELETE CASCADE,
  nombre        VARCHAR(100) NOT NULL,
  profesor      VARCHAR(100) NOT NULL DEFAULT '',
  aula          VARCHAR(50)  NOT NULL DEFAULT '',
  color_value   INTEGER      NOT NULL,
  icono         VARCHAR(50)  NOT NULL DEFAULT 'book',
  nota_objetivo DECIMAL(4,2),
  creado_en     TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: horarios_clase  (relación 1:N con materias)
-- ============================================================
CREATE TABLE horarios_clase (
  id           SERIAL       PRIMARY KEY,
  materia_id   VARCHAR(36)  NOT NULL REFERENCES materias(id) ON DELETE CASCADE,
  dia_semana   SMALLINT     NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
  -- 1=Lun 2=Mar 3=Mié 4=Jue 5=Vie 6=Sáb 7=Dom
  hora_inicio  VARCHAR(5)   NOT NULL, -- "08:00"
  hora_fin     VARCHAR(5)   NOT NULL  -- "09:30"
);

-- ============================================================
-- TABLA: tareas
-- ============================================================
CREATE TABLE tareas (
  id                   VARCHAR(36)  PRIMARY KEY,
  materia_id           VARCHAR(36)  NOT NULL REFERENCES materias(id) ON DELETE CASCADE,
  grupo_id             VARCHAR(36),  -- NULL si no es del maestro
  titulo               VARCHAR(200) NOT NULL,
  descripcion          TEXT         NOT NULL DEFAULT '',
  fecha_limite         DATE         NOT NULL,
  fecha_creacion       TIMESTAMP    NOT NULL DEFAULT NOW(),
  estado               SMALLINT     NOT NULL DEFAULT 0,
  -- 0=pendiente 1=enProgreso 2=entregada
  prioridad            SMALLINT     NOT NULL DEFAULT 1,
  -- 0=baja 1=media 2=alta
  tipo                 SMALLINT     NOT NULL DEFAULT 0,
  -- 0=tarea 1=examen 2=quiz 3=proyecto 4=exposicion 5=laboratorio 6=lectura 7=otro
  notificado           BOOLEAN      NOT NULL DEFAULT FALSE,
  asignado_por_maestro BOOLEAN      NOT NULL DEFAULT FALSE
);

-- ============================================================
-- TABLA: notas
-- ============================================================
CREATE TABLE notas (
  id                 VARCHAR(36)  PRIMARY KEY,
  materia_id         VARCHAR(36)  NOT NULL REFERENCES materias(id) ON DELETE CASCADE,
  titulo             VARCHAR(200) NOT NULL,
  contenido          TEXT         NOT NULL DEFAULT '',
  color_value        INTEGER      NOT NULL DEFAULT -24636,
  -- 0xFFFFF9C4 en decimal negativo (Integer overflow en Java/Dart)
  fecha_creacion     TIMESTAMP    NOT NULL DEFAULT NOW(),
  fecha_modificacion TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: calificaciones
-- ============================================================
CREATE TABLE calificaciones (
  id          VARCHAR(36)   PRIMARY KEY,
  materia_id  VARCHAR(36)   NOT NULL REFERENCES materias(id) ON DELETE CASCADE,
  nombre      VARCHAR(150)  NOT NULL,
  nota        DECIMAL(5,2)  NOT NULL,
  nota_maxima DECIMAL(5,2)  NOT NULL DEFAULT 10.0,
  porcentaje  DECIMAL(5,2)  NOT NULL,
  fecha       DATE          NOT NULL DEFAULT CURRENT_DATE
);

-- ============================================================
-- TABLA: grupos
-- ============================================================
CREATE TABLE grupos (
  id          VARCHAR(36)  PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  descripcion TEXT         NOT NULL DEFAULT '',
  color_value INTEGER      NOT NULL,
  creado_en   TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: alumnos_grupo
-- ============================================================
CREATE TABLE alumnos_grupo (
  id          VARCHAR(36)  PRIMARY KEY,
  grupo_id    VARCHAR(36)  NOT NULL REFERENCES grupos(id) ON DELETE CASCADE,
  nombre      VARCHAR(100) NOT NULL,
  apellido    VARCHAR(150) NOT NULL DEFAULT '',
  color_value INTEGER      NOT NULL,
  agregado_en TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: anuncios
-- ============================================================
CREATE TABLE anuncios (
  id        VARCHAR(36)  PRIMARY KEY,
  grupo_id  VARCHAR(36)  REFERENCES grupos(id) ON DELETE CASCADE,
  -- NULL = todos los grupos
  titulo    VARCHAR(200) NOT NULL,
  cuerpo    TEXT         NOT NULL,
  fecha     TIMESTAMP    NOT NULL DEFAULT NOW(),
  fijado    BOOLEAN      NOT NULL DEFAULT FALSE
);

-- Índice FK para tareas → grupos
ALTER TABLE tareas
  ADD CONSTRAINT fk_tareas_grupo
  FOREIGN KEY (grupo_id) REFERENCES grupos(id) ON DELETE SET NULL;

-- ============================================================
-- ÍNDICES para mejorar búsquedas comunes
-- ============================================================
CREATE INDEX idx_tareas_materia     ON tareas(materia_id);
CREATE INDEX idx_tareas_grupo       ON tareas(grupo_id);
CREATE INDEX idx_tareas_estado      ON tareas(estado);
CREATE INDEX idx_tareas_fecha       ON tareas(fecha_limite);
CREATE INDEX idx_notas_materia      ON notas(materia_id);
CREATE INDEX idx_calif_materia      ON calificaciones(materia_id);
CREATE INDEX idx_alumnos_grupo      ON alumnos_grupo(grupo_id);
CREATE INDEX idx_anuncios_grupo     ON anuncios(grupo_id);
CREATE INDEX idx_horarios_materia   ON horarios_clase(materia_id);

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

-- Materias
INSERT INTO materias (id, nombre, profesor, aula, color_value, icono, nota_objetivo) VALUES
  ('mat-01', 'Matemáticas',  'Prof. García',   'A-301', -9551105, 'calculate', 9.0),
  ('mat-02', 'Programación', 'Prof. López',    'B-205', -14575105,'code',      9.5),
  ('mat-03', 'Física',       'Prof. Ramírez',  'C-102', -26368,   'science',   8.5),
  ('mat-04', 'Historia',     'Prof. Martínez', 'A-205', -1761229, 'history',   8.0),
  ('mat-05', 'Inglés',       'Prof. Smith',    'B-101', -11751600,'language',  9.0),
  ('mat-06', 'Química',      'Prof. Torres',   'D-304', -16738680,'biotech',   8.5);

-- Horarios
INSERT INTO horarios_clase (materia_id, dia_semana, hora_inicio, hora_fin) VALUES
  ('mat-01', 1, '08:00', '09:30'), ('mat-01', 3, '08:00', '09:30'),
  ('mat-02', 2, '10:00', '11:30'), ('mat-02', 4, '10:00', '11:30'),
  ('mat-03', 1, '11:00', '12:30'), ('mat-03', 5, '09:00', '10:30'),
  ('mat-04', 2, '08:00', '09:30'), ('mat-04', 5, '11:00', '12:30'),
  ('mat-05', 3, '10:00', '11:30'), ('mat-05', 5, '13:00', '14:00'),
  ('mat-06', 4, '13:00', '14:30'), ('mat-06', 6, '09:00', '10:30');

-- Grupos
INSERT INTO grupos (id, nombre, descripcion, color_value) VALUES
  ('grp-01', '6°A Matutino',   '32 alumnos - Turno matutino',   -9551105),
  ('grp-02', '6°B Vespertino', '28 alumnos - Turno vespertino', -14575105),
  ('grp-03', '7°A Avanzado',   '25 alumnos - Grupo avanzado',   -11751600);

-- Alumnos del grupo 6°A
INSERT INTO alumnos_grupo (id, grupo_id, nombre, apellido, color_value) VALUES
  ('alu-01', 'grp-01', 'Ana',       'García López',      -9551105),
  ('alu-02', 'grp-01', 'Carlos',    'Martínez Ruiz',     -14575105),
  ('alu-03', 'grp-01', 'Sofía',     'Hernández Cruz',    -1499549),
  ('alu-04', 'grp-01', 'Diego',     'López Sánchez',     -11751600),
  ('alu-05', 'grp-01', 'Valentina', 'Ramírez Flores',    -26368),
  ('alu-06', 'grp-01', 'Miguel',    'Torres Vargas',     -6543440),
  ('alu-07', 'grp-01', 'Camila',    'Morales Jiménez',   -16738680),
  ('alu-08', 'grp-01', 'Andrés',    'Reyes Castro',      -693019),
  ('alu-09', 'grp-01', 'Isabella',  'Gutiérrez Mendoza', -13238906),
  ('alu-10', 'grp-01', 'José',      'Pérez Alvarado',    -8825528),
  ('alu-11', 'grp-01', 'Lucía',     'Díaz Ramos',        -10453621),
  ('alu-12', 'grp-01', 'Sebastián', 'Vega Ortega',       -13408563);

-- Alumnos del grupo 6°B
INSERT INTO alumnos_grupo (id, grupo_id, nombre, apellido, color_value) VALUES
  ('alu-13', 'grp-02', 'Mariana',   'Soto Navarro',      -1499549),
  ('alu-14', 'grp-02', 'Fernando',  'Luna Estrada',      -14575105),
  ('alu-15', 'grp-02', 'Daniela',   'Ríos Aguilar',      -11751600),
  ('alu-16', 'grp-02', 'Ricardo',   'Mora Pedraza',      -26368),
  ('alu-17', 'grp-02', 'Paola',     'Cruz Villanueva',   -6543440),
  ('alu-18', 'grp-02', 'Alejandro', 'Fuentes Blanco',    -16738680),
  ('alu-19', 'grp-02', 'Natalia',   'Herrera Montes',    -13238906),
  ('alu-20', 'grp-02', 'Emilio',    'Vargas Delgado',    -693019),
  ('alu-21', 'grp-02', 'Gabriela',  'Rojas Sandoval',    -8825528),
  ('alu-22', 'grp-02', 'Pablo',     'Medina Campos',     -10453621);

-- Alumnos del grupo 7°A
INSERT INTO alumnos_grupo (id, grupo_id, nombre, apellido, color_value) VALUES
  ('alu-23', 'grp-03', 'Valeria',   'Ángel Bravo',       -11751600),
  ('alu-24', 'grp-03', 'Rodrigo',   'Serrano Lara',      -9551105),
  ('alu-25', 'grp-03', 'Fernanda',  'Ibáñez Ponce',      -1499549),
  ('alu-26', 'grp-03', 'Tomás',     'Guerrero Arias',    -13408563),
  ('alu-27', 'grp-03', 'Regina',    'Salinas Pacheco',   -26368),
  ('alu-28', 'grp-03', 'Mateo',     'Contreras Vidal',   -6543440),
  ('alu-29', 'grp-03', 'Renata',    'Espinoza Trejo',    -13238906),
  ('alu-30', 'grp-03', 'Bruno',     'Acosta Palma',      -16738680);

-- Tareas de prueba
INSERT INTO tareas (id, materia_id, titulo, fecha_limite, estado, prioridad, tipo, asignado_por_maestro, grupo_id) VALUES
  ('tar-01', 'mat-01', 'Ejercicios de integrales',        CURRENT_DATE - 5,  0, 2, 0, FALSE, NULL),
  ('tar-02', 'mat-04', 'Ensayo Revolución Industrial',    CURRENT_DATE - 3,  0, 2, 0, FALSE, NULL),
  ('tar-04', 'mat-05', 'Examen parcial de Inglés',        CURRENT_DATE,      1, 2, 1, FALSE, NULL),
  ('tar-05', 'mat-06', 'Quiz: Tabla periódica',           CURRENT_DATE,      0, 2, 2, FALSE, NULL),
  ('tar-06', 'mat-02', 'Proyecto final: App móvil',       CURRENT_DATE + 2,  1, 2, 3, FALSE, NULL),
  ('tar-07', 'mat-04', 'Lectura cap. 7 y 8',              CURRENT_DATE + 3,  0, 0, 6, FALSE, NULL),
  ('tar-08', 'mat-02', 'Algoritmos de ordenamiento',      CURRENT_DATE + 4,  0, 1, 0, FALSE, NULL),
  ('tar-09', 'mat-03', 'Exposición: Relatividad',         CURRENT_DATE + 5,  0, 1, 4, FALSE, NULL),
  ('tar-11', 'mat-01', 'Examen de Álgebra lineal',        CURRENT_DATE + 10, 0, 2, 1, FALSE, NULL),
  ('tar-14', 'mat-02', 'Introducción a Flutter',          CURRENT_DATE - 10, 2, 1, 0, FALSE, NULL),
  ('tar-18', 'mat-01', 'Examen diagnóstico del maestro',  CURRENT_DATE + 1,  0, 2, 1, TRUE, 'grp-01'),
  ('tar-19', 'mat-02', 'Proyecto integrador del maestro', CURRENT_DATE + 20, 0, 2, 3, TRUE, 'grp-02');

-- Calificaciones
INSERT INTO calificaciones (id, materia_id, nombre, nota, nota_maxima, porcentaje, fecha) VALUES
  ('cal-01', 'mat-01', 'Primer Parcial',    8.5,  10, 30, CURRENT_DATE - 45),
  ('cal-02', 'mat-01', 'Quiz semana 3',     9.0,  10, 10, CURRENT_DATE - 30),
  ('cal-04', 'mat-02', 'Primer Parcial',    9.5,  10, 30, CURRENT_DATE - 40),
  ('cal-05', 'mat-02', 'Proyecto Flutter',  10.0, 10, 20, CURRENT_DATE - 20),
  ('cal-07', 'mat-03', 'Laboratorio 1',     7.0,  10, 20, CURRENT_DATE - 35),
  ('cal-08', 'mat-03', 'Examen cinemática', 8.5,  10, 30, CURRENT_DATE - 20),
  ('cal-11', 'mat-05', 'Speaking Unit 1-3', 9.5,  10, 20, CURRENT_DATE - 30),
  ('cal-13', 'mat-06', 'Lab: Reacciones',   9.0,  10, 20, CURRENT_DATE - 28);

-- Anuncios
INSERT INTO anuncios (id, titulo, cuerpo, grupo_id, fijado) VALUES
  ('ann-01', '🚨 Examen recuperativo este viernes',
   'El examen de recuperación del primer parcial se realizará este viernes en el aula C-102. Traer calculadora científica.',
   NULL, TRUE),
  ('ann-02', 'Cambio de horario — Semana Santa',
   'Durante la semana del 14 al 18 de abril no habrá clases presenciales. Las actividades se entregarán de forma virtual.',
   NULL, TRUE),
  ('ann-03', 'Material para laboratorio',
   'Para la práctica del próximo martes necesitan traer: bata, guantes de látex y lentes de seguridad.',
   'grp-01', FALSE),
  ('ann-04', 'Calificaciones parciales publicadas',
   'Las calificaciones del primer parcial ya están disponibles en la plataforma escolar.',
   NULL, FALSE);

-- ============================================================
-- VISTAS útiles para pgAdmin
-- ============================================================

-- Vista: tareas con nombre de materia
CREATE OR REPLACE VIEW v_tareas_detalle AS
SELECT
  t.id,
  t.titulo,
  m.nombre        AS materia,
  m.profesor,
  t.fecha_limite,
  t.estado,
  t.prioridad,
  t.tipo,
  t.asignado_por_maestro,
  g.nombre        AS grupo
FROM tareas t
JOIN materias m ON m.id = t.materia_id
LEFT JOIN grupos g ON g.id = t.grupo_id;

-- Vista: alumnos con su grupo
CREATE OR REPLACE VIEW v_alumnos_con_grupo AS
SELECT
  a.id,
  a.nombre || ' ' || a.apellido AS nombre_completo,
  g.nombre AS grupo,
  g.id     AS grupo_id
FROM alumnos_grupo a
JOIN grupos g ON g.id = a.grupo_id
ORDER BY g.nombre, a.apellido;

-- Vista: promedio por materia
CREATE OR REPLACE VIEW v_promedios_materias AS
SELECT
  m.nombre AS materia,
  ROUND(
    SUM((c.nota / c.nota_maxima) * c.porcentaje) /
    NULLIF(SUM(c.porcentaje), 0) * 100, 2
  ) AS promedio_ponderado
FROM calificaciones c
JOIN materias m ON m.id = c.materia_id
GROUP BY m.nombre
ORDER BY promedio_ponderado DESC;

-- ============================================================
-- VERIFICAR DATOS
-- ============================================================
-- SELECT * FROM v_tareas_detalle;
-- SELECT * FROM v_alumnos_con_grupo;
-- SELECT * FROM v_promedios_materias;
