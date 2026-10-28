import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import ts from 'typescript';
import { pathToFileURL } from 'node:url';
import { spawnSync } from 'node:child_process';
import { descriptions, fields, methods, vueExamples, vueState, dartExamples, dartState, vueNeeds, dartNeeds } from './content.mjs';
import { jsExamples, typeValues, dartApiExamples } from './examples.mjs';
import { notes, dartExtras } from './details.mjs';

const dartApi = JSON.parse(fs.readFileSync(process.argv.slice(2).find(arg => !arg.startsWith('--')) ?? path.join(os.tmpdir(), 'tecexpress-dart-api.json'), 'utf8'));
const library = await import(pathToFileURL(path.resolve('npm/dist/tecexpress.js')));
const program = ts.createProgram(['npm/src/index.ts'], { target: ts.ScriptTarget.ESNext, module: ts.ModuleKind.NodeNext, moduleResolution: ts.ModuleResolutionKind.NodeNext, strict: true, skipLibCheck: true });
const checker = program.getTypeChecker();
const entry = program.getSourceFile('npm/src/index.ts');
const symbols = checker.getExportsOfModule(checker.getSymbolAtLocation(entry)).filter(s => s.name !== 'default');
const flags = ts.TypeFormatFlags.NoTruncation | ts.TypeFormatFlags.UseAliasDefinedOutsideCurrentScope;
const flat = s => String(s).replace(/\s+/g, ' ').trim();
const cell = s => flat(s).replaceAll('|', '&#124;').replaceAll('\n', ' ');
const code = (s, lang = 'ts') => `\n\`\`\`${lang}\n${s.trim()}\n\`\`\`\n`;
const anchor = (lang, name) => `${lang}-${name.toLowerCase()}`;
const text = (pair, lang) => pair[lang === 'de' ? 0 : 1].split('`').map((part, i) => i % 2 ? part : part.replaceAll('<', '&lt;').replaceAll('>', '&gt;')).join('`');
const missing = new Set();
const eventDescriptions = {
  click: ['Klickereignis mit MouseEvent.', 'Click event carrying MouseEvent.'],
  selectionChanged: ['Neue Auswahl; Payload siehe Vertrag unten.', 'New selection; see the payload contract below.'],
  itemClick: ['Aktivierter Eintrag mit itemData; Menu liefert zusätzlich itemIndex/event, List zusätzlich itemIndex.', 'Activated entry as itemData; Menu also supplies itemIndex/event, List also supplies itemIndex.'],
  valueChanged: ['Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event.', 'New value in { value }; editors also include previousValue and event.'],
  itemDeleted: ['Gelöschter Listeneintrag in { itemData }.', 'Deleted list entry in { itemData }.'],
  itemReordered: ['Umordnung in { itemData, fromIndex, toIndex, items }; items enthält die neue Liste.', 'Reordering as { itemData, fromIndex, toIndex, items }; items contains the new list.'],
  customItemCreating: ['Eigener Text in { text }; eigenen Eintrag über die Anwendung ergänzen.', 'Custom text in { text }; add a custom entry through the application.'],
  showing: ['Vor Anzeige: { cancel }; synchron auf true setzen, um abzubrechen.', 'Before showing: { cancel }; set synchronously to true to cancel.'],
  hiding: ['Vor benutzerinitiiertem Schließen: { cancel }; synchron abbrechbar.', 'Before user-initiated closing: { cancel }; synchronously cancellable.'],
  shown: ['Nach Anzeige, ohne Payload.', 'After showing, without a payload.'],
  hidden: ['Nach Verbergen, ohne Payload.', 'After hiding, without a payload.'],
  uploaded: ['Upload erfolgreich: { file, result }.', 'Upload succeeded: { file, result }.'],
  uploadError: ['Upload fehlgeschlagen: { file, error }.', 'Upload failed: { file, error }.'],
  progress: ['Uploadfortschritt in Bytes: { file, loaded, total }.', 'Upload progress in bytes: { file, loaded, total }.'],
  error: ['Fehlerobjekt einer Dateioperation.', 'File operation error object.'],
  fileOpened: ['Aktivierter TxFileEntry.', 'Activated TxFileEntry.'],
  markerClick: ['Aktivierter TxMapMarker.', 'Activated TxMapMarker.'],
  tileError: ['Fehlgeschlagene Kachel in { x, y, zoom }.', 'Failed tile as { x, y, zoom }.'],
  rowClick: ['RowClickEvent: data, key, rowIndex, event.', 'RowClickEvent: data, key, rowIndex, event.'],
  cardClick: ['CardClickEvent: data, key, index, event.', 'CardClickEvent: data, key, index, event.'],
  sortChanged: ['Aktueller SortDescriptor oder null.', 'Current SortDescriptor or null.'],
  filterChanged: ['Aktuelle Textfilter als Record<string, string>.', 'Current text filters as Record<string, string>.'],
  searchChanged: ['Neuer Suchtext als string.', 'New search text as a string.'],
  cellClick: ['SchedulerCellClickEvent: startDate, endDate, allDay, event.', 'SchedulerCellClickEvent: startDate, endDate, allDay, event.'],
  appointmentClick: ['AppointmentClickEvent: appointmentData, event.', 'AppointmentClickEvent: appointmentData, event.'],
  appointmentAdding: ['AppointmentChangeEvent mit cancel vor Anlegen.', 'AppointmentChangeEvent with cancel before adding.'],
  appointmentDeleting: ['AppointmentChangeEvent mit cancel vor Löschen.', 'AppointmentChangeEvent with cancel before deleting.'],
  appointmentUpdating: ['AppointmentUpdatingEvent mit oldData, newData und cancel.', 'AppointmentUpdatingEvent with oldData, newData and cancel.'],
  appointmentAdded: ['AppointmentEvent nach lokalem Anlegen.', 'AppointmentEvent after local insertion.'],
  appointmentDeleted: ['AppointmentEvent nach lokalem Löschen.', 'AppointmentEvent after local deletion.'],
  appointmentUpdated: ['AppointmentUpdatedEvent mit oldData und newData.', 'AppointmentUpdatedEvent with oldData and newData.'],
  messageEntered: ['ChatMessageEnteredEvent; cancel synchron setzen, um eigene Serververarbeitung zu starten.', 'ChatMessageEnteredEvent; set cancel synchronously to start custom server processing.'],
  messageSent: ['ChatMessageEvent nach lokaler Aufnahme.', 'ChatMessageEvent after local acceptance.'],
  typingStart: ['ChatTypingEvent beim Beginn des Schreibens.', 'ChatTypingEvent when typing starts.'],
  typingEnd: ['ChatTypingEvent beim Ende des Schreibens.', 'ChatTypingEvent when typing ends.'],
};
const slots = {
  TxButton: { default: '()' }, TxToolbar: { default: '()', after: '()' }, TxTabs: { default: '{ selectedIndex, item }' }, TxTabPanel: { default: '{ selectedIndex, item }' },
  TxPopup: { default: '()', footer: '()' }, TxTooltip: { default: '()', content: '()' }, TxToast: { default: '()', actions: '()' }, TxCard: { default: '()', header: '()', media: '()', actions: '()', footer: '()' },
  TxDataGrid: { default: 'TxColumn[]', '[cellTemplate]': '{ data, value, column, rowIndex }' },
  TxScheduler: { appointment: '{ appointmentData, startDate, endDate, view }' },
  TxCardView: { item: '{ data, key, index, selected }', media: '{ data, key, index, selected }', content: '{ data, key, index, selected }', footer: '{ data, key, index, selected }', field: '{ data, column, value }' },
  TxChat: { header: '{ user }', empty: '()', message: '{ message, isOwn }' },
  TxRadioGroup: { item: '{ item, selected }' }, TxButtonGroup: { item: '{ item, selected }' }, TxLookup: { item: '{ item }' }, TxTagBox: { item: '{ item }' }, TxList: { item: '{ item, index, selected }' }, TxGallery: { item: '{ item, index }' }, TxActionSheet: { item: '{ item }' }, TxContextMenu: { default: '()' }, TxRangeSlider: { default: '{ value }' }, TxRangeSelector: { default: '{ value }' },
};
function describe(name, lang) {
  if (descriptions[name]) return text(descriptions[name], lang);
  const related = {
    EditorValue: ['Eingabewert eines Editors.', 'Editor input value.'], Item: ['Menü-/Reitereintrag.', 'Menu/tab entry.'], RowKey: descriptions.TxKey, DataRow: ['Frei strukturierter Datensatz mit benannten Feldern.', 'Flexible record with named fields.'], Column: descriptions.TxColumn, SortDescriptor: descriptions.TxSort,
    SchedulerView: descriptions.TxSchedulerView, SchedulerDate: ['Datum als Date oder parsebarer String; lokale ISO-Werte ohne Z kennzeichnen lokale Zeit.', 'Date or parseable string; local ISO values without Z denote local time.'], SchedulerEditing: descriptions.TxSchedulerEditing, Appointment: descriptions.TxAppointment, CardField: descriptions.TxCardField, ChatUser: descriptions.TxChatUser, ChatMessage: descriptions.TxChatMessage,
  };
  if (related[name]) return text(related[name], lang);
  if (name.endsWith('Event')) return text([`Typisierter Ereignisvertrag für ${name}; die Felder unten beschreiben den Payload.`, `Typed event contract for ${name}; fields below describe the payload.`], lang);
  missing.add(name); return name;
}
function fieldDescription(name, lang) {
  if (Object.hasOwn(fields, name)) return text(fields[name], lang);
  if (Object.hasOwn(methods, name)) return text(methods[name], lang);
  if (name.startsWith('can')) return text([`Ob der Store ${name.slice(3)} unterstützt.`, `Whether the store supports ${name.slice(3)}.`], lang);
  if (name.endsWith('Builder') || name === 'builder') return text(['Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.', 'Builds custom content; callback arguments and return type are given in the signature.'], lang);
  if (name.startsWith('on')) {
    const base = name.slice(2, 3).toLowerCase() + name.slice(3);
    if (base.endsWith('Changed')) {
      const prop = base.slice(0, -7);
      return text([`Meldet ${prop}; kontrollierten Zustand im Callback aktualisieren.`, `Reports ${prop}; update controlled state in the callback.`], lang);
    }
    if (eventDescriptions[base]) return text(eventDescriptions[base], lang);
    return text([`Callback für ${base}; Argumente und Rückgabetyp siehe Signatur.`, `Callback for ${base}; see the signature for arguments and return type.`], lang);
  }
  missing.add(`field:${name}`); return name;
}
function vueExample(name) {
  const template = vueExamples[name];
  const declarations = (vueNeeds[name] ?? []).map(key => [key, vueState[key]]);
  const imports = [name];
  if (name === 'TxDataGrid') imports.push('TxColumn');
  if (name === 'TxColumn') imports.push('TxDataGrid');
  if (template.includes('<TxButton')) imports.push('TxButton');
  if (declarations.some(([key]) => key === 'provider')) imports.push('TxMemoryFileProvider');
  if (declarations.some(([key]) => key === 'upload')) imports.push('txHttpUpload');
  if (name === 'TxScheduler') imports.push('type Appointment');
  if (name === 'TxChat') imports.push('type ChatMessage');
  return `<script setup lang="ts">\n${declarations.some(([,d]) => d.includes('ref(') || d.includes('ref<')) ? "import { ref } from 'vue'\n" : ''}import { ${[...new Set(imports)].join(', ')} } from '@tekocloud.de/tecexpress'\nimport '@tekocloud.de/tecexpress/themes/index.css'\n${declarations.map(([,value]) => value).join('\n')}\n</script>\n\n<template>\n${template.split('\n').map(line => `  ${line}`).join('\n')}\n</template>`;
}
function dartExample(name) {
  const expression = dartExamples[name];
  const declarations = (dartNeeds[name] ?? []).map(key => [key, dartState[key]]);
  const header = "import 'package:flutter/material.dart';\nimport 'package:tecexpress/tecexpress.dart';\n\n";
  if (!expression.includes('setState')) return `${header}Widget example() {\n${declarations.map(([,value]) => value.split('\n').map(line => `  ${line}`).join('\n')).join('\n')}\n  return ${expression};\n}`;
  return `${header}Widget example() {\n${declarations.map(([,value]) => value.split('\n').map(line => `  ${line}`).join('\n')).join('\n')}\n  return StatefulBuilder(\n    builder: (context, setState) => ${expression},\n  );\n}`;
}
function jsApiExample(name, generic) {
  let example = jsExamples[name];
  if (example) {
    if (!example.includes("from '@tekocloud.de/tecexpress'")) example = `import { ${name} } from '@tekocloud.de/tecexpress'\n${example}`;
    return example;
  }
  if (!(name in typeValues)) throw Error(`Missing TypeScript example: ${name}`);
  return `import type { ${name} } from '@tekocloud.de/tecexpress'\nconst example: ${name}${generic ? name === 'ValueChangedEvent' ? '<string>' : '<{ id: number }>' : ''} = ${typeValues[name]}\nconsole.log(example)`;
}
function dartApiExample(name, kind) {
  if (dartApiExamples[name]) return dartApiExamples[name];
  if (kind === 'enum') return `print(${name}.values);`;
  if (name === 'TxSourceState') return `class BoundLabel extends StatefulWidget {\n  const BoundLabel({super.key, required this.source});\n  final Object source;\n  @override\n  State<BoundLabel> createState() => _BoundLabelState();\n}\n\nclass _BoundLabelState extends State<BoundLabel>\n    with TxSourceState<BoundLabel, String> {\n  @override\n  Object get sourceInput => widget.source;\n  @override\n  Widget build(BuildContext context) => Text(sourceItems.join(', '));\n}`;
  throw Error(`Missing Dart example: ${name}`);
}
const table = (headers, rows) => `\n| ${headers.join(' | ')} |\n| ${headers.map(() => '---').join(' | ')} |\n${rows.map(row => `| ${row.map(cell).join(' | ')} |`).join('\n')}\n`;
const label = (lang, de, en) => lang === 'de' ? de : en;
function npmEvent(name, event, lang) {
  if (event.startsWith('update:')) return label(lang, `Neuer Wert von ${event.slice(7)}; über v-model:${event.slice(7)} übernehmen (modelValue: v-model).`, `New ${event.slice(7)} value; accept using v-model:${event.slice(7)} (modelValue: v-model).`);
  if (event === 'selectionChanged') {
    const payload = name === 'TxDataGrid' ? '{ selectedRowKeys, selectedRowsData }' : name === 'TxCardView' ? '{ selectedCardKeys, selectedCardsData }' : name === 'TxTabs' || name === 'TxTabPanel' ? '{ selectedIndex, itemData }' : name === 'TxFileManager' ? 'TxFileEntry[]' : '{ value, itemData }';
    return label(lang, `Neue Auswahl: ${payload}.`, `New selection: ${payload}.`);
  }
  if (event === 'itemClick') return name === 'TxMenu' ? '{ itemData, itemIndex, event }' : name === 'TxList' ? '{ itemData, itemIndex }' : '{ itemData }';
  const description = eventDescriptions[event];
  if (!description) throw Error(`Missing event description: ${name}.${event}`);
  return text(description, lang);
}

