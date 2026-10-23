import { mkdtemp, writeFile, readFile } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join, resolve } from 'node:path'
import { spawnSync } from 'node:child_process'

const npmCli = process.env.npm_execpath
if (!npmCli) throw new Error('Bitte mit npm run test:package starten.')
const consumer = await mkdtemp(join(tmpdir(), 'tecexpress-consumer-'))
function npm(args, cwd) {
  const result = spawnSync(process.execPath, [npmCli, ...args], { cwd, encoding: 'utf8' })
  if (result.status !== 0) throw new Error(result.stderr || result.stdout || String(result.error))
  return result.stdout
}
npm(['run', 'build'], process.cwd())
const pack = JSON.parse(npm(['pack', '--ignore-scripts', '--json', '--pack-destination', consumer], process.cwd()))[0]
await writeFile(join(consumer, 'package.json'), JSON.stringify({ private: true, type: 'module' }))
npm(['install', '--ignore-scripts', '--no-audit', '--no-fund', join(consumer, pack.filename)], consumer)
const installed = JSON.parse(await readFile(join(consumer, 'node_modules/tecexpress/package.json'), 'utf8'))
if (installed.dependencies && Object.keys(installed.dependencies).length) throw new Error('Unerwartete Laufzeitabhängigkeiten')
const lock = await readFile(join(consumer, 'package-lock.json'), 'utf8')
if (/devextreme/i.test(lock)) throw new Error('DevExtreme im Consumer gefunden')
await writeFile(join(consumer, 'smoke.mjs'), `
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { createSSRApp, h } from 'vue'
import { renderToString } from '@vue/server-renderer'
import Tecexpress, * as library from 'tecexpress'
const expected = ['TxButton','TxTextBox','TxTextArea','TxNumberBox','TxCheckBox','TxSwitch','TxSelectBox','TxDateBox','TxTabs','TxToolbar','TxMenu','TxPopup','TxTooltip','TxToast','TxLoadIndicator','TxDataGrid','TxColumn','TxScheduler']
assert.deepEqual(Object.keys(library).filter(key => key.startsWith('Tx')).sort(), expected.sort())
const app = createSSRApp({ render: () => h(library.TxDataGrid, { dataSource: [{id: 1, name: 'Paketprobe'}] }) })
app.use(Tecexpress)
for (const name of expected) assert.ok(app.component(name))
assert.match(await renderToString(app), /Paketprobe/)
const scheduler = createSSRApp({ render: () => h(library.TxScheduler, { currentDate: '2026-10-23', dataSource: [{id: 1, text: 'Scheduler-Paketprobe', startDate: '2026-10-23T09:00', endDate: '2026-10-23T10:00'}] }) })
assert.match(await renderToString(scheduler), /Scheduler-Paketprobe/)
for (const name of ['light','dark','index']) assert.ok(readFileSync(new URL(import.meta.resolve('tecexpress/themes/' + name + '.css')), 'utf8').includes('@import'))
console.log('18 Exporte einschließlich Scheduler, globale Registrierung, SSR und alle Theme-Exporte erfolgreich geprüft.')
`)
const result = spawnSync(process.execPath, ['smoke.mjs'], { cwd: consumer, encoding: 'utf8' })
if (result.status !== 0) throw new Error(result.stderr || result.stdout)
console.log(result.stdout.trim())
console.log(`Installiertes Testprojekt: ${consumer}`)
console.log(`Installierbares Paket: ${resolve(consumer, pack.filename)}`)
