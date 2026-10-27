import 'source.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'data.dart';
import 'models.dart';
import 'overlays.dart';
import 'theme.dart';

class TxDataGrid<T> extends StatefulWidget {
  const TxDataGrid({
    super.key,
    required this.dataSource,
    required this.keyOf,
    required this.columns,
    this.filterRow = true,
    this.pageSize = 10,
    this.pageIndex,
    this.onPageIndexChanged,
    this.selection = TxSelectionMode.none,
    this.selectedRowKeys,
    this.onSelectedRowKeysChanged,
    this.onSelectionChanged,
    this.onRowClick,
    this.onSortChanged,
    this.onFilterChanged,
    this.loading = false,
    this.disabled = false,
    this.noDataText = 'Keine Daten vorhanden.',
    this.label = 'Datentabelle',
  }) : assert(pageSize > 0);
  final Object dataSource;
  final Object Function(T row) keyOf;
  final List<TxColumn<T>> columns;
  final bool filterRow, loading, disabled;
  final int pageSize;
  final int? pageIndex;
  final ValueChanged<int>? onPageIndexChanged;
  final TxSelectionMode selection;
  final Set<Object>? selectedRowKeys;
  final ValueChanged<Set<Object>>? onSelectedRowKeysChanged;
  final ValueChanged<TxSelection<T>>? onSelectionChanged;
  final ValueChanged<T>? onRowClick;
  final void Function(String? field, bool descending)? onSortChanged;
  final ValueChanged<Map<String, String>>? onFilterChanged;
  final String noDataText, label;
  @override
  State<TxDataGrid<T>> createState() => _TxDataGridState<T>();
}

