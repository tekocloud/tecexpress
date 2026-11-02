import { chromium } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import http from 'node:http';
import https from 'node:https';
const portal = process.env.PORTAL_URL || 'http://127.0.0.1:8090';
const demos = process.env.DEMO_URL || 'http://127.0.0.1:8080';
const output = process.env.SCREENSHOT_DIR || path.join(process.env.TEMP || '/tmp', 'tecexpress-web-qa');
fs.mkdirSync(output, { recursive: true });
const catalog = JSON.parse(fs.readFileSync('_web/content/catalog.json'));
const read = url => new Promise((resolve, reject) => {
  (url.startsWith('https:') ? https : http).get(url, { agent: false }, response => { let body = ''; response.setEncoding('utf8'); response.on('data', chunk => body += chunk); response.on('end', () => resolve({ status: response.statusCode, body })); }).on('error', reject);
});
for (const [framework, languages] of Object.entries(catalog.frameworks)) for (const [lang, pages] of Object.entries(languages)) for (const id of Object.keys(pages)) {
  const response = await read(`${portal}/index.php?framework=${framework}&lang=${lang}&page=${id}`);
  assert.equal(response.status, 200, `${framework}/${lang}/${id}`);
  assert.doesNotMatch(response.body, /(?:Fatal error|Warning:|Deprecated:)/);
}
assert.equal((await read(`${portal}/index.php?page=missing`)).status, 404);
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1440, height: 1050 }, deviceScaleFactor: 1 });
const errors = [];
page.on('pageerror', error => errors.push(error.message));
try {
  await page.goto(portal);
  await page.evaluate(() => { localStorage.setItem('tx-docs-theme', 'light'); });
  await page.reload();
  await page.screenshot({ path: path.join(output, 'desktop.png'), fullPage: true });
  await page.locator('[data-search]').fill('DataGrid');
  assert.ok(await page.locator('[data-results] a').count() > 0);
  await page.locator('[data-results] a').first().click();
  assert.match(await page.locator('h1').textContent(), /TxDataGrid/);
  await page.locator('[data-load-demo]').last().click();
  await page.frameLocator('[data-demo-frame]').locator('.stage').waitFor();
  await page.screenshot({ path: path.join(output, 'datagrid.png'), fullPage: true });
  await page.locator('button[data-theme]').click();
  assert.equal(await page.locator('html').getAttribute('data-theme'), 'dark');
  await page.screenshot({ path: path.join(output, 'dark.png'), fullPage: true });
  await page.goto(portal + '/index.php?framework=flutter&lang=en&page=txbutton');
  assert.equal(await page.locator('html').getAttribute('lang'), 'en');
  await page.locator('[data-load-demo]').last().click();
  await page.frameLocator('[data-demo-frame]').locator('flt-glass-pane').waitFor({ state: 'attached', timeout: 45000 });
  await page.frameLocator('[data-demo-frame]').locator('canvas').first().waitFor({ timeout: 45000 });
  await page.screenshot({ path: path.join(output, 'flutter.png'), fullPage: true });
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto(portal);
  await page.locator('button[data-theme]').click();
  await page.locator('[data-menu]').click();
  assert.equal(await page.locator('[data-menu]').getAttribute('aria-expanded'), 'true');
  await page.locator('[data-menu]').click();
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, 'Mobile overflow');
  await page.screenshot({ path: path.join(output, 'mobile.png'), fullPage: true });
  const manifest = JSON.parse(fs.readFileSync('_web/demos/manifest.json'));
  await page.setViewportSize({ width: 1100, height: 800 });
  for (const id of manifest.vue) {
    await page.goto(`${demos}/vue/?component=${id}&lang=en&theme=light`);
    await page.locator('.stage').waitFor();
    assert.ok(await page.locator('.stage').evaluate(node => node.childElementCount > 0), id);
    await page.getByRole('button', { name: 'Reset demo' }).click();
  }
  await page.goto(`${demos}/vue/?component=txtextbox&lang=en`);
  await page.locator('input').first().fill('Verified live input');
  assert.equal(await page.locator('input').first().inputValue(), 'Verified live input');
  await page.goto(`${demos}/vue/?component=txcheckbox&lang=en`);
  const checkbox = page.getByRole('checkbox').first();
  const before = await checkbox.isChecked(); await checkbox.click();
  assert.notEqual(await checkbox.isChecked(), before);
  await page.goto(`${demos}/vue/?component=txbutton&lang=en`);
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await page.getByRole('button', { name: 'Saved ✓', exact: true }).waitFor();
  await page.getByRole('button', { name: 'Reset demo' }).click();
  await page.getByRole('button', { name: 'Save', exact: true }).waitFor();
  assert.deepEqual(errors, [], 'Browser runtime errors');
  console.log(`Browser checks passed: all PHP pages, search, routing, iframe embedding, language, themes, mobile, 38 Vue demos and Flutter Web canvas. Screenshots: ${output}`);
} finally { await browser.close(); }