function npmSections(lang) {
  let out = '';
  for (const symbol of symbols) {
    const name = symbol.name;
    const target = symbol.flags & ts.SymbolFlags.Alias ? checker.getAliasedSymbol(symbol) : symbol;
    const decl = target.declarations?.[0];
    if (!decl) throw Error(`No declaration for ${name}`);
    const runtime = library[name];
    out += `\n<a id="${anchor(lang, name)}"></a>\n### ${name}\n\n${describe(name, lang)}\n`;
    if (notes[name]) out += '\n' + text(notes[name], lang) + '\n';
    if (vueExamples[name]) {
      const type = checker.getTypeOfSymbolAtLocation(target, decl);
      const instance = type.getConstructSignatures()[0]?.getReturnType();
      const propSymbol = instance?.getProperty('$props');
      const propsType = propSymbol && checker.getTypeOfSymbolAtLocation(propSymbol, decl);
      out += table(['Prop', label(lang, 'Typ', 'Type'), label(lang, 'Standard', 'Default'), label(lang, 'Bedeutung', 'Meaning')], Object.entries(runtime.props ?? {}).map(([key, value]) => {
        const prop = propsType?.getProperty(key);
        const typeText = prop ? checker.typeToString(checker.getTypeOfSymbolAtLocation(prop, decl), decl, flags) : 'unknown';
        const obj = value && typeof value === 'object' && !Array.isArray(value) ? value : { type: value };
        const fallback = 'default' in obj ? typeof obj.default === 'function' && obj.type !== Function ? JSON.stringify(obj.default()) : String(obj.default) : obj.required ? label(lang, 'erforderlich', 'required') : obj.type === Boolean || Array.isArray(obj.type) && obj.type.includes(Boolean) ? 'false' : 'undefined';
        return [`\`${key}\``, `\`${typeText}\``, `\`${fallback}\``, fieldDescription(key, lang)];
      }));
      const emits = Array.isArray(runtime.emits) ? runtime.emits : Object.keys(runtime.emits ?? {});
      if (emits.length) out += `\n**${label(lang, 'Ereignisse', 'Events')}**\n` + table(['Event', 'Payload / ' + label(lang, 'Verhalten', 'behavior')], emits.map(event => [event, npmEvent(name, event, lang)]));
      if (slots[name]) out += `\n**Slots**\n` + table(['Slot', label(lang, 'Argumente', 'Arguments')], Object.entries(slots[name]));
      if (name === 'TxFileUploader') out += label(lang, '\nÜber eine Template-Ref erreichbar: `upload(): Promise<void[]>` startet alle bereiten Warteschlangeneinträge parallel; `cancel(): void` bricht alle laufenden Einträge ab. Beispiel: `await uploader.value?.upload()` beziehungsweise `uploader.value?.cancel()`. Die Ref wird mit `const uploader = ref<{ upload(): Promise<void[]>; cancel(): void } | null>(null)` angelegt und mit `ref="uploader"` gebunden.\n', '\nAvailable through a template ref: `upload(): Promise<void[]>` starts all ready queued entries in parallel; `cancel(): void` cancels all active entries. Example: `await uploader.value?.upload()` or `uploader.value?.cancel()`. Declare `const uploader = ref<{ upload(): Promise<void[]>; cancel(): void } | null>(null)` and bind `ref="uploader"`.\n');
      out += code(vueExample(name), 'vue');
      continue;
    }
    if (ts.isClassDeclaration(decl)) {
      const type = checker.getTypeOfSymbolAtLocation(target, decl);
      const instance = type.getConstructSignatures()[0]?.getReturnType();
      const constructors = type.getConstructSignatures();
      out += code(constructors.map(sig => `new ${name}${checker.signatureToString(sig, decl, flags)}`).join('\n'));
      if (instance) out += table([label(lang, 'Mitglied', 'Member'), label(lang, 'Typ / Rückgabe', 'Type / return'), label(lang, 'Verhalten', 'Behavior')], instance.getProperties().filter(prop => !prop.declarations?.some(d => d.modifiers?.some(m => m.kind === ts.SyntaxKind.PrivateKeyword || m.kind === ts.SyntaxKind.ProtectedKeyword))).map(prop => [prop.name, `\`${checker.typeToString(checker.getTypeOfSymbolAtLocation(prop, decl), decl, flags)}\``, fieldDescription(prop.name, lang)]));
    } else if (ts.isFunctionDeclaration(decl)) {
      out += code(`function ${name}${checker.signatureToString(checker.getSignatureFromDeclaration(decl), decl, flags)}`);
    } else if (ts.isInterfaceDeclaration(decl) || ts.isTypeAliasDeclaration(decl)) {
      out += code(decl.getText().replace(/^export /, ''));
      if (ts.isInterfaceDeclaration(decl)) {
        const type = checker.getDeclaredTypeOfSymbol(target);
        out += table([label(lang, 'Feld', 'Field'), label(lang, 'Bedeutung', 'Meaning')], type.getProperties().map(prop => [prop.name, fieldDescription(prop.name, lang)]));
      }
    }
    out += code(jsApiExample(name, !!decl.typeParameters?.length));
  }
  return out;
}

