import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
test('demo service: files, embedding policy, upload limits and errors', async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'tx-web-server-'));
  fs.mkdirSync(path.join(dir, 'vue')); fs.writeFileSync(path.join(dir, 'vue/index.html'), '<h1>Vue</h1>');
  const child = spawn(process.execPath, ['_web/docker/server.mjs'], { env: { ...process.env, PORT: '18081', STATIC_ROOT: dir, PORTAL_ORIGINS: 'https://www.tekocloud.de' }, stdio: ['ignore', 'pipe', 'pipe'] });
  try {
    await Promise.race([once(child.stdout, 'data'), once(child, 'exit').then(() => { throw new Error('Server exited'); }), new Promise((_, reject) => setTimeout(() => reject(new Error('Server start timeout')), 10000).unref())]);
    const url = 'http://127.0.0.1:18081';
    assert.equal((await fetch(url + '/healthz')).status, 200);
    const response = await fetch(url + '/vue/');
    assert.equal(await response.text(), '<h1>Vue</h1>');
    assert.match(response.headers.get('content-security-policy'), /frame-ancestors 'self' https:\/\/www.tekocloud.de/);
    assert.equal(response.headers.get('x-frame-options'), null);
    assert.equal((await fetch(url + '/missing')).status, 404);
    const data = new FormData(); data.append('file', new Blob(['test']), 'demo.txt');
    const upload = await fetch(url + '/api/upload', { method: 'POST', body: data });
    assert.equal(upload.status, 200); assert.equal((await upload.json()).stored, false);
    assert.equal((await fetch(url + '/api/upload', { method: 'POST', body: 'bad' })).status, 415);
    const large = new FormData(); large.append('file', new Blob([new Uint8Array(2 * 1024 * 1024)]), 'big.txt');
    assert.equal((await fetch(url + '/api/upload', { method: 'POST', body: large })).status, 413);
  } finally { child.kill(); await once(child, 'exit'); fs.rmSync(dir, { recursive: true, force: true }); }
});
