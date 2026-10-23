import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'data.dart';
import 'editors.dart';
import 'models.dart';
import 'overlays.dart';
import 'theme.dart';

class TxCard extends StatelessWidget {
  const TxCard({
    super.key,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.imageAlt = '',
    this.header,
    this.media,
    this.child,
    this.actions = const [],
    this.footer,
    this.variant = TxCardVariant.outlined,
    this.loading = false,
    this.semanticLabel,
  });
  final String? title, subtitle, imageUrl, semanticLabel;
  final String imageAlt;
  final Widget? header, media, child, footer;
  final List<Widget> actions;
  final TxCardVariant variant;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    final tokens = txThemeOf(context);
    return Semantics(
      container: true,
      label: semanticLabel ?? title,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: variant == TxCardVariant.elevated ? 8 : 0,
        color: variant == TxCardVariant.filled
            ? tokens.surfaceAlt
            : tokens.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (media != null)
              media!
            else if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                height: 160,
                fit: BoxFit.cover,
                semanticLabel: imageAlt,
                excludeFromSemantics: imageAlt.isEmpty,
                errorBuilder: (_, error, stack) => const SizedBox(
                  height: 100,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            if (header != null ||
                title != null ||
                subtitle != null ||
                actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          header ??
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                Text(
                                  title!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              if (subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    subtitle!,
                                    style: TextStyle(
                                      color: tokens.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                    ),
                    if (actions.isNotEmpty) Wrap(spacing: 4, children: actions),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: loading
                  ? const TxLoadIndicator(label: 'Karte wird geladen …')
                  : child ?? const SizedBox.shrink(),
            ),
            if (footer != null) ...[
              const Divider(height: 1),
              Padding(padding: const EdgeInsets.all(16), child: footer!),
            ],
          ],
        ),
      ),
    );
  }
}

class TxCardView<T> extends StatefulWidget {
  const TxCardView({
    super.key,
    required this.dataSource,
    required this.keyOf,
    required this.titleOf,
    this.subtitleOf,
    this.imageOf,
    this.imageAltOf,
    this.columns = const [],
    this.searchEnabled = true,
    this.searchTextOf,
    this.pageSize = 6,
    this.pageIndex,
    this.onPageIndexChanged,
    this.selection = TxSelectionMode.none,
    this.selectedCardKeys,
    this.onSelectedCardKeysChanged,
    this.onSelectionChanged,
    this.onCardClick,
    this.onSearchChanged,
    this.loading = false,
    this.disabled = false,
    this.noDataText = 'Keine Karten vorhanden.',
    this.label = 'Kartenansicht',
    this.itemBuilder,
    this.mediaBuilder,
    this.contentBuilder,
    this.footerBuilder,
  }) : assert(pageSize > 0);
  final List<T> dataSource;
  final Object Function(T row) keyOf;
  final String Function(T row) titleOf;
  final String? Function(T row)? subtitleOf, imageOf, imageAltOf, searchTextOf;
  final List<TxCardField<T>> columns;
  final bool searchEnabled, loading, disabled;
  final int pageSize;
  final int? pageIndex;
  final ValueChanged<int>? onPageIndexChanged;
  final TxSelectionMode selection;
  final Set<Object>? selectedCardKeys;
  final ValueChanged<Set<Object>>? onSelectedCardKeysChanged;
  final ValueChanged<TxSelection<T>>? onSelectionChanged;
  final ValueChanged<T>? onCardClick;
  final ValueChanged<String>? onSearchChanged;
  final String noDataText, label;
  final Widget Function(BuildContext context, T row, bool selected)?
  itemBuilder;
  final Widget Function(BuildContext context, T row)? mediaBuilder,
      contentBuilder,
      footerBuilder;
  @override
  State<TxCardView<T>> createState() => _TxCardViewState<T>();
}

class _TxCardViewState<T> extends State<TxCardView<T>> {
  final _searchController = TextEditingController();
  String _search = '';
  int _page = 0;
  Set<Object> _selected = {};
  Set<Object> get _keys {
    if (widget.selection == TxSelectionMode.none) return {};
    final existing = widget.dataSource.map(widget.keyOf).toSet();
    final keys = (widget.selectedCardKeys ?? _selected)
        .where(existing.contains)
        .toSet();
    return widget.selection == TxSelectionMode.single && keys.isNotEmpty
        ? {keys.first}
        : keys;
  }

