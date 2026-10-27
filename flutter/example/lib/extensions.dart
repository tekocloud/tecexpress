import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

class ExtensionsShowcase extends StatefulWidget {
  const ExtensionsShowcase({super.key});
  @override
  State<ExtensionsShowcase> createState() => _ExtensionsShowcaseState();
}

class _ExtensionsShowcaseState extends State<ExtensionsShowcase> {
  static const items = [
    TxItem(value: 'design', text: 'Design', group: 'Produkt'),
    TxItem(value: 'development', text: 'Entwicklung', group: 'Produkt'),
    TxItem(value: 'sales', text: 'Vertrieb', group: 'Geschäft'),
    TxItem(value: 'archive', text: 'Archiv', disabled: true),
  ];
  late final shared = TxDataSource<TxItem<String>>.array(
    items,
    keyOf: (v) => v.value,
  );
  late final remote = TxDataSource<TxItem<String>>(
    TxDataSourceConfig<TxItem<String>>(
      store: TxCustomStore<TxItem<String>>(
        load: (options) async {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          options.cancellation?.throwIfCancelled();
          return txQuery(items, options);
        },
        byKey: (key) => items.where((v) => v.value == key).firstOrNull,
      ),
      pageSize: 2,
    ),
  );
  final files = TxMemoryFileProvider([
    const TxFileEntry(id: 'docs', name: 'Dokumente', isDirectory: true),
    const TxFileEntry(id: 'welcome', parentId: 'docs', name: 'Willkommen.txt'),
  ]);
  String? _choice = 'design';
  Set<String> _tags = {'design'}, _buttons = {};
  RangeValues _range = const RangeValues(20, 70);
  int _tab = 0;
  bool _popup = false, _toast = false;
  String? _tileUrl;
  static const actions = [
    TxAction(id: 'new', text: 'Neu erstellen', icon: Icons.add),
    TxAction(
      id: 'more',
      text: 'Weitere Aktionen',
      items: [
        TxAction(id: 'save', text: 'Speichern'),
        TxAction(id: 'delete', text: 'Löschen', destructive: true),
      ],
    ),
  ];
  @override
  void dispose() {
    shared.dispose();
    remote.dispose();
    super.dispose();
  }

