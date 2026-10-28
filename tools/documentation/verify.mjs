// Extract real README examples into temporary consumer projects for compilation.
// Usage: node tools/documentation/verify.mjs <installed-npm-consumer-directory>
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';

const npmConsumer = process.argv.includes('--flutter-only') ? null : path.resolve(process.argv[2]);
const dartApi = JSON.parse(fs.readFileSync(path.join(os.tmpdir(), 'tecexpress-dart-api.json'), 'utf8'));
for (const file of fs.readdirSync('flutter/lib/src').filter(f => f.endsWith('.dart'))) {
  const name = `flutter/lib/src/${file}`;
  const baseline = spawnSync('git', ['show', `HEAD:${name}`], { encoding: 'utf8' });
  assert.equal(baseline.status, 0, name);
  const runtime = source => source.split(/\r?\n/).filter(line => !line.trimStart().startsWith('///') && line.trim()).join('\n');
  assert.equal(runtime(fs.readFileSync(name, 'utf8')), runtime(baseline.stdout), `Runtime changed: ${name}`);
}
console.log('Dart source changes contain documentation comments only.');
function blocks(readme, language) {
  return [...new Set([...readme.matchAll(new RegExp('```' + language + '\\r?\\n([\\s\\S]*?)\\r?\\n```', 'g'))].map(match => match[1]).filter(value => value.includes('import ')))];
}
function checkReadme(file) {
  const readme = fs.readFileSync(file, 'utf8');
  if (file === 'flutter/README.md') assert.ok(Buffer.byteLength(readme, 'utf8') <= 262144, 'Flutter README exceeds pub.dev maximum of 262144 bytes');
  assert.equal((readme.match(/^```/gm) ?? []).length % 2, 0, 'Unbalanced code fences');
  const anchors = [...readme.matchAll(/<a id="([^"]+)"><\/a>/g)].map(m => m[1]);
  assert.equal(new Set(anchors).size, anchors.length, 'Duplicate anchors');
  for (const [,target] of readme.matchAll(/\]\(#([^)]*)\)/g)) assert.ok(anchors.includes(target), `Broken anchor ${target}`);
  const german = anchors.filter(a => a.startsWith('de-')).map(a => a.slice(3));
  const english = anchors.filter(a => a.startsWith('en-')).map(a => a.slice(3));
  assert.deepEqual(german, english, 'Language coverage differs');
  for (const [,lang,body] of readme.matchAll(/```(\w+)\n([\s\S]*?)\n```/g)) {
    if (lang === 'vue') assert.ok(body.includes('<script setup') && body.includes('<template>'));
  }
  return readme;
}
const npmReadme = checkReadme('npm/README.md');
const dartReadme = checkReadme('flutter/README.md');
if (npmConsumer) assert.equal(fs.readFileSync(path.join(npmConsumer, 'node_modules/@tekocloud.de/tecexpress/README.md'), 'utf8'), npmReadme, 'Installed package README differs from source');
for (const api of dartApi) {
  for (const lang of ['de', 'en']) assert.ok(dartReadme.includes(`id="${lang}-${api.name.toLowerCase()}"`), api.name);
  assert.ok(api.documented, `Missing Dart API comment: ${api.name}`);
  for (const member of api.members) assert.ok(member.documented, `Missing Dart member comment: ${api.name}.${member.name}`);
}

const vue = blocks(npmReadme, 'vue');
const typescript = blocks(npmReadme, 'ts');
if (npmConsumer) {
const npmDir = path.join(npmConsumer, 'readme-examples');
fs.mkdirSync(npmDir, { recursive: true });
for (const [index, block] of vue.entries()) fs.writeFileSync(path.join(npmDir, `example-${index}.vue`), block);
for (const [index, block] of typescript.entries()) fs.writeFileSync(path.join(npmDir, `example-${index}.ts`), block);
fs.writeFileSync(path.join(npmDir, 'tsconfig.json'), JSON.stringify({ compilerOptions: { target: 'ES2022', module: 'ESNext', moduleResolution: 'Bundler', strict: true, skipLibCheck: true, lib: ['ES2022', 'DOM'], types: [] }, include: ['*.ts', '*.vue'] }, null, 2));
const result = spawnSync(process.execPath, [path.resolve('node_modules/vue-tsc/bin/vue-tsc.js'), '--noEmit', '-p', path.join(npmDir, 'tsconfig.json')], { encoding: 'utf8' });
console.log(`Vue/TypeScript: ${vue.length} SFCs, ${typescript.length} blocks checked against installed package.`);
if (result.status !== 0) { console.error(result.stdout, result.stderr); process.exitCode = 1; }
}

const flutterConsumer = fs.mkdtempSync(path.join(os.tmpdir(), 'tecexpress-docs-flutter-'));
fs.mkdirSync(path.join(flutterConsumer, 'lib'));
fs.mkdirSync(path.join(flutterConsumer, 'test'));
fs.writeFileSync(path.join(flutterConsumer, 'pubspec.yaml'), `name: documentation_consumer\npublish_to: none\nenvironment:\n  sdk: '>=3.13.5 <4.0.0'\ndependencies:\n  flutter:\n    sdk: flutter\n  tecexpress:\n    path: ${path.resolve('flutter').replaceAll('\\', '/')}\ndev_dependencies:\n  flutter_test:\n    sdk: flutter\n`);
// A few snippets intentionally demonstrate assigning state without reading it.
fs.writeFileSync(path.join(flutterConsumer, 'analysis_options.yaml'), 'analyzer:\n  errors:\n    unused_local_variable: ignore\n    unused_import: ignore\n');
const dart = blocks(dartReadme, 'dart');
for (const [index, block] of dart.entries()) fs.writeFileSync(path.join(flutterConsumer, 'lib', `example_${index}.dart`), block);
const smoke = ['TxButton(', 'TxTextBox(', 'TxDataGrid<', 'TxCard(', 'TxChat(', 'TxRangeSlider(', 'TxMap('];
const examples = smoke.map(name => dart.findIndex(block => block.includes('Widget example()') && block.includes(name)));
assert.ok(examples.every(i => i >= 0));
fs.writeFileSync(path.join(flutterConsumer, 'test', 'examples_test.dart'), `import 'package:flutter/material.dart';\nimport 'package:flutter_test/flutter_test.dart';\nimport 'package:tecexpress/tecexpress.dart';\n${examples.map((index,i) => `import '../lib/example_${index}.dart' as example${i};`).join('\n')}\nvoid main() {\n${examples.map((_,i) => `  testWidgets('${smoke[i]} README example', (tester) async {\n    tester.view.resetPhysicalSize();\n    tester.view.physicalSize = const Size(1600, 1800);\n    tester.view.devicePixelRatio = 1;\n    addTearDown(tester.view.resetPhysicalSize);\n    addTearDown(tester.view.resetDevicePixelRatio);\n    await tester.pumpWidget(MaterialApp(theme: TxTheme.light(), localizationsDelegates: TxLocalizations.delegates, supportedLocales: TxLocalizations.supportedLocales, home: Scaffold(body: SingleChildScrollView(child: example${i}.example()))));\n    await tester.pump();\n    expect(tester.takeException(), isNull);\n    await tester.pumpWidget(const SizedBox.shrink());\n  });`).join('\n')}\n}\n`);
console.log(`Dart: ${dart.length} complete example files prepared.`);
console.log(`Flutter consumer: ${flutterConsumer}`);
fs.writeFileSync(path.join(os.tmpdir(), 'tecexpress-documentation-consumers.json'), JSON.stringify({ npm: npmConsumer, flutter: flutterConsumer, vue: vue.length, typescript: typescript.length, dart: dart.length }));
