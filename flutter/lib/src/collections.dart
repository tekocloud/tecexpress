import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'source.dart';

class TxRadioGroup<T> extends StatelessWidget {
  const TxRadioGroup({
    super.key,
    this.items = const [],
    this.dataSource,
    this.value,
    this.onChanged,
    this.direction = Axis.vertical,
    this.disabled = false,
    this.label = 'Auswahl',
  });
  final List<TxItem<T>> items;
  final Object? dataSource;
  final T? value;
  final ValueChanged<T>? onChanged;
  final Axis direction;
  final bool disabled;
  final String label;
  @override
  Widget build(BuildContext context) => TxDataSourceBuilder<TxItem<T>>(
    dataSource: dataSource ?? items,
    builder: (context, rows, source) => Semantics(
      label: label,
      child: RadioGroup<T>(
        groupValue: value,
        onChanged: (v) {
          if (!disabled && v != null) onChanged?.call(v);
        },
        child: Flex(
          direction: direction,
          mainAxisSize: MainAxisSize.min,
          children: rows
              .map(
                (item) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<T>(
                      value: item.value,
                      enabled: !disabled && !item.disabled,
                    ),
                    Text(item.text),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

class TxButtonGroup<T> extends StatelessWidget {
  const TxButtonGroup({
    super.key,
    this.items = const [],
    this.dataSource,
    this.values = const {},
    this.onChanged,
    this.onItemClick,
    this.selection = TxSelectionMode.single,
    this.disabled = false,
    this.direction = Axis.horizontal,
  });
  final List<TxItem<T>> items;
  final Object? dataSource;
  final Set<T> values;
  final ValueChanged<Set<T>>? onChanged;
  final ValueChanged<TxItem<T>>? onItemClick;
  final TxSelectionMode selection;
  final bool disabled;
  final Axis direction;
  @override
  Widget build(BuildContext context) => TxDataSourceBuilder<TxItem<T>>(
    dataSource: dataSource ?? items,
    builder: (context, rows, source) => Wrap(
      direction: direction,
      spacing: 4,
      children: rows
          .map(
            (item) => FilterChip(
              avatar: item.icon == null ? null : Icon(item.icon, size: 18),
              label: Text(item.text),
              selected: values.contains(item.value),
              onSelected: disabled || item.disabled
                  ? null
                  : (selected) {
                      onItemClick?.call(item);
                      if (selection != TxSelectionMode.none) {
                        onChanged?.call(
                          selection == TxSelectionMode.single
                              ? {item.value}
                              : selected
                              ? {...values, item.value}
                              : ({...values}..remove(item.value)),
                        );
                      }
                    },
            ),
          )
          .toList(),
    ),
  );
}

class TxLookup<T> extends StatelessWidget {
  const TxLookup({
    super.key,
    this.items = const [],
    this.dataSource,
    this.value,
    this.onChanged,
    this.disabled = false,
    this.label = 'Auswählen',
    this.searchEnabled = true,
  });
  final List<TxItem<T>> items;
  final Object? dataSource;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final bool disabled, searchEnabled;
  final String label;
  @override
  Widget build(BuildContext context) => _TxLookup<T>(
    items: items,
    dataSource: dataSource,
    values: value == null ? {} : {value as T},
    onChanged: (v) => onChanged?.call(v.firstOrNull),
    disabled: disabled,
    label: label,
    searchEnabled: searchEnabled,
  );
}

class TxTagBox<T> extends StatelessWidget {
  const TxTagBox({
    super.key,
    this.items = const [],
    this.dataSource,
    this.values = const {},
    this.onChanged,
    this.disabled = false,
    this.label = 'Auswählen',
    this.maxDisplayedTags = 4,
    this.applyOnConfirm = false,
    this.onCustomItemCreating,
    this.showSelectionControls = true,
  });
  final List<TxItem<T>> items;
  final Object? dataSource;
  final Set<T> values;
  final ValueChanged<Set<T>>? onChanged;
  final bool disabled, applyOnConfirm, showSelectionControls;
  final int maxDisplayedTags;
  final String label;
  final FutureOr<TxItem<T>> Function(String)? onCustomItemCreating;
  @override
  Widget build(BuildContext context) => _TxLookup<T>(
    items: items,
    dataSource: dataSource,
    values: values,
    onChanged: onChanged,
    disabled: disabled,
    label: label,
    multiple: true,
    maxDisplayedTags: maxDisplayedTags,
    applyOnConfirm: applyOnConfirm,
    onCustomItemCreating: onCustomItemCreating,
    showSelectionControls: showSelectionControls,
  );
}

class _TxLookup<T> extends StatefulWidget {
  const _TxLookup({
    required this.items,
    this.dataSource,
    required this.values,
    this.onChanged,
    required this.disabled,
    required this.label,
    this.multiple = false,
    this.searchEnabled = true,
    this.maxDisplayedTags = 4,
    this.applyOnConfirm = false,
    this.onCustomItemCreating,
    this.showSelectionControls = true,
  });
  final List<TxItem<T>> items;
  final Object? dataSource;
  final Set<T> values;
  final ValueChanged<Set<T>>? onChanged;
  final bool disabled,
      multiple,
      searchEnabled,
      applyOnConfirm,
      showSelectionControls;
  final String label;
  final int maxDisplayedTags;
  final FutureOr<TxItem<T>> Function(String)? onCustomItemCreating;
  @override
  State<_TxLookup<T>> createState() => _TxLookupState<T>();
}

class _TxLookupState<T> extends State<_TxLookup<T>>
    with TxSourceState<_TxLookup<T>, TxItem<T>> {
  @override
  Object? get sourceInput => widget.dataSource;
  @override
  List<TxItem<T>> get sourceFallback => widget.items;
  final _custom = <TxItem<T>>[];
  final _resolved = <T, TxItem<T>>{};
  int _resolution = 0;
  @override
  void initState() {
    super.initState();
    unawaited(Future.microtask(_resolve));
  }

  @override
  void didUpdateWidget(covariant _TxLookup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_resolve());
  }

  @override
  void sourceChanged() {
    unawaited(_resolve());
  }

  Future<void> _resolve() async {
    final source = boundSource, generation = ++_resolution;
    if (source == null || !source.store.canByKey) return;
    for (final key in widget.values) {
      if (sourceItems.any((v) => v.value == key) ||
          _resolved.containsKey(key) ||
          key is! Object) {
        continue;
      }
      try {
        final item = await source.byKey(key);
        if (!mounted || generation != _resolution) return;
        if (item != null) setState(() => _resolved[key] = item);
      } catch (_) {
        /* Loading failures remain available on the source. */
      }
    }
  }

  String _caption(T value) =>
      [
        ...sourceItems,
        ..._custom,
        ..._resolved.values,
      ].where((v) => v.value == value).firstOrNull?.text ??
      '$value';
  Future<void> _open() async {
    var search = '', draft = {...widget.values};
    StateSetter? updateSheet;
    BuildContext? sheet;
    void changed() {
      if (sheet?.mounted ?? false) updateSheet?.call(() {});
    }

    boundSource?.addListener(changed);
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, update) {
            sheet = context;
            updateSheet = update;
            final rows = [...sourceItems, ..._custom]
                .where(
                  (v) =>
                      boundSource != null ||
                      v.text.toLowerCase().contains(search.toLowerCase()),
                )
                .toList();
            void select(TxItem<T> item) {
              if (item.disabled) return;
              update(() {
                if (!widget.multiple) {
                  draft = {item.value};
                } else if (!draft.add(item.value)) {
                  draft.remove(item.value);
                }
              });
              if (!widget.applyOnConfirm) {
                widget.onChanged?.call(Set.unmodifiable(draft));
                if (!widget.multiple) Navigator.pop(context);
              }
            }

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .7,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (widget.searchEnabled)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Suchen',
                          ),
                          onChanged: (text) async {
                            update(() => search = text);
                            if (boundSource != null) {
                              try {
                                await boundSource!.configure(
                                  searchValue: text,
                                  searchExpr: [(item) => item.text],
                                );
                              } catch (_) {}
                              if (context.mounted) update(() {});
                            }
                          },
                        ),
                      ),
                    if (boundSource?.loading ?? false)
                      const LinearProgressIndicator(),
                    if (boundSource?.error != null)
                      Text('${boundSource!.error}'),
                    if (widget.multiple && widget.showSelectionControls)
                      TextButton(
                        onPressed: () {
                          update(
                            () => draft = rows
                                .where((v) => !v.disabled)
                                .map((v) => v.value)
                                .toSet(),
                          );
                          if (!widget.applyOnConfirm) {
                            widget.onChanged?.call(draft);
                          }
                        },
                        child: const Text('Alle geladenen auswählen'),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, i) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (rows[i].group != null &&
                                (i == 0 || rows[i - 1].group != rows[i].group))
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Semantics(
                                  header: true,
                                  child: Text(
                                    rows[i].group!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ),
                              ),
                            widget.multiple
                                ? CheckboxListTile(
                                    title: Text(rows[i].text),
                                    value: draft.contains(rows[i].value),
                                    onChanged: rows[i].disabled
                                        ? null
                                        : (_) => select(rows[i]),
                                  )
                                : ListTile(
                                    title: Text(rows[i].text),
                                    selected: draft.contains(rows[i].value),
                                    enabled: !rows[i].disabled,
                                    onTap: () => select(rows[i]),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    if (boundSource != null &&
                        sourceItems.length < boundSource!.totalCount)
                      TextButton(
                        onPressed: () async {
                          try {
                            await boundSource!.configure(
                              pageSize: boundSource!.pageSize + 20,
                            );
                          } catch (_) {}
                          if (context.mounted) update(() {});
                        },
                        child: const Text('Mehr laden'),
                      ),
                    if (widget.onCustomItemCreating != null &&
                        search.trim().isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          final item = await widget.onCustomItemCreating!(
                            search.trim(),
                          );
                          _custom.add(item);
                          if (context.mounted) select(item);
                        },
                        child: Text('„$search“ hinzufügen'),
                      ),
                    if (widget.applyOnConfirm)
                      TextButton(
                        onPressed: () {
                          widget.onChanged?.call(Set.unmodifiable(draft));
                          Navigator.pop(context);
                        },
                        child: const Text('Übernehmen'),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Schließen'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } finally {
      boundSource?.removeListener(changed);
    }
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      if (widget.multiple)
        ...widget.values
            .take(widget.maxDisplayedTags)
            .map(
              (v) => InputChip(
                label: Text(_caption(v)),
                onDeleted: widget.disabled
                    ? null
                    : () =>
                          widget.onChanged?.call({...widget.values}..remove(v)),
              ),
            ),
      if (widget.multiple && widget.values.length > widget.maxDisplayedTags)
        Chip(label: Text('+${widget.values.length - widget.maxDisplayedTags}')),
      OutlinedButton(
        onPressed: widget.disabled ? null : _open,
        child: Text(
          !widget.multiple && widget.values.isNotEmpty
              ? _caption(widget.values.first)
              : widget.label,
        ),
      ),
      if (widget.values.isNotEmpty)
        IconButton(
          tooltip: 'Auswahl leeren',
          onPressed: widget.disabled ? null : () => widget.onChanged?.call({}),
          icon: const Icon(Icons.clear),
        ),
    ],
  );
}

class TxList<T> extends StatefulWidget {
  const TxList({
    super.key,
    this.items = const [],
    this.dataSource,
    required this.textOf,
    required this.keyOf,
    this.itemBuilder,
    this.groupOf,
    this.selectedKeys = const {},
    this.onSelectionChanged,
    this.onItemClick,
    this.onDelete,
    this.onReorder,
    this.selection = TxSelectionMode.none,
    this.searchEnabled = false,
    this.height = 300,
    this.itemExtent,
    this.disabled = false,
  });
  final List<T> items;
  final Object? dataSource;
  final String Function(T) textOf;
  final Object Function(T) keyOf;
  final Widget Function(BuildContext, T)? itemBuilder;
  final String? Function(T)? groupOf;
  final Set<Object> selectedKeys;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final ValueChanged<T>? onItemClick, onDelete;
  final void Function(int, int)? onReorder;
  final TxSelectionMode selection;
  final bool searchEnabled, disabled;
  final double height;
  final double? itemExtent;
  @override
  State<TxList<T>> createState() => _TxListState<T>();
}

class _TxListState<T> extends State<TxList<T>>
    with TxSourceState<TxList<T>, T> {
  @override
  Object? get sourceInput => widget.dataSource;
  @override
  List<T> get sourceFallback => widget.items;
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final rows = sourceItems
        .where(
          (v) =>
              boundSource != null ||
              widget.textOf(v).toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
    Widget row(int i) {
      final item = rows[i],
          key = widget.keyOf(item),
          selected = widget.selectedKeys.contains(key);
      final group = widget.groupOf?.call(item);
      return Column(
        key: ValueKey(key),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (group != null &&
              (i == 0 || widget.groupOf?.call(rows[i - 1]) != group))
            Padding(
              padding: const EdgeInsets.all(8),
              child: Semantics(
                header: true,
                child: Text(
                  group,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ListTile(
            enabled: !widget.disabled,
            selected: selected,
            leading: widget.selection == TxSelectionMode.none
                ? null
                : Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                  ),
            title:
                widget.itemBuilder?.call(context, item) ??
                Text(widget.textOf(item)),
            trailing: widget.onDelete == null
                ? null
                : IconButton(
                    tooltip: 'Löschen',
                    onPressed: widget.disabled
                        ? null
                        : () => widget.onDelete!(item),
                    icon: const Icon(Icons.delete_outline),
                  ),
            onTap: () {
              widget.onItemClick?.call(item);
              if (widget.selection != TxSelectionMode.none) {
                widget.onSelectionChanged?.call(
                  widget.selection == TxSelectionMode.single
                      ? {key}
                      : selected
                      ? ({...widget.selectedKeys}..remove(key))
                      : {...widget.selectedKeys, key},
                );
              }
            },
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.searchEnabled)
          TextField(
            decoration: const InputDecoration(labelText: 'Liste durchsuchen'),
            onChanged: (text) {
              setState(() => _search = text);
              if (boundSource != null) {
                unawaited(
                  boundSource!
                      .configure(searchValue: text, searchExpr: [widget.textOf])
                      .catchError((_) => <T>[]),
                );
              }
            },
          ),
        if (boundSource?.loading ?? false) const LinearProgressIndicator(),
        if (boundSource?.error != null) Text('${boundSource!.error}'),
        SizedBox(
          height: widget.height,
          child: widget.onReorder != null
              ? ReorderableListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, i) => row(i),
                  onReorderItem: (a, b) {
                    if (!widget.disabled) widget.onReorder!(a, b);
                  },
                )
              : ListView.builder(
                  itemCount: rows.length,
                  itemExtent: widget.groupOf == null ? widget.itemExtent : null,
                  itemBuilder: (context, i) => row(i),
                ),
        ),
        if (rows.isEmpty) const Text('Keine Einträge'),
        if (boundSource != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: boundSource!.pageIndex == 0
                    ? null
                    : () => boundSource!
                          .configure(pageIndex: boundSource!.pageIndex - 1)
                          .catchError((_) => <T>[]),
                child: const Text('Zurück'),
              ),
              Text('${boundSource!.totalCount} Einträge'),
              TextButton(
                onPressed:
                    (boundSource!.pageIndex + 1) * boundSource!.pageSize >=
                        boundSource!.totalCount
                    ? null
                    : () => boundSource!
                          .configure(pageIndex: boundSource!.pageIndex + 1)
                          .catchError((_) => <T>[]),
                child: const Text('Weiter'),
              ),
            ],
          ),
      ],
    );
  }
}

