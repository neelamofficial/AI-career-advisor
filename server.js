require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static('public')); // put your index.html inside /public

const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME || 'career_advisor',
  waitForConnections: true,
  connectionLimit: 10
});

/* ---------- helpers ---------- */
const wrap = fn => (req, res) => fn(req, res).catch(e => { console.error(e); res.status(500).json({ error: 'Server error' }); });
const sign = uid => jwt.sign({ uid }, process.env.JWT_SECRET, { expiresIn: '7d' });
function auth(req, res, next) {
  const t = (req.headers.authorization || '').replace('Bearer ', '');
  try { req.uid = jwt.verify(t, process.env.JWT_SECRET).uid; next(); }
  catch { res.status(401).json({ error: 'Please log in again.' }); }
}

async function getProfile(uid) {
  const [[p]] = await db.query(
    'SELECT e.name AS education, p.field, p.career_goal AS goal FROM profiles p LEFT JOIN education_levels e ON e.edu_id = p.edu_id WHERE p.user_id = ?', [uid]);
  const [s] = await db.query('SELECT s.name FROM user_skills us JOIN skills s ON s.skill_id = us.skill_id WHERE us.user_id = ?', [uid]);
  const [i] = await db.query('SELECT i.name FROM user_interests ui JOIN interests i ON i.interest_id = ui.interest_id WHERE ui.user_id = ?', [uid]);
  return { ...p, skills: s.map(x => x.name), interests: i.map(x => x.name) };
}

async function loadCareers() {
  const [cs] = await db.query('SELECT career_id AS id, slug, title, icon, description FROM careers');
  const [sk] = await db.query('SELECT cs.career_id AS id, s.name FROM career_skills cs JOIN skills s ON s.skill_id = cs.skill_id');
  const [it] = await db.query('SELECT ci.career_id AS id, i.name FROM career_interests ci JOIN interests i ON i.interest_id = ci.interest_id');
  const [rm] = await db.query('SELECT career_id AS id, description FROM roadmap_steps ORDER BY career_id, step_no');
  const [rs] = await db.query('SELECT career_id AS id, name FROM resources');
  const m = {};
  cs.forEach(c => m[c.id] = { ...c, skills: [], interests: [], roadmap: [], resources: [] });
  sk.forEach(r => m[r.id].skills.push(r.name));
  it.forEach(r => m[r.id].interests.push(r.name));
  rm.forEach(r => m[r.id].roadmap.push(r.description));
  rs.forEach(r => m[r.id].resources.push(r.name));
  return m;
}

