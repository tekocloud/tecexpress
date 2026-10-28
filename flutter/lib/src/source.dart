import 'dart:async';

import 'package:flutter/widgets.dart';

/// Getter für den stabilen eindeutigen Schlüssel eines Datensatzes.
///
/// Getter for a stable unique record key.
///
/// ```dart
/// TxKeyOf<int> keyOf = (item) => item;
/// print(keyOf(1));
/// ```
typedef TxKeyOf<T> = Object Function(T item);

/// Typisierter Getter zum Lesen von Abfragewerten.
///
/// Typed getter for reading query values.
///
/// ```dart
/// TxGetter<int> getter = (item) => item * 2;
/// print(getter(3));
/// ```
typedef TxGetter<T> = Object? Function(T item);

/// Sortier- oder Gruppierungsbeschreibung mit Selector und absteigender Richtung.
///
/// Sort or group descriptor with a selector and descending direction.
///
/// ```dart
/// final sort = TxSort<int>((v) => v, desc: true);
/// print(txQuery([1, 2], TxLoadOptions(sort: [sort])).data);
/// ```
class TxSort<T> {
  /// Sortier- oder Gruppierungsbeschreibung mit Selector und absteigender Richtung.
  ///
  /// Sort or group descriptor with a selector and descending direction.
  const TxSort(this.selector, {this.desc = false});

  /// Feldpfad oder Getter des Abfragewerts.
  ///
  /// Field path or getter for a query value.
  final TxGetter<T> selector;

  /// Absteigende Sortierung.
  ///
  /// Descending sort order.
  final bool desc;
}

/// Vergleichs- und Textoperatoren für TxFilter.
///
/// Comparison and text operators for TxFilter.
///
/// ```dart
/// print(TxFilterOperator.values);
/// ```
enum TxFilterOperator {
  equal,
  notEqual,
  greater,
  greaterOrEqual,
  less,
  lessOrEqual,
  contains,
  startsWith,
  endsWith,
}

/// Vergleichs-/Textfilter und verschachtelte UND-, ODER- und NICHT-Verknüpfungen.
///
/// Standardoperator ist Gleichheit. Textoperatoren ignorieren Groß-/Kleinschreibung. Leeres AND ist wahr, leeres OR ist falsch. Dart matches(item) liefert bool, Vue txMatches(item, filter) boolean. Getterfehler werden weitergegeben.
///
/// Comparison/text filter and nested AND, OR and NOT expressions.
///
/// The default operator is equality. Text operators ignore case. Empty AND is true; empty OR is false. Dart matches(item) returns bool; Vue txMatches(item, filter) returns boolean. Getter errors propagate.
///
/// ```dart
/// final adult = TxFilter<int>((v) => v, 18, operator: TxFilterOperator.greaterOrEqual);
/// print(adult.matches(20));
/// print(TxFilter.and([adult, TxFilter.not(TxFilter<int>((v) => v, 30))]).matches(20));
/// print(TxFilter.or([adult]).matches(20));
/// ```
class TxFilter<T> {
  /// Vergleichs-/Textfilter und verschachtelte UND-, ODER- und NICHT-Verknüpfungen.
  ///
  /// Comparison/text filter and nested AND, OR and NOT expressions.
  const TxFilter(
    this.selector,
    this.value, {
    this.operator = TxFilterOperator.equal,
  }) : children = null,
       junction = null;

  /// Vergleichs-/Textfilter und verschachtelte UND-, ODER- und NICHT-Verknüpfungen.
  ///
  /// Comparison/text filter and nested AND, OR and NOT expressions.
  const TxFilter.and(List<TxFilter<T>> filters)
    : selector = null,
      value = null,
      operator = TxFilterOperator.equal,
      children = filters,
      junction = 'and';

  /// Vergleichs-/Textfilter und verschachtelte UND-, ODER- und NICHT-Verknüpfungen.
  ///
  /// Comparison/text filter and nested AND, OR and NOT expressions.
  const TxFilter.or(List<TxFilter<T>> filters)
    : selector = null,
      value = null,
      operator = TxFilterOperator.equal,
      children = filters,
      junction = 'or';

  /// Vergleichs-/Textfilter und verschachtelte UND-, ODER- und NICHT-Verknüpfungen.
  ///
  /// Comparison/text filter and nested AND, OR and NOT expressions.
  TxFilter.not(TxFilter<T> filter)
    : selector = null,
      value = null,
      operator = TxFilterOperator.equal,
      children = [filter],
      junction = 'not';

  /// Feldpfad oder Getter des Abfragewerts.
  ///
  /// Field path or getter for a query value.
  final TxGetter<T>? selector;

  /// Aktueller Eingabe-/Optionswert.
  ///
  /// Current input/option value.
  final Object? value;

  /// Vergleichs-/Textoperator.
  ///
  /// Comparison/text operator.
  final TxFilterOperator operator;

  /// Unterfilter beziehungsweise enthaltene Widgets.
  ///
  /// Child filters or contained widgets.
  final List<TxFilter<T>>? children;

  /// Verknüpfung and/or/not eines zusammengesetzten Filters.
  ///
  /// and/or/not junction of a compound filter.
  final String? junction;

  /// Prüft synchron einen Datensatz gegen diesen Filter.
  ///
  /// Synchronously tests a record against this filter.
  bool matches(T item) {
    if (junction == 'and') return children!.every((f) => f.matches(item));
    if (junction == 'or') return children!.any((f) => f.matches(item));
    if (junction == 'not') return !children!.first.matches(item);
    final a = selector!(item),
        c = txSourceCompare(a, value),
        text = '${a ?? ''}'.toLowerCase(),
        query = '${value ?? ''}'.toLowerCase();
    return switch (operator) {
      TxFilterOperator.equal => a == value,
      TxFilterOperator.notEqual => a != value,
      TxFilterOperator.greater => c > 0,
      TxFilterOperator.greaterOrEqual => c >= 0,
      TxFilterOperator.less => c < 0,
      TxFilterOperator.lessOrEqual => c <= 0,
      TxFilterOperator.contains => text.contains(query),
      TxFilterOperator.startsWith => text.startsWith(query),
      TxFilterOperator.endsWith => text.endsWith(query),
    };
  }
}