class TxGallery<T> extends StatefulWidget {
  const TxGallery({
    super.key,
    this.items = const [],
    this.dataSource,
    required this.itemBuilder,
    this.selectedIndex = 0,
    this.onChanged,
    this.loop = false,
    this.slideshowDelay = Duration.zero,
    this.height = 240,
  });
  final List<T> items;
  final Object? dataSource;
  final Widget Function(BuildContext, T) itemBuilder;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final bool loop;
  final Duration slideshowDelay;
  final double height;
  @override
  State<TxGallery<T>> createState() => _TxGalleryState<T>();
}

class _TxGalleryState<T> extends State<TxGallery<T>>
    with TxSourceState<TxGallery<T>, T> {
  @override
  Object? get sourceInput => widget.dataSource;
  @override
  List<T> get sourceFallback => widget.items;
  late final PageController _controller = PageController(
    initialPage: widget.selectedIndex,
  );
  late int _index = widget.selectedIndex;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (widget.slideshowDelay > Duration.zero) {
      _timer = Timer.periodic(widget.slideshowDelay, (_) {
        if (mounted && !MediaQuery.disableAnimationsOf(context)) {
          _go(_index + 1);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TxGallery<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slideshowDelay != widget.slideshowDelay) _schedule();
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _go(widget.selectedIndex);
    }
  }

  void _go(int index) {
    if (sourceItems.isEmpty || !_controller.hasClients) return;
    final next = widget.loop
        ? index % sourceItems.length
        : index.clamp(0, sourceItems.length - 1);
    _controller.animateToPage(
      next,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: widget.height,
        child: sourceItems.isEmpty
            ? const Center(child: Text('Keine Bilder'))
            : PageView.builder(
                controller: _controller,
                itemCount: sourceItems.length,
                onPageChanged: (i) {
                  setState(() => _index = i);
                  widget.onChanged?.call(i);
                },
                itemBuilder: (context, i) =>
                    widget.itemBuilder(context, sourceItems[i]),
              ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Vorheriges Bild',
            onPressed: () => _go(_index - 1),
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${sourceItems.isEmpty ? 0 : _index + 1} / ${sourceItems.length}',
          ),
          IconButton(
            tooltip: 'Nächstes Bild',
            onPressed: () => _go(_index + 1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    ],
  );
}

class TxAction {
  const TxAction({
    required this.id,
    required this.text,
    this.icon,
    this.disabled = false,
    this.destructive = false,
    this.items = const [],
    this.separator = false,
  });
  final Object id;
  final String text;
  final IconData? icon;
  final bool disabled, destructive, separator;
  final List<TxAction> items;
}

class TxFloatingActionButton extends StatefulWidget {
  const TxFloatingActionButton({
    super.key,
    this.items = const [],
    this.dataSource,
    this.onItemClick,
    this.disabled = false,
    this.icon = Icons.add,
  });
  final List<TxAction> items;
  final Object? dataSource;
  final ValueChanged<TxAction>? onItemClick;
  final bool disabled;
  final IconData icon;
  @override
  State<TxFloatingActionButton> createState() => _TxFloatingActionButtonState();
}

class _TxFloatingActionButtonState extends State<TxFloatingActionButton>
    with TxSourceState<TxFloatingActionButton, TxAction> {
  @override
  Object? get sourceInput => widget.dataSource;
  @override
  List<TxAction> get sourceFallback => widget.items;
  bool _open = false;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (_open)
        ...sourceItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton.icon(
              onPressed: widget.disabled || item.disabled
                  ? null
                  : () {
                      widget.onItemClick?.call(item);
                      setState(() => _open = false);
                    },
              icon: Icon(item.icon ?? Icons.arrow_forward),
              label: Text(item.text),
            ),
          ),
        ),
      FloatingActionButton(
        heroTag: null,
        onPressed: widget.disabled
            ? null
            : () {
                if (sourceItems.length == 1) {
                  if (!sourceItems.first.disabled) {
                    widget.onItemClick?.call(sourceItems.first);
                  }
                } else {
                  setState(() => _open = !_open);
                }
              },
        child: Icon(_open ? Icons.close : widget.icon),
      ),
    ],
  );
}