  Widget _panel(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TxCard(title: title, child: child),
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _panel(
        'RadioGroup und ButtonGroup',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TxRadioGroup<String>(
              dataSource: shared,
              value: _choice,
              onChanged: (v) => setState(() => _choice = v),
            ),
            TxButtonGroup<String>(
              items: items,
              values: _buttons,
              selection: TxSelectionMode.multiple,
              onChanged: (v) => setState(() => _buttons = v),
            ),
            TxSelectBox<String>(
              dataSource: shared,
              value: _choice,
              onChanged: (v) => setState(() => _choice = v),
            ),
          ],
        ),
      ),
      _panel(
        'TagBox und Lookup',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TxTagBox<String>(
              dataSource: shared,
              values: _tags,
              applyOnConfirm: true,
              onChanged: (v) => setState(() => _tags = v),
            ),
            TxLookup<String>(
              dataSource: remote,
              value: _choice,
              label: 'Remote-Suche (simulierter Store)',
              onChanged: (v) => setState(() => _choice = v),
            ),
          ],
        ),
      ),
      _panel(
        'RangeSlider und RangeSelector',
        Column(
          children: [
            TxRangeSlider(
              value: _range,
              step: 5,
              minRange: 5,
              onChanged: (v) => setState(() => _range = v),
            ),
            TxRangeSelector<int>(
              value: _range,
              min: 0,
              max: 100,
              step: 5,
              items: List.generate(21, (i) => i * 5),
              argumentOf: (v) => v.toDouble(),
              valueOf: (v) => 20 + (v % 35).toDouble(),
              onChanged: (v) => setState(() => _range = v),
            ),
          ],
        ),
      ),
      _panel(
        'TabPanel und List',
        Column(
          children: [
            TxTabPanel(
              items: const [TxMenuItem('Übersicht'), TxMenuItem('Details')],
              selectedIndex: _tab,
              onChanged: (v) => setState(() => _tab = v),
              builder: (context, i) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Inhalt ${i + 1}'),
              ),
            ),
            TxList<TxItem<String>>(
              dataSource: shared,
              keyOf: (v) => v.value,
              textOf: (v) => v.text,
              groupOf: (v) => v.group,
              searchEnabled: true,
              height: 180,
            ),
          ],
        ),
      ),
      _panel(
        'Gallery und ContextMenu',
        TxContextMenu(
          items: actions,
          onItemClick: (v) => txNotify(context, message: v.text),
          child: TxGallery<int>(
            items: const [1, 2, 3],
            loop: true,
            itemBuilder: (context, i) => ColoredBox(
              color: [Colors.teal, Colors.deepPurple, Colors.indigo][i - 1],
              child: Center(
                child: Text(
                  'Motiv $i',
                  style: const TextStyle(color: Colors.white, fontSize: 32),
                ),
              ),
            ),
          ),
        ),
      ),
      _panel(
        'ActionSheet und Floating Action Button',
        Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () async {
                final action = await TxActionSheet.show(
                  context,
                  title: 'Aktion wählen',
                  items: actions,
                );
                if (context.mounted && action != null) {
                  txNotify(context, message: action.text);
                }
              },
              child: const Text('ActionSheet öffnen'),
            ),
            TxFloatingActionButton(
              items: actions,
              onItemClick: (v) => txNotify(context, message: v.text),
            ),
          ],
        ),
      ),
      _panel(
        'Popup, Toast, Tooltip und notify',
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _popup = true),
              child: const Text('Dialog öffnen'),
            ),
            OutlinedButton(
              onPressed: () => setState(() => _toast = true),
              child: const Text('Toast'),
            ),
            const TxTooltip(
              text: 'Auch per Tastatur erreichbar',
              child: Icon(Icons.info_outline),
            ),
            OutlinedButton(
              onPressed: () => txNotify(
                context,
                message: 'Gespeichert',
                type: TxToastType.success,
              ),
              child: const Text('txNotify()'),
            ),
          ],
        ),
      ),
      _panel(
        'LoadPanel',
        TxLoadPanel(
          dataSource: remote,
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: Center(
              child: OutlinedButton(
                onPressed: () =>
                    remote.reload().catchError((_) => <TxItem<String>>[]),
                child: const Text('Daten neu laden'),
              ),
            ),
          ),
        ),
      ),
      _panel('File Manager', TxFileManager(provider: files)),
      _panel(
        'File Uploader',
        TxFileUploader(
          multiple: true,
          maxFileSize: 10000000,
          adapter: (file, context) async {
            final result = await files.upload(
              null,
              file,
              cancellation: context.cancellation,
            );
            final size = await file.length();
            context.onProgress(size, size);
            return result;
          },
        ),
      ),
      _panel(
        'Map',
        Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Kachel-URL',
                hintText: 'https://…/{z}/{x}/{y}.png',
              ),
              onSubmitted: (v) =>
                  setState(() => _tileUrl = v.isEmpty ? null : v),
            ),
            TxMap(
              tileUrl: _tileUrl,
              markers: const [
                TxMapMarker(52.52, 13.405, id: 'berlin', text: 'Berlin'),
                TxMapMarker(53.55, 10, id: 'hamburg', text: 'Hamburg'),
              ],
              routes: const [
                TxMapRoute(
                  id: 'route',
                  points: [
                    TxCoordinate(52.52, 13.405),
                    TxCoordinate(53.55, 10),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      _panel(
        'DataSource-Konfiguration im DataGrid',
        TxDataGrid<TxItem<String>>(
          dataSource: TxDataSourceConfig<TxItem<String>>(
            store: TxArrayStore(items, keyOf: (v) => v.value),
            pageSize: 2,
          ),
          keyOf: (v) => v.value,
          columns: [
            TxColumn(caption: 'Team', valueGetter: (v) => v.text),
            TxColumn(caption: 'Gruppe', valueGetter: (v) => v.group),
          ],
          selection: TxSelectionMode.multiple,
        ),
      ),
      TxPopup(
        visible: _popup,
        title: 'Flexibler Dialog',
        dragEnabled: true,
        resizeEnabled: true,
        hideOnOutsideClick: true,
        onVisibleChanged: (v) => setState(() => _popup = v),
        child: const Text('Am Titel verschieben und an der Ecke vergrößern.'),
      ),
      TxToast(
        visible: _toast,
        onVisibleChanged: (v) => setState(() => _toast = v),
        message: 'Beispielmeldung',
        type: TxToastType.warning,
      ),
    ],
  );
}
