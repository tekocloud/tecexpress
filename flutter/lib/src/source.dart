import 'dart:async';

import 'package:flutter/widgets.dart';

typedef TxKeyOf<T> = Object Function(T item);
typedef TxGetter<T> = Object? Function(T item);

class TxSort<T> {
  const TxSort(this.selector, {this.desc = false});
  final TxGetter<T> selector;
  final bool desc;
}

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

class TxFilter<T> {
  const TxFilter(
    this.selector,
    this.value, {
    this.operator = TxFilterOperator.equal,
  }) : children = null,
       junction = null;
  const TxFilter.and(List<TxFilter<T>> filters)
    : selector = null,
      value = null,
      operator = TxFilterOperator.equal,
      children = filters,
      junction = 'and';
  const TxFilter.or(List<TxFilter<T>> filters)
    : selector = null,
      value = null,
      operator = TxFilterOperator.equal,
      children = filters,
      junction = 'or';
  TxFilter.not(TxFilter<T> filter)
    : selector = null,
      value = null,
      operator = TxFilterOperator.equal,
      children = [filter],
      junction = 'not';
  final TxGetter<T>? selector;
  final Object? value;
  final TxFilterOperator operator;
  final List<TxFilter<T>>? children;
  final String? junction;
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

int txSourceCompare(Object? a, Object? b) {
  if (a == null) return b == null ? 0 : -1;
  if (b == null) return 1;
  if (a is num && b is num) return a.compareTo(b);
  if (a is DateTime && b is DateTime) return a.compareTo(b);
  return '$a'.toLowerCase().compareTo('$b'.toLowerCase());
}

class TxCancellation {
  bool isCancelled = false;
  final _listeners = <VoidCallback>[];
  void cancel() {
    if (isCancelled) return;
    isCancelled = true;
    for (final listener in [..._listeners]) {
      listener();
    }
    _listeners.clear();
  }

  VoidCallback onCancel(VoidCallback listener) {
    if (isCancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
    return () => _listeners.remove(listener);
  }

  void throwIfCancelled() {
    if (isCancelled) throw StateError('Operation cancelled');
  }
}

class TxLoadOptions<T> {
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
  final List<TxSort<T>> sort, group;
  final TxFilter<T>? filter;
  final List<TxGetter<T>> searchExpr;
  final String searchValue;
  final int skip;
  final int? take;
  final T Function(T)? select;
  final bool requireTotalCount, requireGroupCount;
  final TxCancellation? cancellation;
}

class TxGroup<T> {
  const TxGroup({
    required this.key,
    required this.items,
    required this.count,
    this.groups = const [],
  });
  final Object? key;
  final List<T> items;
  final int count;
  final List<TxGroup<T>> groups;
}

class TxLoadResult<T> {
  const TxLoadResult({
    required this.data,
    this.totalCount,
    this.groups = const [],
    this.groupCount,
  });
  final List<T> data;
  final int? totalCount, groupCount;
  final List<TxGroup<T>> groups;
}

abstract class TxStore<T> {
  FutureOr<TxLoadResult<T>> load(TxLoadOptions<T> options);
  bool get canInsert => false;
  bool get canUpdate => false;
  bool get canRemove => false;
  bool get canByKey => false;
  FutureOr<T?> byKey(Object key) => throw UnsupportedError('byKey');
  FutureOr<T> insert(T item) => throw UnsupportedError('insert');
  FutureOr<T> update(Object key, T Function(T) change) =>
      throw UnsupportedError('update');
  FutureOr<void> remove(Object key) => throw UnsupportedError('remove');
}

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

class TxArrayStore<T> extends TxStore<T> {
  TxArrayStore(List<T> data, {this.keyOf}) : _data = List.of(data) {
    if (keyOf != null && _data.map(keyOf!).toSet().length != _data.length) {
      throw ArgumentError('Duplicate keys');
    }
  }
  final List<T> _data;
  final TxKeyOf<T>? keyOf;
  List<T> get data => List.unmodifiable(_data);
  @override
  bool get canByKey => keyOf != null;
  @override
  bool get canInsert => keyOf != null;
  @override
  bool get canUpdate => keyOf != null;
  @override
  bool get canRemove => keyOf != null;
  @override
  TxLoadResult<T> load(TxLoadOptions<T> options) => txQuery(_data, options);
  int _index(Object key) {
    if (keyOf == null) throw StateError('keyOf required');
    return _data.indexWhere((v) => keyOf!(v) == key);
  }

  @override
  T? byKey(Object key) {
    final i = _index(key);
    return i < 0 ? null : _data[i];
  }

  @override
  T insert(T item) {
    if (keyOf == null) throw StateError('keyOf required');
    if (_index(keyOf!(item)) >= 0) throw ArgumentError('Duplicate key');
    _data.add(item);
    return item;
  }