class TxActionSheet extends StatelessWidget {
  const TxActionSheet({
    super.key,
    this.items = const [],
    this.dataSource,
    this.title,
    this.onItemClick,
    this.cancelText = 'Abbrechen',
  });
  final List<TxAction> items;
  final Object? dataSource;
  final String? title;
  final ValueChanged<TxAction>? onItemClick;
  final String cancelText;
  static Future<TxAction?> show(
    BuildContext context, {
    List<TxAction> items = const [],
    Object? dataSource,
    String? title,
  }) => showModalBottomSheet<TxAction>(
    context: context,
    builder: (context) => TxActionSheet(
      items: items,
      dataSource: dataSource,
      title: title,
      onItemClick: (item) => Navigator.pop(context, item),
    ),
  );
  @override
  Widget build(BuildContext context) => TxDataSourceBuilder<TxAction>(
    dataSource: dataSource ?? items,
    builder: (context, rows, source) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ...rows.map(
            (item) => ListTile(
              enabled: !item.disabled,
              leading: item.icon == null ? null : Icon(item.icon),
              title: Text(
                item.text,
                style: item.destructive
                    ? TextStyle(color: Theme.of(context).colorScheme.error)
                    : null,
              ),
              onTap: () => onItemClick?.call(item),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
        ],
      ),
    ),
  );
}

