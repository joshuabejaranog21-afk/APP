require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

// ─── Conexión a PostgreSQL ────────────────────────────────────
const pool = new Pool({
  host:     process.env.DB_HOST     || 'localhost',
  port:     parseInt(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME     || 'gestor_tareas',
  user:     process.env.DB_USER     || 'postgres',
  password: process.env.DB_PASSWORD || '',
  client_encoding: 'UTF8',
});

pool.connect()
  .then(() => console.log('✅ Conectado a PostgreSQL'))
  .catch(err => console.error('❌ Error de conexión:', err.message));

// ─── Health check ─────────────────────────────────────────────
app.get('/', (req, res) => res.json({ status: 'ok', app: 'Gestor Tareas API' }));

// ═══════════════════════════════════════════════════════════════
// MATERIAS
// ═══════════════════════════════════════════════════════════════

// GET /materias
app.get('/materias', async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT m.*,
        COALESCE(json_agg(h ORDER BY h.dia_semana) FILTER (WHERE h.id IS NOT NULL), '[]') AS horarios
      FROM materias m
      LEFT JOIN horarios_clase h ON h.materia_id = m.id
      GROUP BY m.id
      ORDER BY m.nombre
    `);
    res.json(rows.map(toMateria));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /materias
app.post('/materias', async (req, res) => {
  const { id, nombre, profesor, aula, colorValue, icono, notaObjetivo, horarios } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      `INSERT INTO materias (id, nombre, profesor, aula, color_value, icono, nota_objetivo)
       VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [id, nombre, profesor || '', aula || '', colorValue, icono || 'book', notaObjetivo]
    );
    if (horarios?.length) {
      for (const h of horarios) {
        await client.query(
          `INSERT INTO horarios_clase (materia_id, dia_semana, hora_inicio, hora_fin)
           VALUES ($1,$2,$3,$4)`,
          [id, h.diaSemana, h.horaInicio, h.horaFin]
        );
      }
    }
    await client.query('COMMIT');
    res.status(201).json({ id });
  } catch (e) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: e.message });
  } finally { client.release(); }
});

// PUT /materias/:id
app.put('/materias/:id', async (req, res) => {
  const { nombre, profesor, aula, colorValue, icono, notaObjetivo, horarios } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      `UPDATE materias SET nombre=$1, profesor=$2, aula=$3, color_value=$4, icono=$5, nota_objetivo=$6
       WHERE id=$7`,
      [nombre, profesor, aula, colorValue, icono, notaObjetivo, req.params.id]
    );
    await client.query('DELETE FROM horarios_clase WHERE materia_id=$1', [req.params.id]);
    if (horarios?.length) {
      for (const h of horarios) {
        await client.query(
          `INSERT INTO horarios_clase (materia_id, dia_semana, hora_inicio, hora_fin)
           VALUES ($1,$2,$3,$4)`,
          [req.params.id, h.diaSemana, h.horaInicio, h.horaFin]
        );
      }
    }
    await client.query('COMMIT');
    res.json({ ok: true });
  } catch (e) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: e.message });
  } finally { client.release(); }
});