  void _select(Set<Object> keys) {
    setState(() => _selected = keys);
    widget.onSelectedCardKeysChanged?.call(Set.unmodifiable(keys));
    widget.onSelectionChanged?.call(
      TxSelection(
        keys: keys,
        data: widget.dataSource.where(
          (item) => keys.contains(widget.keyOf(item)),
        ),
      ),
    );
  }

  void _pageTo(int page) {
    setState(() => _page = page);
    widget.onPageIndexChanged?.call(page);
  }

  @override
  void didUpdateWidget(covariant TxCardView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageSize != widget.pageSize ||
        oldWidget.searchEnabled != widget.searchEnabled) {
      _page = 0;
    }
    final keys = _keys, before = widget.selectedCardKeys ?? _selected;
    if (before.length != keys.length || !before.containsAll(keys)) {
      _selected = keys;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _select(keys);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    txValidateKeys(widget.dataSource, widget.keyOf);
    final tokens = txThemeOf(context),
        blocked = widget.disabled || widget.loading;
    final query = widget.searchEnabled ? _search.trim().toLowerCase() : '';
    final filtered = widget.dataSource.where((row) {
      final text =
          widget.searchTextOf?.call(row) ??
          '${widget.titleOf(row)} ${widget.subtitleOf?.call(row) ?? ''} ${widget.columns.map((field) => field.valueGetter(row) ?? '').join(' ')}';
      return text.toLowerCase().contains(query);
    }).toList();
    final pageCount = math.max(1, (filtered.length / widget.pageSize).ceil()),
        page = (widget.pageIndex ?? _page).clamp(0, pageCount - 1),
        keys = _keys;
    if (page != (widget.pageIndex ?? _page)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (widget.pageIndex ?? _page) != page) _pageTo(page);
      });
    }
    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.searchEnabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 320,
                  child: TxTextBox(
                    controller: _searchController,
                    label: 'Karten durchsuchen',
                    disabled: blocked,
                    onChanged: (text) {
                      setState(() => _search = text);
                      _pageTo(0);
                      widget.onSearchChanged?.call(text);
                    },
                  ),
                ),
              ),
            ),
          if (widget.loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: TxLoadIndicator(label: 'Karten werden geladen …'),
              ),
            )
          else if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: Text(widget.noDataText)),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final count = math.max(
                  1,
                  ((constraints.maxWidth + 16) / 270).floor(),
                );
                final width = (constraints.maxWidth - (count - 1) * 16) / count;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final row
                        in filtered
                            .skip(page * widget.pageSize)
                            .take(widget.pageSize))
                      SizedBox(
                        width: width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: keys.contains(widget.keyOf(row))
                                  ? tokens.accent
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.selection != TxSelectionMode.none)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Checkbox(
                                    semanticLabel:
                                        'Karte ${widget.titleOf(row)} auswählen',
                                    value: keys.contains(widget.keyOf(row)),
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
                                ),
                              widget.itemBuilder?.call(
                                    context,
                                    row,
                                    keys.contains(widget.keyOf(row)),
                                  ) ??
                                  TxCard(
                                    title: widget.titleOf(row),
                                    subtitle: widget.subtitleOf?.call(row),
                                    imageUrl: widget.imageOf?.call(row),
                                    imageAlt:
                                        widget.imageAltOf?.call(row) ?? '',
                                    media: widget.mediaBuilder?.call(
                                      context,
                                      row,
                                    ),
                                    footer:
                                        widget.footerBuilder?.call(
                                          context,
                                          row,
                                        ) ??
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: TxButton(
                                            text: 'Details →',
                                            disabled: blocked,
                                            onPressed: () =>
                                                widget.onCardClick?.call(row),
                                          ),
                                        ),
                                    child:
                                        widget.contentBuilder?.call(
                                          context,
                                          row,
                                        ) ??
                                        Column(
                                          children: [
                                            for (final field in widget.columns)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                    ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        field.caption,
                                                        style: TextStyle(
                                                          color: tokens.muted,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Flexible(
                                                      child:
                                                          field.builder?.call(
                                                            context,
                                                            row,
                                                            field.valueGetter(
                                                              row,
                                                            ),
                                                          ) ??
                                                          Text(
                                                            '${field.valueGetter(row) ?? ''}',
                                                            textAlign:
                                                                TextAlign.right,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TxPager(
              page: page,
              pageCount: pageCount,
              countText:
                  '${filtered.length} Karten${widget.selection != TxSelectionMode.none ? ' · ${keys.length} ausgewählt' : ''}',
              disabled: blocked,
              onChanged: _pageTo,
            ),
          ),
        ],
      ),
    );
  }
}