/// Vergleicht null, Zahlen, Datumswerte oder kleingeschriebene Textdarstellungen; liefert einen negativen Wert, null oder einen positiven Wert.
///
/// Parameter a/b dürfen null sein. null sortiert vor anderen Werten. Zahlen und DateTime werden numerisch/zeitlich verglichen, andere Werte als kleingeschriebener Text. Rückgabe int wie compareTo.
///
/// Compares nulls, numbers, dates or lower-case text representations; returns a negative number, zero or a positive number.
///
/// Parameters a/b may be null. null sorts before other values. Numbers and DateTime values compare numerically/chronologically; other values compare as lower-case text. Returns an int following compareTo conventions.
///
/// ```dart
/// print(txSourceCompare(1, 2)); // negative
/// ```
int txSourceCompare(Object? a, Object? b) {
  if (a == null) return b == null ? 0 : -1;
  if (b == null) return 1;
  if (a is num && b is num) return a.compareTo(b);
  if (a is DateTime && b is DateTime) return a.compareTo(b);
  return '$a'.toLowerCase().compareTo('$b'.toLowerCase());
}

/// Kooperativer Abbruch mit einmaligen Listenern; throwIfCancelled wirft bei Abbruch StateError.
///
/// Cooperative cancellation with one-shot listeners; throwIfCancelled throws StateError after cancellation.
///
/// ```dart
/// final token = TxCancellation();
/// final unregister = token.onCancel(() => debugPrint('Cancelled'));
/// token.throwIfCancelled();
/// token.cancel();
/// unregister();
/// ```
class TxCancellation {
  /// Ob der Abbruch bereits ausgelöst wurde.
  ///
  /// Whether cancellation has been requested.
  bool isCancelled = false;
  final _listeners = <VoidCallback>[];

  /// Synchron auf true setzen, um die Aktion abzubrechen.
  ///
  /// Set synchronously to true to cancel the action.
  void cancel() {
    if (isCancelled) return;
    isCancelled = true;
    for (final listener in [..._listeners]) {
      listener();
    }
    _listeners.clear();
  }

  /// Registriert einen Abbruchlistener; nach Abbruch sofortiger Aufruf. Rückgabe entfernt den Listener.
  ///
  /// Registers a cancellation listener; called immediately if already cancelled. The return value unregisters it.
  VoidCallback onCancel(VoidCallback listener) {
    if (isCancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
    return () => _listeners.remove(listener);
  }

  /// Wirft StateError, wenn der Token abgebrochen ist.
  ///
  /// Throws StateError if the token was cancelled.
  void throwIfCancelled() {
    if (isCancelled) throw StateError('Operation cancelled');
  }
}

/// Abfragevertrag für Stores: Filter, Suche, Sortierung, Gruppierung, Paging, Projektion und Abbruch.
///
/// Vue: nicht gesetzte Optionen sind undefined; die DataSource ergänzt Counts und Paging. Dart-Standards stehen im Konstruktor. skip/take gelten für Zeilen und oberste Gruppen. Lokale Verarbeitung liefert Counts auch ohne Count-Anforderung. Vue select ist eine Feldliste, Dart select ein T→T-Callback. signal/cancellation wird an eigene asynchrone Operationen weitergereicht.
///
/// Store query contract: filtering, searching, sorting, grouping, paging, projection and cancellation.
///
/// Vue: omitted options are undefined; DataSource supplies count and paging defaults. Dart defaults appear in the constructor. skip/take apply to rows and top-level groups. Local processing returns counts even without a count request. Vue select is a field list; Dart select is a T→T callback. Forward signal/cancellation to custom async operations.
///
/// ```dart
/// final options = TxLoadOptions<int>(sort: [TxSort((v) => v)], take: 1);
/// print(txQuery([2, 1], options).data);
/// ```
class TxLoadOptions<T> {
  /// Abfragevertrag für Stores: Filter, Suche, Sortierung, Gruppierung, Paging, Projektion und Abbruch.
  ///
  /// Store query contract: filtering, searching, sorting, grouping, paging, projection and cancellation.
  const TxLoadOptions({
    this.sort = const [],
    this.filter,
    this.searchExpr = const [],
    this.searchValue = '',
    this.group = const [],
    this.skip = 0,
    this.take,
    this.select,
    this.requireTotalCount = true,
    this.requireGroupCount = false,
    this.cancellation,
  });

  /// sort: Sortierbeschreibungen in Prioritätsreihenfolge.
  /// group: Gruppierungsbeschreibungen beziehungsweise Gruppenname.
  ///
  /// sort: Sort descriptors in priority order.
  /// group: Group descriptors or group name.
  final List<TxSort<T>> sort, group;

  /// Filterausdruck.
  ///
  /// Filter expression.
  final TxFilter<T>? filter;

  /// Felder beziehungsweise Getter der Suche.
  ///
  /// Search fields or getters.
  final List<TxGetter<T>> searchExpr;

  /// Suchtext, lokal ohne Beachtung der Groß-/Kleinschreibung.
  ///
  /// Search text; local search ignores case.
  final String searchValue;

  /// Anzahl zu überspringender Ergebnisse.
  ///
  /// Number of results to skip.
  final int skip;

  /// Maximale Anzahl zurückzugebender Ergebnisse.
  ///
  /// Maximum number of results to return.
  final int? take;

  /// Projektion vor dem abschließenden Mapping.
  ///
  /// Projection before final mapping.
  final T Function(T)? select;

  /// requireTotalCount: Fordert die Gesamtanzahl vor Paging an.
  /// requireGroupCount: Fordert die Anzahl oberster Gruppen an.
  ///
  /// requireTotalCount: Requests the total count before paging.
  /// requireGroupCount: Requests the number of top-level groups.
  final bool requireTotalCount, requireGroupCount;