  @override
  T update(Object key, T Function(T) change) {
    final i = _index(key);
    if (i < 0) throw StateError('Unknown key');
    final next = change(_data[i]);
    if (keyOf!(next) != key) throw ArgumentError('Keys are immutable');
    return _data[i] = next;
  }

  @override
  void remove(Object key) {
    final i = _index(key);
    if (i < 0) throw StateError('Unknown key');
    _data.removeAt(i);
  }
}

// Callback names intentionally mirror the public store operations.
// ignore_for_file: prefer_initializing_formals
class TxCustomStore<T> extends TxStore<T> {
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
  @override
  bool get canByKey => _byKey != null;
  @override
  bool get canInsert => _insert != null;
  @override
  bool get canUpdate => _update != null;
  @override
  bool get canRemove => _remove != null;
  @override
  FutureOr<TxLoadResult<T>> load(TxLoadOptions<T> options) => _load(options);
  @override
  FutureOr<T?> byKey(Object key) =>
      _byKey == null ? super.byKey(key) : _byKey(key);
  @override
  FutureOr<T> insert(T item) =>
      _insert == null ? super.insert(item) : _insert(item);
  @override
  FutureOr<T> update(Object key, T Function(T) change) =>
      _update == null ? super.update(key, change) : _update(key, change);
  @override
  FutureOr<void> remove(Object key) =>
      _remove == null ? super.remove(key) : _remove(key);
}

class TxDataSourceConfig<T> {
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
  final TxStore<T> store;
  final TxKeyOf<T>? keyOf;
  final List<TxSort<T>> sort, group;
  final TxFilter<T>? filter;
  final List<TxGetter<T>> searchExpr;
  final String searchValue;
  final int pageSize, pageIndex;
  final bool paginate;
  final bool? remoteOperations;
  final T Function(T)? select, map;
  final bool requireTotalCount, requireGroupCount;
}

class TxPush<T> {
  const TxPush.insert(T this.data) : type = 'insert', key = null, change = null;
  const TxPush.update(Object this.key, T Function(T) this.change)
    : type = 'update',
      data = null;
  const TxPush.remove(Object this.key)
    : type = 'remove',
      data = null,
      change = null;
  final String type;
  final Object? key;
  final T? data;
  final T Function(T)? change;
}

class TxDataSource<T> extends ChangeNotifier {
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
  final TxDataSourceConfig<T> config;
  TxStore<T> get store => config.store;
  List<T> _items = [];
  List<T> get items => List.unmodifiable(_items);
  List<TxGroup<T>> groups = [];
  int totalCount = 0;
  int revision = 0;
  final _removedKeys = <Object>{};
  bool? containsKey(Object key) => _removedKeys.contains(key)
      ? false
      : store is TxArrayStore<T> && (store as TxArrayStore<T>).keyOf != null
      ? (store as TxArrayStore<T>).byKey(key) != null
      : null;
  int? groupCount;
  bool loading = false, loaded = false, _disposed = false;
  Object? error;
  List<TxSort<T>> sort, group;
  TxFilter<T>? filter;
  List<TxGetter<T>> searchExpr;
  String searchValue;
  int pageSize, pageIndex;
  int _generation = 0;
  TxCancellation? _cancellation;
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

  Future<List<T>> reload() => load();
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

  void cancel() {
    ++_generation;
    _cancellation?.cancel();
    loading = false;
    if (!_disposed) notifyListeners();
  }

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

  Future<T> insert(T item) => _write(() async {
    final result = await store.insert(item);
    if (config.keyOf != null) _removedKeys.remove(config.keyOf!(result));
    return result;
  });
  Future<T> update(Object key, T Function(T) change) =>
      _write(() => store.update(key, change));
  Future<void> remove(Object key) => _write(() async {
    await store.remove(key);
    _removedKeys.add(key);
  });
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

  @override
  void dispose() {
    cancel();
    _disposed = true;
    super.dispose();
  }
}

/// Lifecycle bridge used by every data-bound StatefulWidget. Only owned sources are disposed.
mixin TxSourceState<W extends StatefulWidget, T> on State<W> {
  Object? get sourceInput;
  List<T> get sourceFallback => <T>[];
  TxDataSource<T>? boundSource;
  Object? _input;
  bool _owned = false;
  void sourceChanged() {}
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

  @override
  void dispose() {
    boundSource?.removeListener(_changed);
    if (_owned) boundSource?.dispose();
    super.dispose();
  }
}

class TxDataSourceBuilder<T> extends StatefulWidget {
  const TxDataSourceBuilder({
    super.key,
    required this.dataSource,
    required this.builder,
  });
  final Object dataSource;
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