function dartSections(lang) {
  let out = '';
  for (const api of dartApi) {
    out += `\n<a id="${anchor(lang, api.name)}"></a>\n### ${api.name}\n\n${describe(api.name, lang)}\n`;
    if (notes[api.name]) out += '\n' + text(notes[api.name], lang) + '\n';
    if (api.kind === 'enum' || api.kind === 'typedef' || api.kind === 'function') out += code(api.signature, 'dart');
    const ctors = api.members.filter(m => m.kind === 'constructor');
    const members = api.members.filter(m => m.kind !== 'constructor');
    if (ctors.length) {
      for (const ctor of ctors) {
        if (!ctor.parameters?.length) continue;
        out += `\n\`${ctor.name}\`\n` + table([label(lang, 'Parameter', 'Parameter'), label(lang, 'Typ', 'Type'), label(lang, 'Standard', 'Default'), label(lang, 'Bedeutung', 'Meaning')], ctor.parameters.filter(p => !(p.name === 'key' && p.type === 'Key?')).map(p => [p.name, `\`${p.type || 'siehe Felder / see fields'}\``, `\`${p.required ? label(lang, 'erforderlich', 'required') : p.default ?? 'null'}\``, fieldDescription(p.name, lang)]));
      }
    }
    // Constructor parameter tables already document field types, defaults and
    // meaning. Keep methods and additional fields without repeating those rows.
    const parameterNames = new Set(ctors.flatMap(ctor => ctor.parameters?.map(p => p.name) ?? []));
    const additionalMembers = members.filter(member => member.kind !== 'field' || !parameterNames.has(member.name));
    if (additionalMembers.length) out += table([label(lang, 'Mitglied / Typ / Rückgabe', 'Member / type / return'), label(lang, 'Bedeutung', 'Meaning')], additionalMembers.map(member => [`\`${member.signature}\``, fieldDescription(member.name, lang)]));
    if (dartExamples[api.name]) out += code(dartExample(api.name), 'dart');
    else {
      const example = dartApiExample(api.name, api.kind);
      const imports = `${example.includes('Uint8List') ? "import 'dart:typed_data';\n" : ''}${/\b(debugPrint|Colors|Icons|MaterialApp|BuildContext|Widget|State|StatefulWidget)\b/.test(example) ? "import 'package:flutter/material.dart';\n" : ''}import 'package:tecexpress/tecexpress.dart';`;
      out += code(`${imports}\n\n${api.name === 'TxSourceState' ? example : `Future<void> example() async {\n${example.split('\n').map(line => '  ' + line).join('\n')}\n}`}`, 'dart');
    }
    if (dartExtras[api.name]) out += code(`import 'package:flutter/material.dart';\nimport 'package:tecexpress/tecexpress.dart';\n\n${dartExtras[api.name]}`, 'dart');
  }
  return out;
}

