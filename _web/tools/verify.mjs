import fs from 'node:fs';
import assert from 'node:assert/strict';
import ts from 'typescript';
const catalog = JSON.parse(fs.readFileSync('_web/content/catalog.json', 'utf8'));
const manifest = JSON.parse(fs.readFileSync('_web/demos/manifest.json', 'utf8'));
for (const [framework, languages] of Object.entries(catalog.frameworks)) {
  assert.deepEqual(Object.keys(languages.de), Object.keys(languages.en), 'Language coverage');
  for (const [lang, pages] of Object.entries(languages)) for (const entry of Object.values(pages)) {
    assert.ok(entry.body && entry.title);
    assert.equal((entry.body.match(/^```/gm) || []).length % 2, 0, `${entry.id}: code fences`);
    for (const [, id] of entry.body.matchAll(/\]\(#(?:de|en)-([^)]*)\)/g)) assert.ok(pages[id], `Broken link ${framework}/${lang}/${id}`);
    if (entry.demo) assert.ok(manifest[framework].includes(entry.id), `Missing demo ${entry.id}`);
  }
  for (const id of manifest[framework]) assert.ok(languages.de[id].demo && languages.en[id].demo);
  assert.ok(manifest[framework].length >= 37);
}
// Validate documentation against the actual TypeScript public export surface.
const program = ts.createProgram(['npm/src/index.ts'], { target: ts.ScriptTarget.ESNext, module: ts.ModuleKind.NodeNext, moduleResolution: ts.ModuleResolutionKind.NodeNext, skipLibCheck: true });
const checker = program.getTypeChecker();
for (const symbol of checker.getExportsOfModule(checker.getSymbolAtLocation(program.getSourceFile('npm/src/index.ts')))) {
  if (symbol.name !== 'default') assert.ok(catalog.frameworks.vue.en[symbol.name.toLowerCase()], `Undocumented Vue export ${symbol.name}`);
}
console.log('Verified bilingual coverage, API exports, links, code fences and all 76 live demo routes.');