  /// Token für kooperativen Abbruch.
  ///
  /// Cooperative cancellation token.
  final TxCancellation? cancellation;
}

/// Gruppierter Abfragebestand mit Gruppenschlüssel und Anzahl vor dem Paging.
///
/// Grouped query data with a group key and count before paging.
///
/// ```dart
/// const group = TxGroup<int>(key: 'team', items: [1, 2], count: 2);
/// print(group.count);
/// ```
class TxGroup<T> {
  /// Gruppierter Abfragebestand mit Gruppenschlüssel und Anzahl vor dem Paging.
  ///
  /// Grouped query data with a group key and count before paging.
  const TxGroup({
    required this.key,
    required this.items,
    required this.count,
    this.groups = const [],
  });

  /// Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln.
  ///
  /// Stable key or selector; distinct from a widget key.
  final Object? key;

  /// Einträge; bei Datenbindung durch dataSource ersetzt.
  ///
  /// Entries; replaced by dataSource when bound.
  final List<T> items;

  /// Anzahl Datensätze der Gruppe.
  ///
  /// Record count in the group.
  final int count;

  /// Gruppenhierarchie des Ergebnisses.
  ///
  /// Result group hierarchy.
  final List<TxGroup<T>> groups;
}

/// Ladeergebnis mit flachen Datensätzen und optionaler Gesamtanzahl und Gruppenhierarchie.
///
/// Load result with flat records and optional total count and group hierarchy.
///
/// ```dart
/// const result = TxLoadResult<int>(data: [1], totalCount: 2);
/// print(result.data);
/// ```
class TxLoadResult<T> {
  /// Ladeergebnis mit flachen Datensätzen und optionaler Gesamtanzahl und Gruppenhierarchie.
  ///
  /// Load result with flat records and optional total count and group hierarchy.
  const TxLoadResult({
    required this.data,
    this.totalCount,
    this.groups = const [],
    this.groupCount,
  });

  /// Datensätze beziehungsweise Nutzdaten des Ereignisses.
  ///
  /// Records or event payload.
  final List<T> data;

  /// totalCount: Gesamtanzahl gefilterter Datensätze vor Paging.
  /// groupCount: Anzahl oberster Gruppen vor Paging.
  ///
  /// totalCount: Total filtered record count before paging.
  /// groupCount: Top-level group count before paging.
  final int? totalCount, groupCount;

  /// Gruppenhierarchie des Ergebnisses.
  ///
  /// Result group hierarchy.
  final List<TxGroup<T>> groups;
}

/// Store-Vertrag für Laden sowie optionale Schlüsselauflösung und Schreiboperationen.
///
/// Store contract for loading and optional key resolution and writes.
///
/// ```dart
/// TxStore<int> store = TxArrayStore([1, 2], keyOf: (v) => v);
/// print(await store.load(const TxLoadOptions()));
/// ```
abstract class TxStore<T> {
  /// Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben.
  ///
  /// Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate.
  FutureOr<TxLoadResult<T>> load(TxLoadOptions<T> options);

  /// Ob der Store Insert unterstützt.
  ///
  /// Whether the store supports Insert.
  bool get canInsert => false;

  /// Ob der Store Update unterstützt.
  ///
  /// Whether the store supports Update.
  bool get canUpdate => false;

  /// Ob der Store Remove unterstützt.
  ///
  /// Whether the store supports Remove.
  bool get canRemove => false;

  /// Ob der Store ByKey unterstützt.
  ///
  /// Whether the store supports ByKey.
  bool get canByKey => false;

  /// Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart).
  ///
  /// Reads a record by key; missing keys return undefined (Vue) or null (Dart).
  FutureOr<T?> byKey(Object key) => throw UnsupportedError('byKey');

  /// Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück.
  ///
  /// Inserts a record with a unique key and returns it.
  FutureOr<T> insert(T item) => throw UnsupportedError('insert');

  /// Aktualisiert eine Meldung beziehungsweise einen Datensatz.
  ///
  /// Updates a notification or record.
  FutureOr<T> update(Object key, T Function(T) change) =>
      throw UnsupportedError('update');

  /// Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand.
  ///
  /// Removes the record or recursively removes a file/directory tree.
  FutureOr<void> remove(Object key) => throw UnsupportedError('remove');
}

/// Verarbeitet lokale Daten synchron: Filtern/Suchen, Sortieren/Gruppieren, Paging und Projektion. Das Eingangsarray bleibt erhalten.
///
/// Parameter: input = Ausgangsliste, o/options = TxLoadOptions. Synchrones Ergebnis: TxLoadResult mit flacher data-Liste, totalCount vor Paging und optionalen groups/groupCount. Gruppierung ändert nicht die Form von data. Getter-/Projektionsfehler werden weitergegeben; Dart skip/take dürfen nicht negativ sein.
///
/// Synchronously processes local data: filter/search, sort/group, page and project. The input array is preserved.
///
/// Parameters: input = source list, o/options = TxLoadOptions. Synchronous result: TxLoadResult with flat data, totalCount before paging and optional groups/groupCount. Grouping does not change the shape of data. Getter/projection errors propagate; Dart skip/take must not be negative.
///
/// ```dart
/// print(txQuery([2, 1], TxLoadOptions<int>(sort: [TxSort((v) => v)], take: 1)).data);
/// ```
TxLoadResult<T> txQuery<T>(List<T> input, TxLoadOptions<T> options) {
  var rows = input
      .where(
        (item) =>
            (options.filter?.matches(item) ?? true) &&
            (options.searchValue.isEmpty ||
                (options.searchExpr.isEmpty
                        ? <Object?>[item]
                        : options.searchExpr.map((f) => f(item)))
                    .any(
                      (value) => '$value'.toLowerCase().contains(
                        options.searchValue.toLowerCase(),
                      ),
                    )),
      )
      .toList();
  final sort = [...options.group, ...options.sort];
  if (sort.isNotEmpty) {
    rows.sort((a, b) {
      for (final s in sort) {
        final c = txSourceCompare(s.selector(a), s.selector(b));
        if (c != 0) return s.desc ? -c : c;
      }
      return 0;
    });
  }
  final total = rows.length;
  List<TxGroup<T>> group(List<T> data, int level) {
    final buckets = <Object?, List<T>>{};
    for (final row in data) {
      buckets
          .putIfAbsent(options.group[level].selector(row), () => [])
          .add(row);
    }
    return buckets.entries
        .map(
          (e) => TxGroup<T>(
            key: e.key,
            items: List.unmodifiable(e.value),
            count: e.value.length,
            groups: level + 1 < options.group.length
                ? group(e.value, level + 1)
                : [],
          ),
        )
        .toList();
  }

  final groups = options.group.isEmpty ? <TxGroup<T>>[] : group(rows, 0);
  rows = rows.skip(options.skip).take(options.take ?? rows.length).toList();
  return TxLoadResult(
    data: options.select == null ? rows : rows.map(options.select!).toList(),
    totalCount: total,
    groups: groups
        .skip(options.skip)
        .take(options.take ?? groups.length)
        .toList(),
    groupCount: groups.length,
  );
}

/// Kopierter Speicherbestand mit lokaler Abfrage und schlüsselbasierten CRUD-Operationen.
///
/// Vue: data = [], key = "id". Dart: data ist erforderlich; ohne keyOf sind nur Abfragen möglich. Konstruktion kopiert die Liste. Doppelte Schlüssel, Einfügen vorhandener Schlüssel und Schlüsseländerungen werden abgelehnt. update/remove mit unbekanntem Schlüssel schlagen fehl; byKey liefert undefined/null.
///
/// Copied in-memory collection with local queries and key-based CRUD operations.
///
/// Vue: data = [], key = "id". Dart: data is required; without keyOf only queries are supported. Construction copies the list. Duplicate keys, insertion of existing keys and key changes are rejected. update/remove with an unknown key fail; byKey returns undefined/null.
///
/// ```dart
/// final store = TxArrayStore<Map<String, Object>>([{'id': 1}], keyOf: (row) => row['id']!);
/// print(store.load(const TxLoadOptions()));
/// print(store.byKey(1));
/// store.insert({'id': 2});
/// store.update(2, (row) => {...row, 'name': 'Two'});
/// store.remove(2);
/// ```
class TxArrayStore<T> extends TxStore<T> {
  /// Kopierter Speicherbestand mit lokaler Abfrage und schlüsselbasierten CRUD-Operationen.
  ///
  /// Copied in-memory collection with local queries and key-based CRUD operations.
  TxArrayStore(List<T> data, {this.keyOf}) : _data = List.of(data) {
    if (keyOf != null && _data.map(keyOf!).toSet().length != _data.length) {
      throw ArgumentError('Duplicate keys');
    }
  }
  final List<T> _data;