function intro(platform, lang) {
  const isVue = platform === 'npm';
  const version = isVue ? JSON.parse(fs.readFileSync('npm/package.json', 'utf8')).version : fs.readFileSync('flutter/pubspec.yaml', 'utf8').match(/^version:\s*(\S+)/m)[1];
  const id = lang;
  let out = `\n<a id="${id}"></a>\n## ${lang === 'de' ? 'Deutsch' : 'English'}\n\n`;
  out += label(lang, `Vollständige öffentliche API von tecexpress ${version} für ${isVue ? 'Vue 3' : 'Flutter'}. MIT-Lizenz, ohne Lizenzkey.`, `Complete public API for tecexpress ${version} for ${isVue ? 'Vue 3' : 'Flutter'}. MIT licensed, no license key.`);
  out += `\n\n[${label(lang, 'Installation und Einstieg', 'Installation and getting started')}](#${id}-start) · [${label(lang, 'Daten und Zustandsverwaltung', 'Data and state')}](#${id}-data) · [${label(lang, 'Dateien, Uploads und Karten', 'Files, uploads and maps')}](#${id}-adapters) · [${label(lang, 'API-Verzeichnis', 'API index')}](#${id}-api) · [${label(lang, 'Entwicklung', 'Development')}](#${id}-development)\n`;
  out += `\n<a id="${id}-start"></a>\n### ${label(lang, 'Installation und Einstieg', 'Installation and getting started')}\n`;
  if (isVue) {
    out += code('npm install @tekocloud.de/tecexpress vue@^3.5.0', 'sh');
    out += label(lang, '\nAlle folgenden Vue-Beispiele sind vollständige Single-File-Components. Als App.vue speichern und in einer Vue-3-Anwendung mit TypeScript ausführen. Für lokale Entwicklung Node.js 24.15+ innerhalb 24.x verwenden.\n', '\nAll Vue examples below are complete single-file components. Save as App.vue in a Vue 3 application with TypeScript. For local development use Node.js 24.15+ within 24.x.\n');
    out += code(vueExample('TxTextBox'), 'vue');
    out += label(lang, '\nEinzelimporte sind möglich; alternativ registriert `app.use(Tecexpress)` alle Komponenten. Props in camelCase können in Templates als kebab-case geschrieben werden.\n', '\nImport components individually or register all of them with `app.use(Tecexpress)`. camelCase props can be written as kebab-case in templates.\n');
    out += `\n**Themes**\n` + code("import '@tekocloud.de/tecexpress/themes/index.css'\ndocument.documentElement.dataset.txTheme = 'dark' // 'light'\n// Fixed theme: import only themes/light.css or themes/dark.css instead.");
    out += label(lang, '\nOhne data-tx-theme gilt Light. Das Attribut funktioniert auch auf einem Container und bleibt für Overlays erhalten. Nach dem CSS-Import können Tokens am Container überschrieben werden.\n', '\nWithout data-tx-theme, light is used. The attribute also works on a container and is retained for overlays. Override tokens on the container after importing CSS.\n');
    const baseCss = fs.readdirSync('npm/themes').filter(f => f.endsWith('.css')).map(f => fs.readFileSync(`npm/themes/${f}`, 'utf8')).join('\n');
    const tokens = [...new Set([...baseCss.matchAll(/(--tx-[\w-]+)\s*:/g)].map(m => m[1]))];
    out += code('.my-app { --tx-accent: #6636c6; --tx-radius: 10px; --tx-control-height: 44px; }', 'css');
    out += label(lang, '\nVerfügbare Tokens: ', '\nAvailable tokens: ') + tokens.map(t => `\`${t}\``).join(', ') + '.\n';
  } else {
    out += code('flutter pub add tecexpress', 'sh');
    out += label(lang, '\nAb 0.7.0 nur Flutter-SDK-Laufzeitabhängigkeiten. Eigene Datei-API: `TxFile` und `TxFileDialogs`. Breaking Changes, Ressourcenbesitz und Plattformkonfiguration: [Migration 0.7](MIGRATION-0.7.md). Native Apps nach dem Update vollständig neu bauen.\n', '\nSince 0.7.0 only Flutter SDK runtime dependencies. Built-in file API: `TxFile` and `TxFileDialogs`. See [migration 0.7](MIGRATION-0.7.md) for breaking changes, ownership and platform setup. Fully rebuild native apps after upgrading.\n');
    out += label(lang, '\nBenötigt Flutter 3.47.7+ und Dart 3.13.5+. Zielplattformen: Android, iOS, Web, Windows, macOS und Linux.\n', '\nRequires Flutter 3.47.7+ and Dart 3.13.5+. Targets Android, iOS, web, Windows, macOS and Linux.\n');
    out += code("import 'package:flutter/material.dart';\nimport 'package:tecexpress/tecexpress.dart';\n\nvoid main() => runApp(MaterialApp(\n  theme: TxTheme.light(),\n  darkTheme: TxTheme.dark(),\n  themeMode: ThemeMode.system,\n  locale: const Locale('de'),\n  localizationsDelegates: TxLocalizations.delegates,\n  supportedLocales: TxLocalizations.supportedLocales,\n  home: Scaffold(body: Center(child: TxButton(text: 'Hello', onPressed: () {}))),\n));", 'dart');
    out += label(lang, '\nWidgetbeispiele definieren jeweils `Widget example()`. Zum Ausprobieren innerhalb einer MaterialApp `Scaffold(body: example())` verwenden. Alle Widgets akzeptieren zusätzlich den optionalen Flutter-Parameter `Key? key = null`; dieser steht hier einmal gemeinsam statt in jeder Tabelle. Der lokale Zustand entsteht einmal beim Erzeugen des Widgets; in einer produktiven App gehört er in den eigenen State. Beispiele für Datenoperationen definieren eine asynchrone Funktion, die separat aufgerufen wird.\n', '\nWidget examples each define `Widget example()`. Try them inside a MaterialApp using `Scaffold(body: example())`. All widgets also accept the optional Flutter parameter `Key? key = null`; it is documented once here instead of in every table. Local state is created once when constructing the widget; in a production app keep it in your own State. Data operation examples define an async function to call separately.\n');
    out += label(lang, '\nEigene Tokens: `TxTheme.light(tokens: TxThemeData.light.copyWith(accent: Colors.indigo, radius: 12))`. `txThemeOf(context)` liest aktuelle Tokens. Lokalisierungsdelegates aktivieren deutsche/englische Material-Steuerelemente; paketinterne Bedientexte sind derzeit deutsch.\n', '\nCustom tokens: `TxTheme.light(tokens: TxThemeData.light.copyWith(accent: Colors.indigo, radius: 12))`. `txThemeOf(context)` reads current tokens. Localization delegates enable German/English Material controls; package-specific UI labels are currently German.\n');
  }
  out += `\n<a id="${id}-data"></a>\n### ${label(lang, 'Daten und Zustandsverwaltung', 'Data and state')}\n\n`;
  out += label(lang,
    `Eine Datenbindung akzeptiert ${isVue ? 'Arrays' : 'List&lt;T&gt;'}, Konfigurationen oder bestehende DataSource-Instanzen. Bei einer Konfiguration besitzt und entsorgt die Komponente ihre Source; eine übergebene Instanz bleibt Aufgabe der Anwendung. dataSource hat Vorrang vor items. Geteilte Instanzen teilen auch Filter, Suche, Sortierung und Seite. Für unabhängige Ansichten eigene Instanzen verwenden.\n\n${isVue ? 'Kontrollierte Werte mit v-model beziehungsweise update-Ereignissen übernehmen. Ohne Wertbindung verwalten unterstützte Komponenten ihren Zustand intern.' : 'Kontrollierte Werte und Listen über on…Changed in den eigenen State übernehmen. Externe TextEditingController entsorgt die Anwendung; interne Controller entsorgt das Widget.'}\n\nArrayStores verarbeiten Abfragen lokal; CustomStores standardmäßig auf dem Server. Bei remoteOperations = false müssen CustomStores sämtliche Rohdaten liefern. Der Serververtrag wird von der Anwendung bestimmt; Getter sind nicht serialisierbar. Für serverseitiges Paging totalCount liefern. Kalender und Chat benötigen vollständige Verläufe oder eine bewusst begrenzte Datenmenge; paginate = false lädt alles.\n\nload/reload/configure können fehlschlagen: await mit try/catch verwenden und error anzeigen. Neue Ladevorgänge ersetzen alte; verspätete Antworten überschreiben keinen neueren Zustand. Schlüssel bleiben eindeutig und unveränderlich. Schreiben ohne passende Store-Operation schlägt fehl. push ist keine Transaktion.\n\nTerminenden liegen nach dem Beginn. Ganztagstermine verwenden lokale Tagesgrenzen mit exklusivem Ende. UTC-Zeitpunkte werden lokal dargestellt. Chat zeigt Text, kein HTML; Backend und KI-Dienst richtet die Anwendung ein.`,
    `Data binding accepts ${isVue ? 'arrays' : 'List&lt;T&gt;'}, configurations or existing DataSource instances. A component owns and disposes sources created from configurations; the application owns borrowed instances. dataSource takes precedence over items. Shared instances also share filters, search, sort and page state. Use separate instances for independent views.\n\n${isVue ? 'Accept controlled values using v-model or update events. Without a value binding, supported components manage state internally.' : 'Accept controlled values and lists into application State through on…Changed. The application disposes external TextEditingControllers; widgets dispose internal controllers.'}\n\nArrayStores process queries locally; custom stores process them remotely by default. With remoteOperations = false, custom stores must return all raw data. The application defines the server protocol; getters are not serializable. Supply totalCount for server paging. Calendar and chat need full histories or an intentionally limited dataset; paginate = false loads everything.\n\nload/reload/configure can fail: await with try/catch and display error. New loads replace old loads; late responses cannot overwrite newer state. Keys remain unique and immutable. Writes without the required store operation fail. push is not a transaction.\n\nAppointment ends follow their starts. All-day appointments use local day boundaries with an exclusive end. UTC instants display in local time. Chat displays plain text, not HTML; the application supplies backend and AI services.`) + '\n';
  out += code(isVue ? "import { TxDataSource } from '@tekocloud.de/tecexpress'\nconst source = new TxDataSource({ store: [{ id: 1, text: 'One' }], paginate: false })\ntry { await source.load() } catch (error) { console.error(error) }\nsource.dispose()" : "import 'package:tecexpress/tecexpress.dart';\n\nFuture<void> example() async {\n  final source = TxDataSource.array([1, 2], keyOf: (v) => v);\n  try { await source.load(); } catch (error) { print(error); }\n  source.dispose();\n}", isVue ? 'ts' : 'dart');
  out += `\n<a id="${id}-adapters"></a>\n### ${label(lang, 'Dateien, Uploads und Karten', 'Files, uploads and maps')}\n\n`;
  out += label(lang,
    `Der MemoryFileProvider speichert nur im Arbeitsspeicher. Ungültige Namen, doppelte IDs/Namen, ungültige Eltern und zyklische Verschiebungen werden abgelehnt. Dateioperationen sind asynchron. ${isVue ? 'Optionale Provider-Methoden bestimmen sichtbare Aktionen; txFileStore unterstützt Laden, Löschen und Umbenennen, sofern angeboten.' : 'Die capabilities-Menge bestimmt sichtbare Aktionen. txFileStore unterstützt Laden und optional Löschen; Umbenennen wird nicht als Store-Update angeboten.'}\n\nHTTP-Uploads benötigen einen eigenen Multipart-POST-Endpunkt. fieldName ist standardmäßig file. Bei chunkSize muss der Server das durch chunkFields vereinbarte Protokoll zusammensetzen. Wiederholung beginnt von vorn. ${isVue ? 'XHR meldet Fortschritt während der Übertragung; withCredentials ist standardmäßig false.' : 'Der HTTP-Adapter liest die Datei in den Speicher und meldet Fortschritt nach abgeschlossenen Chunks. Dateiauswahl/Drop und Speicherdialoge hängen von OS und Plugins ab; onDownload ermöglicht eigene Speicherung.'}\n\nKartenkacheln verwenden {z}/{x}/{y}. Kachelquelle, Zugangsdaten und Attribution müssen selbst konfiguriert werden. GeoAdapter wird von der Anwendung aufgerufen; seine Ergebnisse werden als Marker/Routen gebunden. Ohne Quelle erfolgt kein impliziter externer Kartenaufruf.`,
    `MemoryFileProvider stores only in memory. Invalid names, duplicate IDs/names, invalid parents and cyclic moves are rejected. File operations are asynchronous. ${isVue ? 'Optional provider methods determine visible actions; txFileStore supports loading, removal and renaming when offered.' : 'The capabilities set determines visible actions. txFileStore supports loading and optional removal; renaming is not offered as a store update.'}\n\nHTTP uploads require your own multipart POST endpoint. fieldName defaults to file. With chunkSize, the server must assemble the protocol agreed through chunkFields. Retrying starts from the beginning. ${isVue ? 'XHR reports progress during transmission; withCredentials defaults to false.' : 'The HTTP adapter reads the file into memory and reports progress after completed chunks. File pickers/drop and save dialogs depend on OS and plugins; onDownload enables custom saving.'}\n\nMap tiles use {z}/{x}/{y}. Configure tile sources, credentials and attribution yourself. The application calls GeoAdapter and binds its results as markers/routes. Without a source, no implicit external map request is made.`) + '\n';
  out += `\n<a id="${id}-api"></a>\n### ${label(lang, 'API-Verzeichnis', 'API index')}\n\n`;
  const names = isVue ? symbols.map(s => s.name) : dartApi.map(a => a.name);
  out += names.map(name => `- [${name}](#${anchor(lang, name)})`).join('\n') + '\n';
  out += label(lang, '\n`undefined` (Vue) beziehungsweise optionale nullable Parameter (Dart) bedeuten keinen extern vorgegebenen Wert. Boolean-Props ohne expliziten Vue-Standard sind false. Typen und Standardwerte unten stammen aus der aktuellen Implementierung; zusätzliche Fähigkeiten werden dadurch nicht zugesagt.\n', '\n`undefined` (Vue) or optional nullable parameters (Dart) mean no externally supplied value. Boolean Vue props without an explicit default are false. Types and defaults below come from the current implementation; they do not promise additional capabilities.\n');
  return out;
}

