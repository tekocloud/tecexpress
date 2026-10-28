// Local-only browser HTTP fixtures; requires Node and a Chromium installation.
import http from 'node:http';
import { spawn } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const server = http.createServer((request, response) => {
  response.setHeader('Access-Control-Allow-Origin', '*');
  response.setHeader('Access-Control-Allow-Headers', '*');
  response.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  if (request.method === 'OPTIONS') { response.writeHead(204); response.end(); return; }
  const chunks = [];
  request.on('data', chunk => chunks.push(chunk));
  request.on('end', () => {
    if (request.url === '/hold') return;
    response.setHeader('Content-Type', 'application/json');
    response.end(JSON.stringify({ body: Buffer.concat(chunks).toString('utf8') }));
  });
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
const port = server.address().port;
try {
  const args = ['test', '--no-pub', '--platform', 'chrome',
    `--dart-define=TX_TEST_UPLOAD_URL=http://127.0.0.1:${port}`,
    ...process.argv.slice(2), 'test/file_web_test.dart'];
  const child = spawn('flutter', args, {
    cwd: path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..'),
    stdio: 'inherit', shell: process.platform === 'win32',
  });
  process.exitCode = await new Promise((resolve, reject) => {
    child.on('error', reject); child.on('exit', code => resolve(code ?? 1));
  });
} finally { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