  /// Liest den stabilen Datensatzschlüssel.
  ///
  /// Reads the stable record key.
  final TxKeyOf<T>? keyOf;

  /// Datensätze beziehungsweise Nutzdaten des Ereignisses.
  ///
  /// Records or event payload.
  List<T> get data => List.unmodifiable(_data);

  /// Ob der Store ByKey unterstützt.
  ///
  /// Whether the store supports ByKey.
  @override
  bool get canByKey => keyOf != null;

  /// Ob der Store Insert unterstützt.
  ///
  /// Whether the store supports Insert.
  @override
  bool get canInsert => keyOf != null;

  /// Ob der Store Update unterstützt.
  ///
  /// Whether the store supports Update.
  @override
  bool get canUpdate => keyOf != null;

  /// Ob der Store Remove unterstützt.
  ///
  /// Whether the store supports Remove.
  @override
  bool get canRemove => keyOf != null;

  /// Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben.
  ///
  /// Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate.
  @override
  TxLoadResult<T> load(TxLoadOptions<T> options) => txQuery(_data, options);
  int _index(Object key) {
    if (keyOf == null) throw StateError('keyOf required');
    return _data.indexWhere((v) => keyOf!(v) == key);
  }

  /// Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart).
  ///
  /// Reads a record by key; missing keys return undefined (Vue) or null (Dart).
  @override
  T? byKey(Object key) {
    final i = _index(key);
    return i < 0 ? null : _data[i];
  }

  /// Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück.
  ///
  /// Inserts a record with a unique key and returns it.
  @override
  T insert(T item) {
    if (keyOf == null) throw StateError('keyOf required');
    if (_index(keyOf!(item)) >= 0) throw ArgumentError('Duplicate key');
    _data.add(item);
    return item;
  }

  /// Aktualisiert eine Meldung beziehungsweise einen Datensatz.
  ///
  /// Updates a notification or record.
  @override
  T update(Object key, T Function(T) change) {
    final i = _index(key);
    if (i < 0) throw StateError('Unknown key');
    final next = change(_data[i]);
    if (keyOf!(next) != key) throw ArgumentError('Keys are immutable');
    return _data[i] = next;
  }

  /// Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand.
  ///
  /// Removes the record or recursively removes a file/directory tree.
  @override
  void remove(Object key) {
    final i = _index(key);
    if (i < 0) throw StateError('Unknown key');
    _data.removeAt(i);
  }
}

// Callback names intentionally mirror the public store operations.
// ignore_for_file: prefer_initializing_formals
/// Adapter für eigene synchrone oder asynchrone Store-Callbacks. Nicht angebotene Operationen sind nicht verfügbar.
///
/// load ist erforderlich; byKey/insert/update/remove sind optional. load erhält TxLoadOptions und liefert TxLoadResult direkt oder asynchron. Eigene HTTP-Callbacks müssen Statuscodes prüfen und Fehler weitergeben. byKey liefert undefined/null bei fehlendem Datensatz. Für Paging muss der Store data und totalCount vor Paging liefern. Bei remoteOperations false liefert er alle Rohdaten. Das Beispiel verwendet einen lokalen asynchronen Callback und benötigt keinen Server.
///
/// Adapter for custom synchronous or asynchronous store callbacks. Operations without callbacks are unavailable.
///
/// load is required; byKey/insert/update/remove are optional. load receives TxLoadOptions and returns TxLoadResult directly or asynchronously. Custom HTTP callbacks must check status codes and propagate failures. byKey returns undefined/null for a missing record. For paging, return data and totalCount before paging. With remoteOperations false, return all raw data. The example uses a local async callback and requires no server.
///
/// ```dart
/// final store = TxCustomStore<int>(load: (options) async => txQuery([1, 2], options), byKey: (key) => key == 1 ? 1 : null);
/// print(await store.load(const TxLoadOptions()));
/// ```
class TxCustomStore<T> extends TxStore<T> {
  /// Adapter für eigene synchrone oder asynchrone Store-Callbacks. Nicht angebotene Operationen sind nicht verfügbar.
  ///
  /// Adapter for custom synchronous or asynchronous store callbacks. Operations without callbacks are unavailable.
  TxCustomStore({
    required this._load,
    FutureOr<T?> Function(Object)? byKey,
    this._insert,
    this._update,
    this._remove,
  }) : _byKey = byKey;
  final FutureOr<TxLoadResult<T>> Function(TxLoadOptions<T>) _load;
  final FutureOr<T?> Function(Object)? _byKey;
  final FutureOr<T> Function(T)? _insert;
  final FutureOr<T> Function(Object, T Function(T))? _update;
  final FutureOr<void> Function(Object)? _remove;