function development(platform, lang) {
  const isVue = platform === 'npm';
  let out = `\n<a id="${lang}-development"></a>\n### ${label(lang, 'Entwicklung und weiterführende Dokumentation', 'Development and further documentation')}\n`;
  out += code(isVue ? 'npm install\nnpm run typecheck\nnpm test\nnpm run test:package\nnpm pack --dry-run' : 'flutter pub get\nflutter analyze\nflutter test\ndart doc\nflutter pub publish --dry-run', 'sh');
  out += label(lang, '\nDie Befehle im jeweiligen Paketordner ausführen. Ein Dry-run veröffentlicht nichts.\n\n', '\nRun commands from the respective package directory. A dry run does not publish anything.\n\n');
  const base = 'https://github.com/tekocloud/tecexpress/blob/main/';
  out += `[${label(lang, 'Veröffentlichungsanleitung', 'Publishing guide')}](${base}PUBLISHING.md) · [${label(lang, 'Showcase', 'Showcase')}](${base}${isVue ? 'npm/demo/App.vue' : 'flutter/example/lib/showcase.dart'}) · [${label(lang, 'Änderungen', 'Changelog')}](${base}${isVue ? 'npm/docs/CHANGELOG.md' : 'flutter/CHANGELOG.md'}) · [MIT](${base}${isVue ? 'npm' : 'flutter'}/LICENSE)\n`;
  out += isVue ? `[DataSource](${base}npm/docs/data-source.md) · [Scheduler](${base}npm/docs/scheduler.md) · [Cards / Chat](${base}npm/docs/cards-chat.md) · [${label(lang, 'Erweiterungen', 'Extensions')}](${base}npm/docs/extensions.md)\n` : `[${label(lang, 'Komponentenzuordnung', 'Component mapping')}](${base}flutter/COMPONENTS.md) · [${label(lang, 'Erweiterungen', 'Extensions')}](${base}flutter/EXTENSIONS.md)\n`;
  return out;
}