// DELETE /materias/:id
app.delete('/materias/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM materias WHERE id=$1', [req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ═══════════════════════════════════════════════════════════════
// TAREAS
// ═══════════════════════════════════════════════════════════════

// GET /tareas
app.get('/tareas', async (req, res) => {
  try {
    const { rows } = await pool.query(`SELECT * FROM tareas ORDER BY fecha_limite`);
    res.json(rows.map(toTarea));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /tareas?grupo_id=xxx
app.get('/tareas/grupo/:grupoId', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT * FROM tareas WHERE grupo_id=$1 ORDER BY fecha_limite`,
      [req.params.grupoId]
    );
    res.json(rows.map(toTarea));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /tareas
app.post('/tareas', async (req, res) => {
  const { id, titulo, descripcion, materiaId, fechaLimite, estado, prioridad,
          tipo, notificado, asignadoPorMaestro, grupoId } = req.body;
  try {
    await pool.query(
      `INSERT INTO tareas (id, materia_id, grupo_id, titulo, descripcion, fecha_limite,
        estado, prioridad, tipo, notificado, asignado_por_maestro)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)`,
      [id, materiaId, grupoId || null, titulo, descripcion || '',
       fechaLimite, estado ?? 0, prioridad ?? 1, tipo ?? 0,
       notificado ?? false, asignadoPorMaestro ?? false]
    );
    res.status(201).json({ id });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// PUT /tareas/:id/estado
app.put('/tareas/:id/estado', async (req, res) => {
  try {
    await pool.query('UPDATE tareas SET estado=$1 WHERE id=$2', [req.body.estado, req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// PUT /tareas/:id
app.put('/tareas/:id', async (req, res) => {
  const { titulo, descripcion, fechaLimite, estado, prioridad, tipo } = req.body;
  try {
    await pool.query(
      `UPDATE tareas SET titulo=$1, descripcion=$2, fecha_limite=$3, estado=$4, prioridad=$5, tipo=$6
       WHERE id=$7`,
      [titulo, descripcion, fechaLimite, estado, prioridad, tipo, req.params.id]
    );
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// DELETE /tareas/:id
app.delete('/tareas/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM tareas WHERE id=$1', [req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ═══════════════════════════════════════════════════════════════
// GRUPOS
// ═══════════════════════════════════════════════════════════════

// GET /grupos
app.get('/grupos', async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT g.*,
        COALESCE(json_agg(a ORDER BY a.apellido) FILTER (WHERE a.id IS NOT NULL), '[]') AS alumnos
      FROM grupos g
      LEFT JOIN alumnos_grupo a ON a.grupo_id = g.id
      GROUP BY g.id
      ORDER BY g.nombre
    `);
    res.json(rows.map(toGrupo));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /grupos
app.post('/grupos', async (req, res) => {
  const { id, nombre, descripcion, colorValue } = req.body;
  try {
    await pool.query(
      `INSERT INTO grupos (id, nombre, descripcion, color_value) VALUES ($1,$2,$3,$4)`,
      [id, nombre, descripcion || '', colorValue]
    );
    res.status(201).json({ id });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// PUT /grupos/:id
app.put('/grupos/:id', async (req, res) => {
  const { nombre, descripcion, colorValue, alumnos } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      `UPDATE grupos SET nombre=$1, descripcion=$2, color_value=$3 WHERE id=$4`,
      [nombre, descripcion, colorValue, req.params.id]
    );
    // Sincronizar alumnos: eliminar los que ya no están, insertar nuevos
    if (alumnos !== undefined) {
      const ids = alumnos.map(a => a.id);
      if (ids.length > 0) {
        await client.query(
          `DELETE FROM alumnos_grupo WHERE grupo_id=$1 AND id != ALL($2::varchar[])`,
          [req.params.id, ids]
        );
      } else {
        await client.query(`DELETE FROM alumnos_grupo WHERE grupo_id=$1`, [req.params.id]);
      }
      for (const a of alumnos) {
        await client.query(
          `INSERT INTO alumnos_grupo (id, grupo_id, nombre, apellido, color_value)
           VALUES ($1,$2,$3,$4,$5)
           ON CONFLICT (id) DO UPDATE SET nombre=$3, apellido=$4, color_value=$5`,
          [a.id, req.params.id, a.nombre, a.apellido, a.colorValue]
        );
      }
    }
    await client.query('COMMIT');
    res.json({ ok: true });
  } catch (e) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: e.message });
  } finally { client.release(); }
});

// DELETE /grupos/:id
app.delete('/grupos/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM grupos WHERE id=$1', [req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ═══════════════════════════════════════════════════════════════
// ANUNCIOS
// ═══════════════════════════════════════════════════════════════

app.get('/anuncios', async (req, res) => {
  try {
    const { rows } = await pool.query(`SELECT * FROM anuncios ORDER BY fecha DESC`);
    res.json(rows.map(toAnuncio));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/anuncios', async (req, res) => {
  const { id, titulo, cuerpo, grupoId, fijado } = req.body;
  try {
    await pool.query(
      `INSERT INTO anuncios (id, titulo, cuerpo, grupo_id, fijado) VALUES ($1,$2,$3,$4,$5)`,
      [id, titulo, cuerpo, grupoId || null, fijado ?? false]
    );
    res.status(201).json({ id });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.put('/anuncios/:id/fijar', async (req, res) => {
  try {
    await pool.query(
      `UPDATE anuncios SET fijado = NOT fijado WHERE id=$1 RETURNING fijado`,
      [req.params.id]
    );
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/anuncios/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM anuncios WHERE id=$1', [req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ═══════════════════════════════════════════════════════════════
// NOTAS
// ═══════════════════════════════════════════════════════════════

app.get('/notas', async (req, res) => {
  try {
    const { rows } = await pool.query(`SELECT * FROM notas ORDER BY fecha_modificacion DESC`);
    res.json(rows.map(toNota));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/notas', async (req, res) => {
  const { id, titulo, contenido, materiaId, colorValue } = req.body;
  try {
    await pool.query(
      `INSERT INTO notas (id, materia_id, titulo, contenido, color_value) VALUES ($1,$2,$3,$4,$5)`,
      [id, materiaId, titulo, contenido || '', colorValue]
    );
    res.status(201).json({ id });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.put('/notas/:id', async (req, res) => {
  const { titulo, contenido, colorValue } = req.body;
  try {
    await pool.query(
      `UPDATE notas SET titulo=$1, contenido=$2, color_value=$3, fecha_modificacion=NOW() WHERE id=$4`,
      [titulo, contenido, colorValue, req.params.id]
    );
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/notas/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM notas WHERE id=$1', [req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ═══════════════════════════════════════════════════════════════
// CALIFICACIONES
// ═══════════════════════════════════════════════════════════════

app.get('/calificaciones', async (req, res) => {
  try {
    const { rows } = await pool.query(`SELECT * FROM calificaciones ORDER BY fecha DESC`);
    res.json(rows.map(toCalificacion));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/calificaciones', async (req, res) => {
  const { id, nombre, nota, notaMaxima, porcentaje, materiaId, fecha } = req.body;
  try {
    await pool.query(
      `INSERT INTO calificaciones (id, materia_id, nombre, nota, nota_maxima, porcentaje, fecha)
       VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [id, materiaId, nombre, nota, notaMaxima ?? 10, porcentaje, fecha ?? new Date()]
    );
    res.status(201).json({ id });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/calificaciones/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM calificaciones WHERE id=$1', [req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ═══════════════════════════════════════════════════════════════
// MAPPERS: DB row → JSON para Flutter
// ═══════════════════════════════════════════════════════════════

function toMateria(row) {
  return {
    id: row.id,
    nombre: row.nombre,
    profesor: row.profesor,
    aula: row.aula,
    colorValue: row.color_value,
    icono: row.icono,
    notaObjetivo: row.nota_objetivo ? parseFloat(row.nota_objetivo) : null,
    horarios: (row.horarios || []).map(h => ({
      diaSemana: h.dia_semana,
      horaInicio: h.hora_inicio,
      horaFin: h.hora_fin,
    })),
  };
}

function toTarea(row) {
  return {
    id: row.id,
    titulo: row.titulo,
    descripcion: row.descripcion,
    materiaId: row.materia_id,
    grupoId: row.grupo_id,
    fechaLimite: row.fecha_limite,
    fechaCreacion: row.fecha_creacion,
    estado: row.estado,
    prioridad: row.prioridad,
    tipo: row.tipo,
    notificado: row.notificado,
    asignadoPorMaestro: row.asignado_por_maestro,
  };
}

function toGrupo(row) {
  return {
    id: row.id,
    nombre: row.nombre,
    descripcion: row.descripcion,
    colorValue: row.color_value,
    alumnos: (row.alumnos || []).map(a => ({
      id: a.id,
      nombre: a.nombre,
      apellido: a.apellido,
      colorValue: a.color_value,
    })),
  };
}

function toAnuncio(row) {
  return {
    id: row.id,
    titulo: row.titulo,
    cuerpo: row.cuerpo,
    grupoId: row.grupo_id,
    fecha: row.fecha,
    fijado: row.fijado,
  };
}

function toNota(row) {
  return {
    id: row.id,
    titulo: row.titulo,
    contenido: row.contenido,
    materiaId: row.materia_id,
    colorValue: row.color_value,
    fechaCreacion: row.fecha_creacion,
    fechaModificacion: row.fecha_modificacion,
  };
}

function toCalificacion(row) {
  return {
    id: row.id,
    nombre: row.nombre,
    nota: parseFloat(row.nota),
    notaMaxima: parseFloat(row.nota_maxima),
    porcentaje: parseFloat(row.porcentaje),
    materiaId: row.materia_id,
    fecha: row.fecha,
  };
}

// ─── Iniciar servidor ─────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 API corriendo en http://localhost:${PORT}`);
  console.log(`   Endpoints disponibles:`);
  console.log(`   GET  /materias      GET  /tareas`);
  console.log(`   POST /materias      POST /tareas`);
  console.log(`   GET  /grupos        GET  /anuncios`);
  console.log(`   GET  /notas         GET  /calificaciones`);
});