/* ---------- recommendation engine (same logic as the frontend) ---------- */
function scoreCareer(c, p) {
  const us = new Set(p.skills), ui = new Set(p.interests), goal = (p.goal || '').toLowerCase();
  const matched = c.skills.filter(s => us.has(s));
  const missing = c.skills.filter(s => !us.has(s));
  const hits = c.interests.filter(i => ui.has(i)).length;
  const words = c.title.toLowerCase().replace(/\//g, ' ').split(' ').filter(w => w.length > 3);
  const bonus = goal && words.some(w => goal.includes(w)) ? 0.1 : 0;
  const score = Math.round(Math.min(1, 0.6 * matched.length / c.skills.length + 0.4 * Math.min(1, hits / 2) + bonus) * 100);
  return { id: c.id, title: c.title, icon: c.icon, description: c.description, score, matched, missing, roadmap: c.roadmap, resources: c.resources };
}

async function latestRecs(uid) {
  const [[run]] = await db.query('SELECT MAX(run_id) AS id FROM recommendation_runs WHERE user_id = ?', [uid]);
  if (!run.id) return [];
  const [items] = await db.query('SELECT career_id, score FROM recommendation_items WHERE run_id = ? ORDER BY rank_no', [run.id]);
  const p = await getProfile(uid), careers = await loadCareers();
  return items.map(it => ({ ...scoreCareer(careers[it.career_id], p), score: it.score }));
}

function advisorAnswer(q, recs) {
  q = q.toLowerCase();
  if (!recs.length) return "Please complete your profile and tap 'Save & Get Recommendations' first, then I can advise you.";
  const t = recs[0], has = (...k) => k.some(x => q.includes(x));
  if (has('learn', 'skill', 'gap', 'improve', 'missing')) return `For ${t.title}, your next skills to learn are: ${t.missing.slice(0, 4).join(', ') || 'you already cover the core skills!'}. Good free places to start: ${t.resources.slice(0, 3).join(', ')}.`;
  if (has('roadmap', 'plan', 'steps', 'start', 'how')) return `Roadmap to become a ${t.title}:\n` + t.roadmap.slice(0, 5).map((s, i) => `${i + 1}. ${s}`).join('\n');
  if (has('best', 'career', 'suit', 'job', 'which')) return 'Your best matches are: ' + recs.slice(0, 3).map(r => `${r.title} (${r.score}%)`).join(', ') + '.';
  if (has('resource', 'course', 'where', 'free')) return `Recommended resources for ${t.title}: ${t.resources.join(', ')}.`;
  if (has('salary', 'pay', 'money')) return `Pay depends on your skills, portfolio and location. For ${t.title}, build 3 real projects and start with internships or freelancing.`;
  return `Your top match is ${t.title} (${t.score}%). Ask me about skills to learn, a roadmap, free courses or other careers.`;
}

/* ---------- AUTH ---------- */
app.post('/api/auth/register', wrap(async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email?.includes('@') || !password || password.length < 6)
    return res.status(400).json({ error: 'Name, valid email and 6+ character password required.' });
  const mail = email.trim().toLowerCase();
  const [[exists]] = await db.query('SELECT user_id FROM users WHERE email = ?', [mail]);
  if (exists) return res.status(409).json({ error: 'This email is already registered.' });
  const hash = await bcrypt.hash(password, 10);
  const [r] = await db.query('INSERT INTO users (full_name, email, password_hash) VALUES (?,?,?)', [name.trim(), mail, hash]);
  await db.query('INSERT INTO profiles (user_id) VALUES (?)', [r.insertId]);
  res.status(201).json({ token: sign(r.insertId), name: name.trim() });
}));

app.post('/api/auth/login', wrap(async (req, res) => {
  const { email, password } = req.body;
  const [[u]] = await db.query('SELECT user_id, full_name, password_hash FROM users WHERE email = ?', [(email || '').trim().toLowerCase()]);
  if (!u || !(await bcrypt.compare(password || '', u.password_hash)))
    return res.status(401).json({ error: 'Wrong email or password.' });
  res.json({ token: sign(u.user_id), name: u.full_name });
}));

/* ---------- LOOKUPS ---------- */
app.get('/api/meta', wrap(async (req, res) => {
  const [skills] = await db.query('SELECT name FROM skills ORDER BY skill_id');
  const [interests] = await db.query('SELECT name FROM interests ORDER BY interest_id');
  const [education] = await db.query('SELECT name FROM education_levels ORDER BY edu_id');
  res.json({ skills: skills.map(x => x.name), interests: interests.map(x => x.name), education: education.map(x => x.name) });
}));

/* ---------- PROFILE ---------- */
app.get('/api/profile', auth, wrap(async (req, res) => res.json(await getProfile(req.uid))));

app.put('/api/profile', auth, wrap(async (req, res) => {
  const { education, field, goal, skills = [], interests = [] } = req.body;
  const con = await db.getConnection();
  try {
    await con.beginTransaction();
    await con.query('UPDATE profiles SET edu_id = (SELECT edu_id FROM education_levels WHERE name = ?), field = ?, career_goal = ? WHERE user_id = ?',
      [education || null, field || null, goal || null, req.uid]);
    await con.query('DELETE FROM user_skills WHERE user_id = ?', [req.uid]);
    await con.query('DELETE FROM user_interests WHERE user_id = ?', [req.uid]);
    if (skills.length) await con.query('INSERT INTO user_skills (user_id, skill_id) SELECT ?, skill_id FROM skills WHERE name IN (?)', [req.uid, skills]);
    if (interests.length) await con.query('INSERT INTO user_interests (user_id, interest_id) SELECT ?, interest_id FROM interests WHERE name IN (?)', [req.uid, interests]);
    await con.commit();
  } catch (e) { await con.rollback(); throw e; } finally { con.release(); }
  res.json({ ok: true });
}));

