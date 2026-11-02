import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../../', import.meta.url));
process.chdir(root);
const write = (name, value) => { fs.mkdirSync(path.dirname(name), { recursive: true }); fs.writeFileSync(name, value); };
const catalog = { version: JSON.parse(fs.readFileSync('npm/package.json')).version, frameworks: {} };
const vue = {}, dart = {};
for (const [framework, folder] of [['vue', 'npm'], ['flutter', 'flutter']]) {
  const readme = fs.readFileSync(`${folder}/README.md`, 'utf8').replaceAll('\r\n', '\n');
  const languages = {};
  for (const lang of ['de', 'en']) {
    const pages = {};
    for (const match of readme.matchAll(new RegExp(`<a id="${lang}-([^"]+)"></a>\\s*### ([^\\n]+)\\n([\\s\\S]*?)(?=<a id=|$)`, 'g'))) {
      const [, id, title] = match;
      let body = match[3];
      if (id === 'txbutton') {
        body = body.replace('text="Save"', ':text="saved ? \'Saved ✓\' : \'Save\'"').replace("text: 'Save'", "text: saved ? 'Saved ✓' : 'Save'");
      }
      if (id === 'txfileuploader') {
        body = body.replace("Uri.parse('https://example.com/api/upload')", "Uri.base.resolve('/api/upload')").replace(/\/\/ Replace with your server's multipart endpoint\./g, '// Demo endpoint: consumes the request without storing files. Maximum 1 MiB.');
        if (framework === 'vue') body = body.replace('accept=".txt"', 'accept=".txt" :max-file-size="1048576"');
        else body = body.replace("extensions: const ['txt']", "extensions: const ['txt'], maxFileSize: 1048576");
        body = (lang === 'de' ? '**Demo:** Uploads werden nur entgegengenommen und sofort verworfen. Keine Speicherung.\n\n' : '**Demo:** Upload requests are consumed and immediately discarded. Nothing is stored.\n\n') + body;
      }
      if (id === 'txmap') {
        if (framework === 'vue') body = body.replace('<TxMap ', '<TxMap tile-url="/tiles/demo.png?z={z}&x={x}&y={y}" attribution="tecexpress · Synthetic demo tiles" ');
        else body = body.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/foundation.dart';").replace('return const TxMap(', "return TxMap(tileUrl: kIsWeb ? Uri.base.resolve('/tiles/demo.png?z={z}&x={x}&y={y}').toString().replaceAll('%7B', '{').replaceAll('%7D', '}') : null, attribution: 'tecexpress · Synthetic demo tiles', ");
        body = (lang === 'de' ? '**Demo:** Synthetische lokale Beispielkacheln, keine echten Geodaten.\n\n' : '**Demo:** Synthetic local example tiles, no real geographic data.\n\n') + body;
      }
      const examples = [...body.matchAll(/```(vue|dart|ts|sh|css)\n([\s\S]*?)\n```/g)].map(m => ({ language: m[1], code: m[2] }));
      const live = examples.find(e => framework === 'vue' ? e.language === 'vue' : /Widget example\(\)/.test(e.code));
      pages[id] = { id, title: title.trim(), body: body.trim(), demo: Boolean(live), summary: body.trim().split('\n\n')[0].replace(/[`*]/g, '') };
      if (live && lang === 'en') (framework === 'vue' ? vue : dart)[id] = live.code;
    }
    assert.ok(Object.keys(pages).length > 90, `${framework} ${lang}: incomplete reference`);
    languages[lang] = pages;
  }
  assert.deepEqual(Object.keys(languages.de), Object.keys(languages.en));
  catalog.frameworks[framework] = languages;
}
// Supplemental guides stay in the documentation instead of linking into a missing source tree.
for (const [framework, folder] of [['vue', 'npm'], ['flutter', 'flutter']]) {
  const pages = catalog.frameworks[framework];
  const referenced = new Set(Object.values(pages).flatMap(language => Object.values(language).flatMap(p => [...p.body.matchAll(/\]\(([^):#]+\.md)(?:#[^)]*)?\)/g)].map(m => m[1]))));
  for (const file of referenced) {
    const source = path.join(folder, file);
    if (!fs.existsSync(source)) continue;
    const id = `guide-${file.replace(/\.md$/, '').replaceAll('/', '-').toLowerCase()}`;
    for (const lang of ['de', 'en']) pages[lang][id] = { id, title: file.replace(/\.md$/, ''), body: fs.readFileSync(source, 'utf8').replaceAll('\r\n', '\n'), summary: file, demo: false };
  }
}
write('_web/content/catalog.json', JSON.stringify(catalog));
for (const [id, code] of Object.entries(vue)) write(`_web/demos/vue/generated/${id}.vue`, code);
write('_web/demos/vue/generated/registry.ts', Object.keys(vue).map(id => `import ${id} from './${id}.vue'`).join('\n') + `\nexport default {${Object.keys(vue).join(',')}}\n`);
for (const [id, code] of Object.entries(dart)) write(`_web/demos/flutter/lib/generated/${id}.dart`, code);
write('_web/demos/flutter/lib/generated/registry.dart', `import 'package:flutter/widgets.dart';\n${Object.keys(dart).map(id => `import '${id}.dart' as ${id};`).join('\n')}\nfinal Map<String, Widget Function()> examples = {${Object.keys(dart).map(id => `'${id}': ${id}.example`).join(',')}};\n`);
write('_web/demos/manifest.json', JSON.stringify({ vue: Object.keys(vue), flutter: Object.keys(dart) }, null, 2));
console.log(`Documentation: ${Object.keys(catalog.frameworks.vue.en).length} Vue pages, ${Object.keys(catalog.frameworks.flutter.en).length} Flutter pages, both languages. Live demos: ${Object.keys(vue).length} Vue, ${Object.keys(dart).length} Flutter.`);