class _TxDataGridState<T> extends State<TxDataGrid<T>>
    with TxSourceState<TxDataGrid<T>, T> {
  @override
  Object? get sourceInput => widget.dataSource;
  @override
  List<T> get sourceFallback => <T>[];
  @override
  void sourceChanged() {
    if (boundSource?.loading ?? false) return;
    final before = widget.selectedRowKeys ?? _selected, next = _keys;
    if (before.length != next.length || !before.containsAll(next)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _select(next);
      });
    }
  }

  final _filters = <String, String>{};
  final _filterControllers = <String, TextEditingController>{};
  Set<Object> _selected = {};
  int _page = 0;
  String? _sort;
  bool _descending = false;
  String _field(TxColumn<T> column) => column.dataField ?? column.caption;
  Set<Object> get _keys {
    final existing = sourceItems.map(widget.keyOf).toSet();
    var keys = (widget.selectedRowKeys ?? _selected)
        .where(
          (key) => boundSource != null
              ? boundSource!.containsKey(key) != false
              : existing.contains(key),
        )
        .toSet();
    if (widget.selection == TxSelectionMode.none) return {};
    if (widget.selection == TxSelectionMode.single && keys.length > 1) {
      keys = {keys.first};
    }
    return keys;
  }

  void _select(Set<Object> keys) {
    setState(() => _selected = keys);
    widget.onSelectedRowKeysChanged?.call(Set.unmodifiable(keys));
    widget.onSelectionChanged?.call(
      TxSelection(
        keys: keys,
        data: sourceItems.where((row) => keys.contains(widget.keyOf(row))),
      ),
    );
  }

  void _pageTo(int page, {bool updateQuery = false}) {
    setState(() => _page = page);
    widget.onPageIndexChanged?.call(page);
    if (boundSource != null) {
      final source = boundSource!;
      if (!updateQuery) {
        source.configure(pageIndex: page).catchError((_) => <T>[]);
        return;
      }
      final column = widget.columns
          .where((v) => _field(v) == _sort)
          .firstOrNull;
      source
          .configure(
            pageIndex: page,
            sort: column == null
                ? []
                : [TxSort<T>(column.valueGetter, desc: _descending)],
            clearFilter: _filters.values.every((v) => v.isEmpty),
            filter: _filters.values.every((v) => v.isEmpty)
                ? null
                : TxFilter<T>.and(
                    widget.columns
                        .where((c) => (_filters[_field(c)] ?? '').isNotEmpty)
                        .map(
                          (c) => TxFilter<T>(
                            c.valueGetter,
                            _filters[_field(c)],
                            operator: TxFilterOperator.contains,
                          ),
                        )
                        .toList(),
                  ),
          )
          .catchError((_) => <T>[]);
    }
  }

  @override
  void didUpdateWidget(covariant TxDataGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageSize != widget.pageSize) {
      _page = 0;
      boundSource
          ?.configure(pageSize: widget.pageSize)
          .catchError((_) => <T>[]);
    }
    final keys = _keys, before = widget.selectedRowKeys ?? _selected;
    if (keys.length != before.length || !keys.containsAll(before)) {
      _selected = keys;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _select(keys);
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _filterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    txValidateKeys(sourceItems, widget.keyOf);
    final tokens = txThemeOf(context),
        blocked =
            widget.disabled ||
            widget.loading ||
            (boundSource?.loading ?? false);
    final columns = widget.columns.where((column) => column.visible).toList();
    if (columns.map(_field).toSet().length != columns.length) {
      throw ArgumentError(
        'Spalten benötigen eindeutige dataField- oder caption-Werte.',
      );
    }
    final indexed = sourceItems
        .asMap()
        .entries
        .where(
          (entry) =>
              boundSource != null ||
              columns.every((column) {
                final query = widget.filterRow && column.allowFiltering
                    ? _filters[_field(column)] ?? ''
                    : '';
                return '${column.valueGetter(entry.value) ?? ''}'
                    .toLowerCase()
                    .contains(query.toLowerCase());
              }),
        )
        .toList();
    final sortColumn = columns
        .where((column) => _field(column) == _sort && column.allowSorting)
        .firstOrNull;
    if (sortColumn != null && boundSource == null) {
      indexed.sort((a, b) {
        final result = txCompare(
          sortColumn.valueGetter(a.value),
          sortColumn.valueGetter(b.value),
        );
        return result == 0
            ? a.key.compareTo(b.key)
            : _descending
            ? -result
            : result;
      });
    }
    final count = math.max(
      1,
      ((boundSource?.totalCount ?? indexed.length) /
              (boundSource?.pageSize ?? widget.pageSize))
          .ceil(),
    );
    final page = (widget.pageIndex ?? boundSource?.pageIndex ?? _page).clamp(
      0,
      count - 1,
    );
    if (page != (widget.pageIndex ?? _page)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (widget.pageIndex ?? _page) != page) _pageTo(page);
      });
    }
    final rows = indexed
        .skip(boundSource == null ? page * widget.pageSize : 0)
        .take(boundSource == null ? widget.pageSize : indexed.length)
        .map((entry) => entry.value)
        .toList();
    final keys = _keys, selectable = widget.selection != TxSelectionMode.none;
    return Semantics(
      label: widget.label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final width = math.max(
                  constraints.maxWidth,
                  columns.fold<double>(
                    selectable ? 60 : 0,
                    (sum, col) => sum + col.width,
                  ),
                );
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    child: Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      columnWidths: {
                        if (selectable) 0: const FixedColumnWidth(60),
                        for (var i = 0; i < columns.length; i++)
                          i + (selectable ? 1 : 0): FlexColumnWidth(
                            columns[i].width,
                          ),
                      },
                      border: TableBorder(
                        horizontalInside: BorderSide(color: tokens.border),
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: tokens.surfaceAlt),
                          children: [
                            if (selectable)
                              widget.selection == TxSelectionMode.multiple
                                  ? Checkbox(
                                      tristate: true,
                                      value:
                                          rows.isEmpty ||
                                              rows.every(
                                                (row) => !keys.contains(
                                                  widget.keyOf(row),
                                                ),
                                              )
                                          ? false
                                          : rows.every(
                                              (row) => keys.contains(
                                                widget.keyOf(row),
                                              ),
                                            )
                                          ? true
                                          : null,
                                      semanticLabel:
                                          'Alle Zeilen dieser Seite auswählen',
                                      onChanged: blocked || rows.isEmpty
                                          ? null
                                          : (checked) {
                                              final next = {...keys};
                                              if (checked == false) {
                                                next.removeAll(
                                                  rows.map(widget.keyOf),
                                                );
                                              } else {
                                                next.addAll(
                                                  rows.map(widget.keyOf),
                                                );
                                              }
                                              _select(next);
                                            },
                                    )
                                  : const SizedBox(height: 48),
                            for (final column in columns)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextButton(
                                  onPressed: blocked || !column.allowSorting
                                      ? null
                                      : () {
                                          setState(() {
                                            if (_sort != _field(column)) {
                                              _sort = _field(column);
                                              _descending = false;
                                            } else if (!_descending) {
                                              _descending = true;
                                            } else {
                                              _sort = null;
                                              _descending = false;
                                            }
                                          });
                                          _pageTo(0, updateQuery: true);
                                          widget.onSortChanged?.call(
                                            _sort,
                                            _descending,
                                          );
                                        },
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(column.caption)),
                                      if (column.allowSorting)
                                        Icon(
                                          _sort == _field(column)
                                              ? _descending
                                                    ? Icons.arrow_downward
                                                    : Icons.arrow_upward
                                              : Icons.unfold_more,
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (widget.filterRow)
                          TableRow(
                            children: [
                              if (selectable) const SizedBox(),
                              for (final column in columns)
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: column.allowFiltering
                                      ? TextField(
                                          controller: _filterControllers
                                              .putIfAbsent(
                                                _field(column),
                                                () => TextEditingController(),
                                              ),
                                          enabled: !blocked,
                                          decoration: InputDecoration(
                                            labelText:
                                                '${column.caption} filtern',
                                            isDense: true,
                                          ),
                                          onChanged: (text) {
                                            setState(
                                              () => _filters[_field(column)] =
                                                  text,
                                            );
                                            _pageTo(0, updateQuery: true);
                                            widget.onFilterChanged?.call(
                                              Map.unmodifiable(_filters),
                                            );
                                          },
                                        )
                                      : const SizedBox(),
                                ),
                            ],
                          ),
                        for (final row in rows)
                          if (!widget.loading)
                            TableRow(
                              decoration: BoxDecoration(
                                color: keys.contains(widget.keyOf(row))
                                    ? tokens.selection
                                    : null,
                              ),
                              children: [
                                if (selectable)
                                  Checkbox(
                                    value: keys.contains(widget.keyOf(row)),
                                    semanticLabel:
                                        'Zeile ${widget.keyOf(row)} auswählen',
                                    onChanged: blocked
                                        ? null
                                        : (checked) {
                                            final next =
                                                widget.selection ==
                                                    TxSelectionMode.single
                                                ? <Object>{}
                                                : {...keys};
                                            if (checked == true) {
                                              next.add(widget.keyOf(row));
                                            } else {
                                              next.remove(widget.keyOf(row));
                                            }
                                            _select(next);
                                          },
                                  ),
                                for (final column in columns)
                                  InkWell(
                                    onTap: blocked || widget.onRowClick == null
                                        ? null
                                        : () => widget.onRowClick!(row),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Align(
                                        alignment: column.alignment,
                                        child:
                                            column.cellBuilder?.call(
                                              context,
                                              row,
                                              column.valueGetter(row),
                                            ) ??
                                            Text(
                                              '${column.valueGetter(row) ?? ''}',
                                            ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (widget.loading || (boundSource?.loading ?? false))
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: TxLoadIndicator()),
              ),
            if (!widget.loading && rows.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text(widget.noDataText)),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TxPager(
                page: page,
                pageCount: count,
                countText:
                    '${boundSource?.totalCount ?? indexed.length} Einträge${selectable ? ' · ${keys.length} ausgewählt' : ''}',
                onChanged: _pageTo,
                disabled: blocked,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