/* ---------- RECOMMENDATIONS ---------- */
app.post('/api/recommendations', auth, wrap(async (req, res) => {
  const p = await getProfile(req.uid);
  if (!p.skills.length && !p.interests.length) return res.status(400).json({ error: 'Select at least one skill or interest first.' });
  const careers = await loadCareers();
  const recs = Object.values(careers).map(c => scoreCareer(c, p)).sort((a, b) => b.score - a.score).slice(0, 6);
  const con = await db.getConnection();
  try {
    await con.beginTransaction();
    const [run] = await con.query('INSERT INTO recommendation_runs (user_id) VALUES (?)', [req.uid]);
    await con.query('INSERT INTO recommendation_items (run_id, career_id, rank_no, score) VALUES ?',
      [recs.map((r, i) => [run.insertId, r.id, i + 1, r.score])]);
    await con.commit();
  } catch (e) { await con.rollback(); throw e; } finally { con.release(); }
  res.status(201).json(recs);
}));

app.get('/api/recommendations/latest', auth, wrap(async (req, res) => res.json(await latestRecs(req.uid))));

app.get('/api/history', auth, wrap(async (req, res) => {
  const [rows] = await db.query(
    `SELECT r.generated_at AS date, c.title AS top, ri.score
     FROM recommendation_runs r
     JOIN recommendation_items ri ON ri.run_id = r.run_id AND ri.rank_no = 1
     JOIN careers c ON c.career_id = ri.career_id
     WHERE r.user_id = ? ORDER BY r.generated_at DESC LIMIT 10`, [req.uid]);
  res.json(rows);
}));

/* ---------- ROADMAP + PROGRESS ---------- */
app.get('/api/roadmap', auth, wrap(async (req, res) => {
  const top = (await latestRecs(req.uid)).slice(0, 3);
  if (!top.length) return res.json([]);
  const [steps] = await db.query(
    `SELECT rs.step_id, rs.career_id, rs.description, (up.step_id IS NOT NULL) AS done
     FROM roadmap_steps rs
     LEFT JOIN user_progress up ON up.step_id = rs.step_id AND up.user_id = ?
     WHERE rs.career_id IN (?) ORDER BY rs.career_id, rs.step_no`, [req.uid, top.map(t => t.id)]);
  res.json(top.map(t => {
    const s = steps.filter(x => x.career_id === t.id).map(x => ({ ...x, done: !!x.done }));
    return { id: t.id, title: t.title, icon: t.icon, steps: s, percent: Math.round(100 * s.filter(x => x.done).length / s.length) };
  }));
}));

app.put('/api/progress/:stepId', auth, wrap(async (req, res) => {
  if (req.body.done) await db.query('INSERT IGNORE INTO user_progress (user_id, step_id) VALUES (?, ?)', [req.uid, req.params.stepId]);
  else await db.query('DELETE FROM user_progress WHERE user_id = ? AND step_id = ?', [req.uid, req.params.stepId]);
  res.json({ ok: true });
}));

/* ---------- CHAT ---------- */
app.get('/api/chat', auth, wrap(async (req, res) => {
  const [rows] = await db.query('SELECT role, content FROM chat_messages WHERE user_id = ? ORDER BY msg_id DESC LIMIT 100', [req.uid]);
  res.json(rows.reverse());
}));

app.post('/api/chat', auth, wrap(async (req, res) => {
  const text = (req.body.message || '').trim();
  if (!text) return res.status(400).json({ error: 'Message is empty.' });
  const reply = advisorAnswer(text, await latestRecs(req.uid));
  await db.query('INSERT INTO chat_messages (user_id, role, content) VALUES (?, "user", ?), (?, "assistant", ?)', [req.uid, text, req.uid, reply]);
  res.json({ reply });
}));

app.listen(process.env.PORT || 3000, () => console.log('API running on port ' + (process.env.PORT || 3000)));