for (const platform of process.argv.includes('--flutter-only') ? ['flutter'] : ['npm', 'flutter']) {
  let readme = `# ${platform === 'npm' ? '@tekocloud.de/tecexpress' : 'tecexpress for Flutter'}\n\n[Deutsch](#de) · [English](#en)\n\n`;
  readme += '<!-- API tables are generated from source. See tools/documentation/README.md in the repository. -->\n';
  for (const lang of ['de', 'en']) readme += intro(platform, lang) + (platform === 'npm' ? npmSections(lang) : dartSections(lang)) + development(platform, lang);
  fs.writeFileSync(`${platform}/README.md`, readme);
}

// Format complete Dart examples in one batch, then reuse them in API comments.
const formatted = new Map();
if (process.argv.includes('--format')) {
  const file = 'flutter/README.md';
  let readme = fs.readFileSync(file, 'utf8');
  const snippets = [...new Set([...readme.matchAll(/```dart\n([\s\S]*?)\n```/g)].map(m => m[1]).filter(s => s.includes('import ')))];
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'tecexpress-format-'));
  snippets.forEach((snippet, i) => fs.writeFileSync(path.join(dir, `example_${i}.dart`), snippet));
  const where = spawnSync(process.platform === 'win32' ? 'where.exe' : 'which', ['dart'], { encoding: 'utf8' });
  const launcher = where.stdout.trim().split(/\r?\n/)[0];
  const dart = process.platform === 'win32' ? path.join(path.dirname(launcher), 'cache/dart-sdk/bin/dart.exe') : launcher;
  const result = spawnSync(dart, ['format', dir], { encoding: 'utf8' });
  if (result.status !== 0) throw Error(result.stdout + result.stderr);
  snippets.forEach((snippet, i) => {
    const value = fs.readFileSync(path.join(dir, `example_${i}.dart`), 'utf8').trim();
    formatted.set(snippet.trim(), value);
    readme = readme.replaceAll('```dart\n' + snippet + '\n```', '```dart\n' + value + '\n```');
  });
  fs.writeFileSync(file, readme);
}