  /// Ob der Store ByKey unterstützt.
  ///
  /// Whether the store supports ByKey.
  @override
  bool get canByKey => _byKey != null;

  /// Ob der Store Insert unterstützt.
  ///
  /// Whether the store supports Insert.
  @override
  bool get canInsert => _insert != null;

  /// Ob der Store Update unterstützt.
  ///
  /// Whether the store supports Update.
  @override
  bool get canUpdate => _update != null;

  /// Ob der Store Remove unterstützt.
  ///
  /// Whether the store supports Remove.
  @override
  bool get canRemove => _remove != null;

  /// Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben.
  ///
  /// Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate.
  @override
  FutureOr<TxLoadResult<T>> load(TxLoadOptions<T> options) => _load(options);

  /// Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart).
  ///
  /// Reads a record by key; missing keys return undefined (Vue) or null (Dart).
  @override
  FutureOr<T?> byKey(Object key) =>
      _byKey == null ? super.byKey(key) : _byKey(key);

  /// Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück.
  ///
  /// Inserts a record with a unique key and returns it.
  @override
  FutureOr<T> insert(T item) =>
      _insert == null ? super.insert(item) : _insert(item);

  /// Aktualisiert eine Meldung beziehungsweise einen Datensatz.
  ///
  /// Updates a notification or record.
  @override
  FutureOr<T> update(Object key, T Function(T) change) =>
      _update == null ? super.update(key, change) : _update(key, change);

  /// Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand.
  ///
  /// Removes the record or recursively removes a file/directory tree.
  @override
  FutureOr<void> remove(Object key) =>
      _remove == null ? super.remove(key) : _remove(key);
}

/// Konfiguration für Store, Schlüssel, Abfrage, Paging und lokale oder entfernte Verarbeitung.
///
/// Configuration for the store, keys, query, paging and local or remote processing.
///
/// ```dart
/// final config = TxDataSourceConfig<int>(store: TxArrayStore([1, 2], keyOf: (v) => v), keyOf: (v) => v, pageSize: 10);
/// final source = TxDataSource(config);
/// await source.load();
/// source.dispose();
/// ```
class TxDataSourceConfig<T> {
  /// Konfiguration für Store, Schlüssel, Abfrage, Paging und lokale oder entfernte Verarbeitung.
  ///
  /// Configuration for the store, keys, query, paging and local or remote processing.
  const TxDataSourceConfig({
    required this.store,
    this.keyOf,
    this.sort = const [],
    this.filter,
    this.searchExpr = const [],
    this.searchValue = '',
    this.group = const [],
    this.pageSize = 20,
    this.pageIndex = 0,
    this.paginate = true,
    this.remoteOperations,
    this.select,
    this.map,
    this.requireTotalCount = true,
    this.requireGroupCount = false,
  });

  /// Datenbestand oder eigener Store-Vertrag.
  ///
  /// Data collection or custom store contract.
  final TxStore<T> store;

  /// Liest den stabilen Datensatzschlüssel.
  ///
  /// Reads the stable record key.
  final TxKeyOf<T>? keyOf;

  /// sort: Sortierbeschreibungen in Prioritätsreihenfolge.
  /// group: Gruppierungsbeschreibungen beziehungsweise Gruppenname.
  ///
  /// sort: Sort descriptors in priority order.
  /// group: Group descriptors or group name.
  final List<TxSort<T>> sort, group;

  /// Filterausdruck.
  ///
  /// Filter expression.
  final TxFilter<T>? filter;

  /// Felder beziehungsweise Getter der Suche.
  ///
  /// Search fields or getters.
  final List<TxGetter<T>> searchExpr;

  /// Suchtext, lokal ohne Beachtung der Groß-/Kleinschreibung.
  ///
  /// Search text; local search ignores case.
  final String searchValue;

  /// pageSize: Anzahl Datensätze je Seite.
  /// pageIndex: Nullbasierter Seitenindex.
  ///
  /// pageSize: Records per page.
  /// pageIndex: Zero-based page index.
  final int pageSize, pageIndex;

  /// Aktiviert Paging; false lädt den gesamten Bestand.
  ///
  /// Enables paging; false loads the whole collection.
  final bool paginate;

  /// Store verarbeitet Abfragen selbst; automatisch für CustomStores aktiviert.
  ///
  /// Store handles queries itself; automatically enabled for custom stores.
  final bool? remoteOperations;

  /// select: Projektion vor dem abschließenden Mapping.
  /// map: Transformation jedes geladenen sichtbaren Datensatzes.
  ///
  /// select: Projection before final mapping.
  /// map: Transformation of each loaded visible record.
  final T Function(T)? select, map;

  /// requireTotalCount: Fordert die Gesamtanzahl vor Paging an.
  /// requireGroupCount: Fordert die Anzahl oberster Gruppen an.
  ///
  /// requireTotalCount: Requests the total count before paging.
  /// requireGroupCount: Requests the number of top-level groups.
  final bool requireTotalCount, requireGroupCount;
}

/// Einfüge-, Änderungs- oder Löschoperation für push. Mehrere Operationen laufen nacheinander, ohne Transaktion.
///
/// Insert, update or remove operation for push. Multiple operations run sequentially without a transaction.
///
/// ```dart
/// final source = TxDataSource.array([1], keyOf: (v) => v);
/// await source.push([const TxPush.insert(2), const TxPush.remove(1)]);
/// source.dispose();
/// ```
class TxPush<T> {
  /// Einfüge-, Änderungs- oder Löschoperation für push. Mehrere Operationen laufen nacheinander, ohne Transaktion.
  ///
  /// Insert, update or remove operation for push. Multiple operations run sequentially without a transaction.
  const TxPush.insert(T this.data) : type = 'insert', key = null, change = null;

