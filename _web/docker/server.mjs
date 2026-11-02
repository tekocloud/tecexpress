import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = path.resolve(process.env.STATIC_ROOT || fileURLToPath(new URL('./public', import.meta.url)));
const port = Number(process.env.PORT || 8080);
const origins = (process.env.PORTAL_ORIGINS || 'https://www.tekocloud.de https://tekocloud.de').split(/\s+/).filter(Boolean);
if (origins.some(origin => !/^https?:\/\/[a-z0-9.\-]+(?::\d+)?$/i.test(origin))) throw new Error('PORTAL_ORIGINS must contain space-separated HTTP(S) origins without paths');
const mime = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.mjs': 'text/javascript; charset=utf-8', '.json': 'application/json', '.css': 'text/css', '.wasm': 'application/wasm', '.png': 'image/png', '.svg': 'image/svg+xml', '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.otf': 'font/otf', '.bin': 'application/octet-stream', '.frag': 'application/octet-stream' };
const server = http.createServer(async (req, res) => {
  res.setHeader('Content-Security-Policy', `frame-ancestors 'self' ${origins.join(' ')}; object-src 'none'; base-uri 'self'`);
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  const json = (code, value) => { res.writeHead(code, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }); res.end(JSON.stringify(value)); };
  let pathname;
  try { pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname); } catch { return json(400, { error: 'Invalid path' }); }
  if (pathname === '/healthz' && req.method === 'GET') return json(200, { status: 'ok' });
  if (pathname === '/api/upload') {
    if (req.method !== 'POST') return json(405, { error: 'Use POST' });
    if (!/^multipart\/form-data;.*boundary=/i.test(req.headers['content-type'] || '')) { req.resume(); return json(415, { error: 'Expected multipart/form-data' }); }
    const max = 1024 * 1024 + 65536;
    if (Number(req.headers['content-length']) > max) { req.resume(); return json(413, { error: 'Maximum demo upload: 1 MiB' }); }
    let received = 0;
    try {
      for await (const chunk of req) { received += chunk.length; if (received > max) { json(413, { error: 'Maximum demo upload: 1 MiB' }); req.destroy(); return; } }
      return json(200, { demo: true, receivedBytes: received, stored: false, message: 'Demo only. Request consumed and discarded; no file is stored.' });
    } catch { if (!res.headersSent) json(400, { error: 'Upload interrupted' }); return; }
  }
  if (!['GET', 'HEAD'].includes(req.method)) return json(405, { error: 'Method not allowed' });
  if (pathname === '/') { res.writeHead(302, { Location: '/vue/' }); return res.end(); }
  if (['/vue', '/flutter'].includes(pathname)) { res.writeHead(302, { Location: pathname + '/' }); return res.end(); }
  const file = path.resolve(root, '.' + pathname + (pathname.endsWith('/') ? 'index.html' : ''));
  if (!file.startsWith(root + path.sep)) return json(403, { error: 'Forbidden' });
  try {
    const stat = await fs.promises.stat(file);
    if (!stat.isFile()) return json(404, { error: 'Not found' });
    res.writeHead(200, { 'Content-Type': mime[path.extname(file)] || 'application/octet-stream', 'Content-Length': stat.size, 'Cache-Control': 'no-cache' });
    if (req.method === 'HEAD') return res.end();
    fs.createReadStream(file).on('error', () => res.destroy()).pipe(res);
  } catch { json(404, { error: 'Not found' }); }
});
server.requestTimeout = 30000;
server.headersTimeout = 10000;
server.listen(port, '0.0.0.0', () => console.log(`tecexpress demos: http://localhost:${port}`));