// API comments use AST offsets and never modify runtime tokens.
if (process.argv.includes('--dart-comments')) {
  const edits = new Map();
  const add = (file, node, lines) => {
    const fileEdits = edits.get(file) ?? new Map();
    fileEdits.set(node.offset, { lines, commentStart: node.commentStart, commentEnd: node.commentEnd });
    edits.set(file, fileEdits);
  };
  for (const api of dartApi) {
    if (!api.documented || process.argv.includes('--refresh-comments')) {
      const sample = dartExamples[api.name] ? dartExample(api.name) : dartApiExample(api.name, api.kind);
      add(api.file, api, [describe(api.name, 'de'), ...(notes[api.name] ? ['', text(notes[api.name], 'de')] : []), '', describe(api.name, 'en'), ...(notes[api.name] ? ['', text(notes[api.name], 'en')] : []), '', '```dart', ...(formatted.get(sample.trim()) ?? sample).split('\n'), '```']);
    }
    for (const member of api.members.filter((m, i, all) => all.findIndex(n => n.offset === m.offset) === i)) {
      if (member.documented && !process.argv.includes('--refresh-comments')) continue;
      const group = api.members.filter(m => m.offset === member.offset);
      const description = member.kind === 'constructor' ? [describe(api.name, 'de'), describe(api.name, 'en')] : ['de', 'en'].map(lang => group.map(m => `${group.length > 1 ? m.name + ': ' : ''}${fieldDescription(m.name, lang)}`).join('\n'));
      add(api.file, member, [...description[0].split('\n'), '', ...description[1].split('\n')]);
    }
  }
  for (const [file, offsets] of edits) {
    let source = fs.readFileSync(file, 'utf8');
    for (const [offset, { lines, commentStart, commentEnd }] of [...offsets].sort((a, b) => b[0] - a[0])) {
      const start = commentEnd == null ? source.lastIndexOf('\n', offset - 1) + 1 : source.indexOf('\n', commentEnd) + 1;
      const replaceStart = commentStart == null ? start : source.lastIndexOf('\n', commentStart - 1) + 1;
      const indent = source.slice(start).match(/^[ \t]*/)[0];
      source = source.slice(0, replaceStart) + lines.map(line => `${indent}///${line ? ' ' + line : ''}`).join('\n') + '\n' + source.slice(start);
    }
    fs.writeFileSync(file, source);
  }
}
const flutterReadmeBytes = fs.statSync('flutter/README.md').size;
if (flutterReadmeBytes > 262144) throw Error(`Flutter README exceeds pub.dev limit: ${flutterReadmeBytes} > 262144 bytes`);
console.log(`Flutter README: ${flutterReadmeBytes} / 262144 bytes.`);
if (missing.size) {
  console.error('Missing prose:', [...missing].join(', '));
  process.exitCode = 1;
} else console.log(`Documented ${symbols.length} npm exports and ${dartApi.length + 1} Dart exports in both languages.`);