  /// Einfüge-, Änderungs- oder Löschoperation für push. Mehrere Operationen laufen nacheinander, ohne Transaktion.
  ///
  /// Insert, update or remove operation for push. Multiple operations run sequentially without a transaction.
  const TxPush.update(Object this.key, T Function(T) this.change)
    : type = 'update',
      data = null;

  /// Einfüge-, Änderungs- oder Löschoperation für push. Mehrere Operationen laufen nacheinander, ohne Transaktion.
  ///
  /// Insert, update or remove operation for push. Multiple operations run sequentially without a transaction.
  const TxPush.remove(Object this.key)
    : type = 'remove',
      data = null,
      change = null;

  /// Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur.
  ///
  /// Appearance/input type; see the signature for allowed values.
  final String type;

  /// Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln.
  ///
  /// Stable key or selector; distinct from a widget key.
  final Object? key;

  /// Datensätze beziehungsweise Nutzdaten des Ereignisses.
  ///
  /// Records or event payload.
  final T? data;

  /// Transformation des bestehenden Datensatzes.
  ///
  /// Transformation of the existing record.
  final T Function(T)? change;
}

/// Beobachtbare Datenquelle mit Abfragezustand und asynchronem Laden. Schreiboperationen laden anschließend neu; der Eigentümer entsorgt die Instanz.
///
/// Standardkonfiguration: pageSize 20, pageIndex 0, paginate true; ArrayStore lokal, andere Stores entfernt. Der Vue-Arraykurzaufruf behält Paging bei; Dart TxDataSource.array verwendet paginate false. items startet leer; load() ist erforderlich, sofern kein gebundener Konsument initial lädt. Ungültiges Paging wird abgelehnt. Store und Schlüssel durch eine neue Instanz ersetzen. configure liefert Promise/Future der neu geladenen Liste. byKey liefert Promise/Future des Datensatzes oder undefined/null; insert/update liefern den geschriebenen Datensatz, remove keinen Wert. Vue push liefert die neue Liste, Dart push keinen Wert. cancel/dispose liefern keinen Wert. Lade-/Schreibfehler stehen zusätzlich in error. Bei Stores ohne optionale Operation wirft Vue Error, Dart UnsupportedError. Nach dispose schlägt load fehl.
///
/// Observable data source with query state and asynchronous loading. Writes reload the data; its owner disposes the instance.
///
/// Default configuration: pageSize 20, pageIndex 0, paginate true; array stores are local, other stores remote. The Vue array shorthand retains paging; Dart TxDataSource.array defaults to paginate false. items starts empty; call load() unless a bound consumer triggers the initial load. Invalid paging is rejected. Replace the store and key by creating a new instance. configure returns a Promise/Future of the reloaded list. byKey returns a Promise/Future of a record or undefined/null; insert/update return the written record and remove returns no value. Vue push returns the new list; Dart push returns no value. cancel/dispose return no value. Load/write failures are also exposed in error. For unsupported operations Vue throws Error and Dart throws UnsupportedError. Loading after disposal fails.
///
/// ```dart
/// final source = TxDataSource.array(<Map<String, Object>>[{'id': 1, 'name': 'One'}], keyOf: (row) => row['id']!);
/// void listener() => debugPrint('${source.loading}: ${source.error}');
/// source.addListener(listener);
/// await source.load();
/// await source.configure(searchExpr: [(row) => row['name']], searchValue: 'One');
/// await source.insert({'id': 2, 'name': 'Two'});
/// await source.update(2, (row) => {...row, 'name': 'Updated'});
/// await source.push([TxPush.update(2, (row) => {...row, 'name': 'Changed'})]);
/// print(await source.byKey(1));
/// print(source.containsKey(1));
/// await source.remove(2);
/// await source.reload();
/// source.cancel();
/// source.removeListener(listener);
/// source.dispose();
/// ```
class TxDataSource<T> extends ChangeNotifier {
  /// Beobachtbare Datenquelle mit Abfragezustand und asynchronem Laden. Schreiboperationen laden anschließend neu; der Eigentümer entsorgt die Instanz.
  ///
  /// Observable data source with query state and asynchronous loading. Writes reload the data; its owner disposes the instance.
  TxDataSource(this.config)
    : sort = config.sort,
      filter = config.filter,
      searchExpr = config.searchExpr,
      searchValue = config.searchValue,
      group = config.group,
      pageSize = config.pageSize,
      pageIndex = config.pageIndex {
    if (pageSize < 1 || pageIndex < 0) throw ArgumentError('Invalid paging');
  }

  /// Beobachtbare Datenquelle mit Abfragezustand und asynchronem Laden. Schreiboperationen laden anschließend neu; der Eigentümer entsorgt die Instanz.
  ///
  /// Observable data source with query state and asynchronous loading. Writes reload the data; its owner disposes the instance.
  factory TxDataSource.array(
    List<T> items, {
    TxKeyOf<T>? keyOf,
    bool paginate = false,
  }) => TxDataSource(
    TxDataSourceConfig(
      store: TxArrayStore(items, keyOf: keyOf),
      keyOf: keyOf,
      paginate: paginate,
    ),
  );

  /// Konfiguration der Instanz.
  ///
  /// Instance configuration.
  final TxDataSourceConfig<T> config;

  /// Datenbestand oder eigener Store-Vertrag.
  ///
  /// Data collection or custom store contract.
  TxStore<T> get store => config.store;
  List<T> _items = [];

  /// Einträge; bei Datenbindung durch dataSource ersetzt.
  ///
  /// Entries; replaced by dataSource when bound.
  List<T> get items => List.unmodifiable(_items);

  /// Gruppenhierarchie des Ergebnisses.
  ///
  /// Result group hierarchy.
  List<TxGroup<T>> groups = [];

  /// Gesamtanzahl gefilterter Datensätze vor Paging.
  ///
  /// Total filtered record count before paging.
  int totalCount = 0;

