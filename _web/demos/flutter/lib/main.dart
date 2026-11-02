import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';
import 'generated/registry.dart';

void main() => runApp(const DemoApp());
class DemoApp extends StatefulWidget {
  const DemoApp({super.key});
  @override
  State<DemoApp> createState() => _DemoAppState();
}
class _DemoAppState extends State<DemoApp> {
  int revision = 0;
  final query = Uri.base.queryParameters;
  @override
  Widget build(BuildContext context) {
    final en = query['lang'] == 'en';
    final id = query['component'] ?? 'txdatagrid';
    final factory = examples[id];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TxTheme.light(), darkTheme: TxTheme.dark(),
      themeMode: query['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(en ? 'en' : 'de'),
      localizationsDelegates: TxLocalizations.delegates,
      supportedLocales: TxLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter / $id'), actions: [TextButton(onPressed: () => setState(() => revision++), child: Text(en ? 'Reset demo' : 'Demo zurücksetzen'))]),
        body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(en ? 'Interactive local example · Changes are not saved.' : 'Interaktives lokales Beispiel · Änderungen werden nicht gespeichert.'),
          const SizedBox(height: 24),
          Expanded(child: factory == null ? Text(en ? 'Unknown example.' : 'Unbekanntes Beispiel.') : _Example(key: ValueKey('$id-$revision'), factory: factory)),
        ])),
      ),
    );
  }
}
class _Example extends StatefulWidget {
  const _Example({super.key, required this.factory});
  final Widget Function() factory;
  @override
  State<_Example> createState() => _ExampleState();
}
class _ExampleState extends State<_Example> {
  late final Widget example = widget.factory();
  @override
  Widget build(BuildContext context) => SingleChildScrollView(child: example);
}
