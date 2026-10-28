// Served at /api/health. Handler edits apply on the next request — no
// rebuild needed.
//
// `request` is a frozen plain object:
//   method  - 'GET' | 'POST' | ...
//   path    - '/api/health'
//   query   - URLSearchParams (request.query.get('name'))
//   headers - lowercased header map
//   body    - raw body text (null when empty); await request.json() parses it
//
// Secrets never belong in a .wizz file (that would ship them to the
// browser). Keep them in a gitignored .env.server at the project root and
// read them here through process.env. Call third-party APIs with the global
// fetch — the key stays server-side.
export default async function handler(request) {
  return {
    ok: true,
    method: request.method
  };
}