  /// Änderungszähler nach erfolgreichem Laden.
  ///
  /// Revision counter after a successful load.
  int revision = 0;
  final _removedKeys = <Object>{};

  /// Liefert false für bekannte Löschungen, beim ArrayStore einen Wahrheitswert, sonst undefined/null.
  ///
  /// Returns false for known removals, a boolean for an array store, otherwise undefined/null.
  bool? containsKey(Object key) => _removedKeys.contains(key)
      ? false
      : store is TxArrayStore<T> && (store as TxArrayStore<T>).keyOf != null
      ? (store as TxArrayStore<T>).byKey(key) != null
      : null;

  /// Anzahl oberster Gruppen vor Paging.
  ///
  /// Top-level group count before paging.
  int? groupCount;

  /// loading: Zeigt den Ladezustand.
  /// loaded: Mindestens ein Ladevorgang war erfolgreich.
  ///
  /// loading: Shows the loading state.
  /// loaded: At least one load completed successfully.
  bool loading = false, loaded = false, _disposed = false;

  /// Letzter Lade-/Schreibfehler.
  ///
  /// Most recent load/write error.
  Object? error;

  /// sort: Sortierbeschreibungen in Prioritätsreihenfolge.
  /// group: Gruppierungsbeschreibungen beziehungsweise Gruppenname.
  ///
  /// sort: Sort descriptors in priority order.
  /// group: Group descriptors or group name.
  List<TxSort<T>> sort, group;

  /// Filterausdruck.
  ///
  /// Filter expression.
  TxFilter<T>? filter;

  /// Felder beziehungsweise Getter der Suche.
  ///
  /// Search fields or getters.
  List<TxGetter<T>> searchExpr;

  /// Suchtext, lokal ohne Beachtung der Groß-/Kleinschreibung.
  ///
  /// Search text; local search ignores case.
  String searchValue;

  /// pageSize: Anzahl Datensätze je Seite.
  /// pageIndex: Nullbasierter Seitenindex.
  ///
  /// pageSize: Records per page.
  /// pageIndex: Zero-based page index.
  int pageSize, pageIndex;
  int _generation = 0;
  TxCancellation? _cancellation;

  /// Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben.
  ///
  /// Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate.
  Future<List<T>> load() async {
    if (_disposed) throw StateError('DataSource disposed');
    _cancellation?.cancel();
    final generation = ++_generation,
        cancellation = _cancellation = TxCancellation();
    loading = true;
    error = null;
    notifyListeners();
    final options = TxLoadOptions<T>(
      sort: sort,
      filter: filter,
      searchExpr: searchExpr,
      searchValue: searchValue,
      group: group,
      skip: config.paginate ? pageIndex * pageSize : 0,
      take: config.paginate ? pageSize : null,
      select: config.select,
      cancellation: cancellation,
      requireTotalCount: config.requireTotalCount,
      requireGroupCount: config.requireGroupCount,
    );
    try {
      final remote = config.remoteOperations ?? store is! TxArrayStore<T>;
      final raw = await store.load(
        remote || store is TxArrayStore<T>
            ? options
            : TxLoadOptions<T>(cancellation: cancellation),
      );
      if (generation != _generation || cancellation.isCancelled) return items;
      final result = remote || store is TxArrayStore<T>
          ? raw
          : txQuery(raw.data, options);
      _items = config.map == null
          ? List.of(result.data)
          : result.data.map(config.map!).toList();
      groups = result.groups;
      totalCount = result.totalCount ?? result.data.length;
      groupCount = result.groupCount;
      loaded = true;
      revision++;
      return items;
    } catch (e) {
      if (generation == _generation && !cancellation.isCancelled) {
        error = e;
        rethrow;
      }
      return items;
    } finally {
      if (generation == _generation && !_disposed) {
        loading = false;
        notifyListeners();
      }
    }
  }

  /// Lädt den aktuellen Abfragezustand erneut und liefert die sichtbaren Datensätze.
  ///
  /// Reloads the current query and returns visible records.
  Future<List<T>> reload() => load();

  /// Ändert Abfrageoptionen und lädt neu. Suche, Filter und Seitengröße setzen die Seite zurück, sofern nicht ausdrücklich angegeben.
  ///
  /// Changes query options and reloads. Search, filter and page size reset the page unless explicitly supplied.
  Future<List<T>> configure({
    List<TxSort<T>>? sort,
    TxFilter<T>? filter,
    bool clearFilter = false,
    String? searchValue,
    List<TxGetter<T>>? searchExpr,
    List<TxSort<T>>? group,
    int? pageSize,
    int? pageIndex,
  }) {
    if (pageSize != null && pageSize < 1 ||
        pageIndex != null && pageIndex < 0) {
      throw ArgumentError('Invalid paging');
    }
    if (filter != null ||
        clearFilter ||
        searchValue != null ||
        searchExpr != null ||
        pageSize != null) {
      this.pageIndex = 0;
    }
    if (sort != null) this.sort = sort;
    if (filter != null || clearFilter) this.filter = filter;
    if (searchValue != null) this.searchValue = searchValue;
    if (searchExpr != null) this.searchExpr = searchExpr;
    if (group != null) this.group = group;
    if (pageSize != null) this.pageSize = pageSize;
    if (pageIndex != null) this.pageIndex = pageIndex;
    return load();
  }

  /// Synchron auf true setzen, um die Aktion abzubrechen.
  ///
  /// Set synchronously to true to cancel the action.
  void cancel() {
    ++_generation;
    _cancellation?.cancel();
    loading = false;
    if (!_disposed) notifyListeners();
  }

  /// Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart).
  ///
  /// Reads a record by key; missing keys return undefined (Vue) or null (Dart).
  Future<T?> byKey(Object key) async => store.byKey(key);
  Future<R> _write<R>(FutureOr<R> Function() operation) async {
    try {
      final result = await operation();
      await reload();
      return result;
    } catch (e) {
      error = e;
      if (!_disposed) notifyListeners();
      rethrow;
    }
  }

  /// Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück.
  ///
  /// Inserts a record with a unique key and returns it.
  Future<T> insert(T item) => _write(() async {
    final result = await store.insert(item);
    if (config.keyOf != null) _removedKeys.remove(config.keyOf!(result));
    return result;
  });