class TxContextMenu extends StatelessWidget {
  const TxContextMenu({
    super.key,
    required this.child,
    this.items = const [],
    this.dataSource,
    this.onItemClick,
    this.disabled = false,
  });
  final Widget child;
  final List<TxAction> items;
  final Object? dataSource;
  final ValueChanged<TxAction>? onItemClick;
  final bool disabled;
  @override
  Widget build(BuildContext context) => TxDataSourceBuilder<TxAction>(
    dataSource: dataSource ?? items,
    builder: (context, rows, source) {
      Future<void> open(Offset point, List<TxAction> actions) async {
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final chosen = await showMenu<TxAction>(
          context: context,
          position: RelativeRect.fromRect(
            Rect.fromLTWH(point.dx, point.dy, 0, 0),
            Offset.zero & overlay.size,
          ),
          items: actions
              .map<PopupMenuEntry<TxAction>>(
                (item) => item.separator
                    ? const PopupMenuDivider()
                    : PopupMenuItem<TxAction>(
                        value: item,
                        enabled: !item.disabled,
                        child: Row(
                          children: [
                            if (item.icon != null) ...[
                              Icon(item.icon, size: 18),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                '${item.text}${item.items.isNotEmpty ? ' ›' : ''}',
                                style: item.destructive
                                    ? TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
              )
              .toList(),
        );
        if (chosen != null) {
          if (chosen.items.isNotEmpty && context.mounted) {
            await open(point, chosen.items);
          } else {
            onItemClick?.call(chosen);
          }
        }
      }

      return Focus(
        onKeyEvent: (_, event) {
          if (!disabled &&
              event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.contextMenu ||
                  event.logicalKey == LogicalKeyboardKey.f10 &&
                      HardwareKeyboard.instance.isShiftPressed)) {
            final box = context.findRenderObject()! as RenderBox;
            unawaited(open(box.localToGlobal(Offset.zero), rows));
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onSecondaryTapDown: disabled
              ? null
              : (details) => open(details.globalPosition, rows),
          onLongPressStart: disabled
              ? null
              : (details) => open(details.globalPosition, rows),
          child: child,
        ),
      );
    },
  );
}
