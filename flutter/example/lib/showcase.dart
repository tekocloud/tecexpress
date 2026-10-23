import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

/// Every public component is demonstrated by this application.
class TecexpressShowcase extends StatefulWidget {
  const TecexpressShowcase({super.key});
  @override
  State<TecexpressShowcase> createState() => _TecexpressShowcaseState();
}

class _TecexpressShowcaseState extends State<TecexpressShowcase> {
  bool _dark = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'tecexpress · Flutter',
    debugShowCheckedModeBanner: false,
    theme: TxTheme.light(),
    darkTheme: TxTheme.dark(),
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    locale: const Locale('de'),
    localizationsDelegates: TxLocalizations.delegates,
    supportedLocales: TxLocalizations.supportedLocales,
    home: _ShowcaseHome(
      dark: _dark,
      onThemeChanged: () => setState(() => _dark = !_dark),
    ),
  );
}

class _Project {
  const _Project(this.id, this.title, this.team, this.status, this.amount);
  final int id;
  final String title, team, status;
  final num amount;
}

class _ShowcaseHome extends StatefulWidget {
  const _ShowcaseHome({required this.dark, required this.onThemeChanged});
  final bool dark;
  final VoidCallback onThemeChanged;
  @override
  State<_ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<_ShowcaseHome> {
  static const sections = [
    'Eingaben & Oberfläche',
    'DataGrid',
    'Scheduler',
    'Cards',
    'Chat',
  ];
  static const icons = [
    Icons.tune,
    Icons.table_chart_outlined,
    Icons.calendar_month,
    Icons.dashboard_outlined,
    Icons.chat_bubble_outline,
  ];
  int _section = 0, _tab = 0;
  bool _checked = true,
      _enabled = true,
      _popup = false,
      _toast = false,
      _readOnlyChat = false,
      _typing = false;
  bool _showLoading = false;
  num? _quantity = 12;
  String? _category = 'technik';
  DateTime? _date = DateTime(2026, 10, 23);
  final _name = TextEditingController(text: 'Stefan Bess'),
      _note = TextEditingController(text: 'Lieferung am Vormittag.');
  final _chatInput = TextEditingController();
  final _user = TxChatUser(id: 'me', name: 'Stefan Bess'),
      _colleague = TxChatUser(id: 'lena', name: 'Lena Fischer');
  late List<TxChatMessage> _messages = [
    TxChatMessage(
      id: 1,
      text: 'Hallo! Willkommen in tecexpress für Flutter.',
      timestamp: DateTime(2026, 10, 23, 9),
      author: _colleague,
    ),
    TxChatMessage(
      id: 2,
      text: 'Alle Komponenten in Light und Dark. Schön, dass du da bist!',
      timestamp: DateTime(2026, 10, 23, 9, 1),
      author: _user,
    ),
  ];
  Set<Object> _selected = {}, _selectedCards = {};
  DateTime _schedulerDate = DateTime(2026, 10, 23);
  TxSchedulerView _view = TxSchedulerView.week;
  List<TxAppointment> _appointments = [
    TxAppointment(
      id: 1,
      text: 'Projektbesprechung',
      startDate: DateTime(2026, 10, 23, 9),
      endDate: DateTime(2026, 10, 23, 10, 30),
    ),
    TxAppointment(
      id: 2,
      text: 'Kundengespräch',
      startDate: DateTime(2026, 10, 23, 9, 30),
      endDate: DateTime(2026, 10, 23, 11),
    ),
    TxAppointment(
      id: 3,
      text: 'Release-Tag',
      startDate: DateTime(2026, 10, 22),
      endDate: DateTime(2026, 10, 23),
      allDay: true,
    ),
    TxAppointment(
      id: 4,
      text: 'Vorbereitung & Lieferung',
      startDate: DateTime(2026, 10, 21, 16),
      endDate: DateTime(2026, 10, 22, 10),
    ),
  ];
  final _projects = List.generate(
    12,
    (i) => _Project(
      i + 1,
      ['Kundenportal', 'Team Workspace', 'Brand Studio', 'Analytics Hub'][i %
          4],
      ['Produkt & Design', 'Entwicklung', 'Kreation'][i % 3],
      ['In Bearbeitung', 'Review', 'Geplant'][i % 3],
      1280 + i * 230,
    ),
  );
  void _notify(String text) => TxToast.show(context, text);
  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    _chatInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 950;
    return Scaffold(
      appBar: AppBar(
        title: const Text('tecexpress · Flutter 0.4.0'),
        actions: [
          IconButton(
            tooltip: 'Theme wechseln',
            onPressed: widget.onThemeChanged,
            icon: Icon(
              widget.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: SafeArea(
                child: ListView(
                  children: [
                    const ListTile(title: Text('Komponenten')),
                    for (var i = 0; i < sections.length; i++)
                      ListTile(
                        title: Text(sections[i]),
                        leading: Icon(icons[i]),
                        selected: _section == i,
                        onTap: () {
                          setState(() => _section = i);
                          Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _section,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (index) =>
                  setState(() => _section = index),
              destinations: [
                for (var i = 0; i < sections.length; i++)
                  NavigationRailDestination(
                    icon: Icon(icons[i]),
                    label: Text(sections[i]),
                  ),
              ],
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1250),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          sections[_section],
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Native Widgets · MIT · Light & Dark · Ohne Lizenzkey',
                        ),
                        const SizedBox(height: 24),
                        switch (_section) {
                          1 => _grid(),
                          2 => _scheduler(),
                          3 => _cards(),
                          4 => _chat(),
                          _ => _editors(),
                        },
                        const SizedBox(height: 24),
                        const Text(
                          'Lokale Demo. Keine Daten werden an einen Server gesendet.',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editors() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TxToolbar(
        label: 'Demo-Aktionen',
        after: [
          TxTooltip(
            text: 'Alle Daten bleiben lokal.',
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.info_outline),
            ),
          ),
        ],
        children: [
          TxButton(
            text: 'Speichern',
            type: TxButtonType.primary,
            onPressed: () => _notify('Gespeichert'),
          ),
          TxButton(
            text: 'Erfolg',
            type: TxButtonType.success,
            onPressed: () => _notify('Erfolg'),
          ),
          TxButton(
            text: 'Löschen',
            type: TxButtonType.danger,
            onPressed: () => _notify('Löschaktion'),
          ),
          const TxButton(text: 'Deaktiviert', disabled: true),
        ],
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < 600
              ? constraints.maxWidth
              : (constraints.maxWidth - 20) / 2;
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              SizedBox(
                width: width,
                child: TxTextBox(controller: _name, label: 'Name'),
              ),
              SizedBox(
                width: width,
                child: TxSelectBox<String>(
                  label: 'Kategorie',
                  value: _category,
                  items: const [
                    TxItem(value: 'technik', text: 'Technik'),
                    TxItem(value: 'design', text: 'Design'),
                  ],
                  onChanged: (value) => setState(() => _category = value),
                ),
              ),
              SizedBox(
                width: width,
                child: TxNumberBox(
                  value: _quantity,
                  label: 'Stückzahl',
                  min: 0,
                  onChanged: (value) => setState(() => _quantity = value),
                ),
              ),
              SizedBox(
                width: width,
                child: TxDateBox(
                  value: _date,
                  label: 'Lieferdatum',
                  onChanged: (value) => setState(() => _date = value),
                ),
              ),
              SizedBox(
                width: width,
                child: TxTextArea(controller: _note, label: 'Notiz'),
              ),
              SizedBox(
                width: width,
                child: Column(
                  children: [
                    TxCheckBox(
                      value: _checked,
                      label: 'Updates erhalten',
                      onChanged: (value) => setState(() => _checked = value),
                    ),
                    TxSwitch(
                      value: _enabled,
                      label: 'Benachrichtigungen aktiv',
                      onChanged: (value) => setState(() => _enabled = value),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 24),
      TxTabs(
        items: const [
          TxMenuItem('Übersicht'),
          TxMenuItem('Details'),
          TxMenuItem('Archiv', disabled: true),
        ],
        selectedIndex: _tab,
        onChanged: (index) => setState(() => _tab = index),
        builder: (_, index) => Text(
          index == 0
              ? 'Ein guter Überblick macht den Unterschied.'
              : 'Hier finden deine Details Platz.',
        ),
      ),
      TxMenu(
        items: const [
          TxMenuItem('Datei'),
          TxMenuItem('Bearbeiten'),
          TxMenuItem('Exportieren', disabled: true),
        ],
        onItemClick: (item, index) => _notify(item.text),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TxButton(
            text: 'Dialog öffnen',
            onPressed: () => setState(() => _popup = true),
          ),
          TxButton(
            text: 'Toast anzeigen',
            onPressed: () => setState(() => _toast = true),
          ),
          TxButton(
            text: 'Ladeanzeige umschalten',
            onPressed: () => setState(() => _showLoading = !_showLoading),
          ),
          TxLoadIndicator(visible: _showLoading),
        ],
      ),
      const SizedBox(height: 24),
      const TxTextBox(
        initialValue: 'Ungültige Eingabe',
        label: 'Fehlerzustand',
        isValid: false,
      ),
      TxPopup(
        visible: _popup,
        title: 'Dein Dialog',
        onVisibleChanged: (value) => setState(() => _popup = value),
        actions: [
          TxButton(
            text: 'Bestätigen',
            type: TxButtonType.primary,
            onPressed: () => setState(() => _popup = false),
          ),
        ],
        child: const Text(
          'Tastaturfokus bleibt im Dialog. Escape schließt ihn.',
        ),
      ),
      TxToast(
        visible: _toast,
        message: 'Änderungen gespeichert.',
        type: TxToastType.success,
        onVisibleChanged: (value) => setState(() => _toast = value),
      ),
    ],
  );
  Widget _grid() => TxDataGrid<_Project>(
    dataSource: _projects,
    keyOf: (row) => row.id,
    selection: TxSelectionMode.multiple,
    selectedRowKeys: _selected,
    onSelectedRowKeysChanged: (keys) => setState(() => _selected = keys),
    pageSize: 5,
    onRowClick: (row) => _notify('Projekt ${row.title}'),
    columns: [
      TxColumn(caption: 'Projekt', valueGetter: (row) => row.title, width: 210),
      TxColumn(caption: 'Team', valueGetter: (row) => row.team, width: 190),
      TxColumn(caption: 'Status', valueGetter: (row) => row.status),
      TxColumn(
        caption: 'Betrag',
        valueGetter: (row) => row.amount,
        alignment: Alignment.centerRight,
        cellBuilder: (_, row, value) => Text('${row.amount} €'),
      ),
    ],
  );
  Widget _scheduler() => TxScheduler(
    dataSource: _appointments,
    onDataSourceChanged: (items) => setState(() => _appointments = items),
    currentDate: _schedulerDate,
    onCurrentDateChanged: (value) => setState(() => _schedulerDate = value),
    currentView: _view,
    onCurrentViewChanged: (value) => setState(() => _view = value),
    label: 'Teamkalender',
  );
  Widget _cards() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const TxCard(
        title: 'Dein nächstes Projekt',
        subtitle: 'Ein guter Anfang braucht eine klare Basis.',
        variant: TxCardVariant.filled,
        child: Text(
          'Header, Inhalt, Medien und Aktionen lassen sich frei gestalten.',
        ),
      ),
      const SizedBox(height: 24),
      TxCardView<_Project>(
        dataSource: _projects,
        keyOf: (row) => row.id,
        titleOf: (row) => row.title,
        subtitleOf: (row) => row.status,
        pageSize: 3,
        selection: TxSelectionMode.multiple,
        selectedCardKeys: _selectedCards,
        onSelectedCardKeysChanged: (keys) =>
            setState(() => _selectedCards = keys),
        onCardClick: (row) => _notify(row.title),
        columns: [
          TxCardField(caption: 'Team', valueGetter: (row) => row.team),
          TxCardField(caption: 'Status', valueGetter: (row) => row.status),
        ],
        mediaBuilder: (context, row) => Container(
          height: 120,
          color: txThemeOf(context).hover,
          child: Icon(
            Icons.dashboard_outlined,
            size: 48,
            color: txThemeOf(context).accent,
          ),
        ),
      ),
    ],
  );
  Widget _chat() => Column(
    children: [
      TxSwitch(
        value: _readOnlyChat,
        label: 'Chat nur lesen',
        onChanged: (value) => setState(() => _readOnlyChat = value),
      ),
      TxSwitch(
        value: _typing,
        label: 'Schreibanzeige simulieren',
        onChanged: (value) => setState(() => _typing = value),
      ),
      const SizedBox(height: 12),
      TxChat(
        user: _user,
        items: _messages,
        controller: _chatInput,
        onItemsChanged: (items) => setState(() => _messages = items),
        title: 'Projektchat',
        subtitle: 'Kundenportal · Produkt & Design',
        readOnly: _readOnlyChat,
        typingUsers: _typing ? [_colleague] : [],
      ),
      const SizedBox(height: 12),
      TxButton(
        text: 'Beispielantwort einfügen',
        onPressed: () => setState(
          () => _messages = [
            ..._messages,
            TxChatMessage(
              id: 'reply-${DateTime.now().microsecondsSinceEpoch}',
              text: 'Lokale Beispielantwort. Kein Backend und kein KI-Dienst.',
              timestamp: DateTime.now(),
              author: _colleague,
            ),
          ],
        ),
      ),
    ],
  );
}