  /// Aktualisiert eine Meldung beziehungsweise einen Datensatz.
  ///
  /// Updates a notification or record.
  Future<T> update(Object key, T Function(T) change) =>
      _write(() => store.update(key, change));

  /// Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand.
  ///
  /// Removes the record or recursively removes a file/directory tree.
  Future<void> remove(Object key) => _write(() async {
    await store.remove(key);
    _removedKeys.add(key);
  });

  /// Führt Store-Schreiboperationen nacheinander aus und lädt einmal neu; keine Transaktion, Teilerfolg bei Fehler möglich.
  ///
  /// Runs store writes sequentially and reloads once; not a transaction, partial success is possible on error.
  Future<void> push(List<TxPush<T>> changes) => _write(() async {
    for (final c in changes) {
      switch (c.type) {
        case 'insert':
          final result = await store.insert(c.data as T);
          if (config.keyOf != null) _removedKeys.remove(config.keyOf!(result));
        case 'update':
          await store.update(c.key!, c.change!);
        case 'remove':
          await store.remove(c.key!);
          _removedKeys.add(c.key!);
      }
    }
  });

  /// Beendet Abfragen und Listener; danach die Instanz nicht mehr verwenden.
  ///
  /// Stops queries and listeners; do not use the instance afterward.
  @override
  void dispose() {
    cancel();
    _disposed = true;
    super.dispose();
  }
}

/// Lifecycle-Mixin für eigene StatefulWidgets mit Datenbindung. sourceInput implementieren; nur selbst erzeugte Sources werden entsorgt.
///
/// Lifecycle mixin for data-bound StatefulWidgets. Implement sourceInput; only owned sources are disposed.
///
/// ```dart
/// class BoundLabel extends StatefulWidget {
///   const BoundLabel({super.key, required this.source});
///   final Object source;
///   @override
///   State<BoundLabel> createState() => _BoundLabelState();
/// }
///
/// class _BoundLabelState extends State<BoundLabel>
///     with TxSourceState<BoundLabel, String> {
///   @override
///   Object get sourceInput => widget.source;
///   @override
///   Widget build(BuildContext context) => Text(sourceItems.join(', '));
/// }
/// ```
mixin TxSourceState<W extends StatefulWidget, T> on State<W> {
  /// Vom eigenen State implementierte List-/Konfigurations-/Instanzbindung.
  ///
  /// List/configuration/instance binding implemented by a custom State.
  Object? get sourceInput;

  /// Ersatzliste ohne gebundene Source.
  ///
  /// Fallback list without a bound source.
  List<T> get sourceFallback => <T>[];

  /// Aktuell gebundene Source; fremde Instanzen bleiben im Besitz des Aufrufers.
  ///
  /// Currently bound source; borrowed instances remain owned by the caller.
  TxDataSource<T>? boundSource;
  Object? _input;
  bool _owned = false;

  /// Hook nach Änderungen einer gebundenen Source; für eigene States überschreiben.
  ///
  /// Hook after a bound source changes; override in custom states.
  void sourceChanged() {}

  /// Aktuell sichtbare Datensätze der Bindung.
  ///
  /// Currently visible bound records.
  List<T> get sourceItems => sourceInput is List
      ? (sourceInput as List).cast<T>()
      : boundSource?.items ?? sourceFallback;
  void _changed() {
    if (mounted) {
      sourceChanged();
      setState(() {});
    }
  }

  void _bind() {
    if (identical(_input, sourceInput)) return;
    boundSource?.removeListener(_changed);
    if (_owned) boundSource?.dispose();
    _input = sourceInput;
    _owned = _input is TxDataSourceConfig<T>;
    boundSource = _input is TxDataSource<T>
        ? _input as TxDataSource<T>
        : _owned
        ? TxDataSource<T>(_input as TxDataSourceConfig<T>)
        : null;
    if (_input != null && _input is! List && boundSource == null) {
      throw ArgumentError('Expected List, TxDataSourceConfig or TxDataSource');
    }
    boundSource?.addListener(_changed);
    if (boundSource != null && !boundSource!.loaded && !boundSource!.loading) {
      unawaited(
        Future.microtask(() async {
          if (mounted) {
            try {
              await boundSource?.load();
            } catch (_) {
              /* exposed through source.error */
            }
          }
        }),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bind();
  }

  /// Beendet Abfragen und Listener; danach die Instanz nicht mehr verwenden.
  ///
  /// Stops queries and listeners; do not use the instance afterward.
  @override
  void dispose() {
    boundSource?.removeListener(_changed);
    if (_owned) boundSource?.dispose();
    super.dispose();
  }
}

/// Verbindet eigene Widgets mit List, Konfiguration oder DataSource und baut sie bei Änderungen neu.
///
/// Binds custom widgets to a List, configuration or DataSource and rebuilds on changes.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   return TxDataSourceBuilder<String>(
///     dataSource: const ['One'],
///     builder: (context, items, source) => Text(items.join(', ')),
///   );
/// }
/// ```
class TxDataSourceBuilder<T> extends StatefulWidget {
  /// Verbindet eigene Widgets mit List, Konfiguration oder DataSource und baut sie bei Änderungen neu.
  ///
  /// Binds custom widgets to a List, configuration or DataSource and rebuilds on changes.
  const TxDataSourceBuilder({
    super.key,
    required this.dataSource,
    required this.builder,
  });

  /// Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  ///
  /// List, configuration or DataSource instance; takes precedence over items.
  final Object dataSource;

  /// Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.
  ///
  /// Builds custom content; callback arguments and return type are given in the signature.
  final Widget Function(BuildContext, List<T>, TxDataSource<T>?) builder;
  @override
  State<TxDataSourceBuilder<T>> createState() => _TxDataSourceBuilderState<T>();
}

class _TxDataSourceBuilderState<T> extends State<TxDataSourceBuilder<T>>
    with TxSourceState<TxDataSourceBuilder<T>, T> {
  @override
  Object get sourceInput => widget.dataSource;
  @override
  Widget build(BuildContext context) =>
      widget.builder(context, sourceItems, boundSource);
}
