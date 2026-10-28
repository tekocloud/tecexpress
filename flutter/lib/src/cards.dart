import 'source.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'data.dart';
import 'editors.dart';
import 'models.dart';
import 'overlays.dart';
import 'theme.dart';

/// Präsentationskarte mit Titel, Medien, Inhalt und Aktionen.
///
/// Presentation card with a title, media, content and actions.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   return const TxCard(
///     title: 'Project',
///     subtitle: 'Active',
///     child: Text('Hello'),
///   );
/// }
/// ```
class TxCard extends StatelessWidget {
  /// Präsentationskarte mit Titel, Medien, Inhalt und Aktionen.
  ///
  /// Presentation card with a title, media, content and actions.
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
  /// title: Titel der Ansicht.
  /// subtitle: Zusätzlicher Untertitel.
  /// imageUrl: Bildadresse der Karte.
  /// semanticLabel: Zugänglicher Name der Karte.
  ///
  /// title: View title.
  /// subtitle: Additional subtitle.
  /// imageUrl: Card image URL.
  /// semanticLabel: Accessible card name.
  final String? title, subtitle, imageUrl, semanticLabel;
  /// Alternativtext des Bildes.
  ///
  /// Image alternative text.
  final String imageAlt;
  /// header: Eigener Kopfbereich.
  /// media: Eigener Medienbereich.
  /// child: Inhalt beziehungsweise Zielwidget.
  /// footer: Eigener Fußbereich.
  ///
  /// header: Custom header.
  /// media: Custom media region.
  /// child: Content or target widget.
  /// footer: Custom footer.
  final Widget? header, media, child, footer;
  /// Aktionen des Dialogs beziehungsweise der Karte.
  ///
  /// Dialog or card actions.
  final List<Widget> actions;
  /// Darstellungsvariante der Karte.
  ///
  /// Card appearance variant.
  final TxCardVariant variant;
  /// Zeigt den Ladezustand.
  ///
  /// Shows the loading state.
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

/// Kartenliste mit Suche, Pagination, Auswahl und eigenen Karteninhalten.
///
/// Card collection with search, paging, selection and custom content.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   final rows = <Map<String, Object>>[
///     {'id': 1, 'name': 'Alex'},
///   ];
///   return TxCardView<Map<String, Object>>(
///     dataSource: rows,
///     keyOf: (row) => row['id']!,
///     titleOf: (row) => '${row['name']}',
///   );
/// }
/// ```
class TxCardView<T> extends StatefulWidget {
  /// Kartenliste mit Suche, Pagination, Auswahl und eigenen Karteninhalten.
  ///
  /// Card collection with search, paging, selection and custom content.
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
  /// Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  ///
  /// List, configuration or DataSource instance; takes precedence over items.
  final Object dataSource;
  /// Liest den stabilen Datensatzschlüssel.
  ///
  /// Reads the stable record key.
  final Object Function(T row) keyOf;
  /// Getter des Kartentitels.
  ///
  /// Card title getter.
  final String Function(T row) titleOf;
  /// subtitleOf: Getter des Kartenuntertitels.
  /// imageOf: Getter der Kartenbildadresse.
  /// imageAltOf: Getter des Bildalternativtexts.
  /// searchTextOf: Getter des durchsuchbaren Kartentexts.
  ///
  /// subtitleOf: Card subtitle getter.
  /// imageOf: Card image URL getter.
  /// imageAltOf: Image alternative text getter.
  /// searchTextOf: Searchable card text getter.
  final String? Function(T row)? subtitleOf, imageOf, imageAltOf, searchTextOf;
  /// Spalten- beziehungsweise Kartenfeldkonfigurationen.
  ///
  /// Column or card field configurations.
  final List<TxCardField<T>> columns;
  /// searchEnabled: Aktiviert die Suche.
  /// loading: Zeigt den Ladezustand.
  /// disabled: Sperrt die Interaktion.
  ///
  /// searchEnabled: Enables searching.
  /// loading: Shows the loading state.
  /// disabled: Disables interaction.
  final bool searchEnabled, loading, disabled;
  /// Anzahl Datensätze je Seite.
  ///
  /// Records per page.
  final int pageSize;
  /// Nullbasierter Seitenindex.
  ///
  /// Zero-based page index.
  final int? pageIndex;
  /// Meldet pageIndex; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports pageIndex; update controlled state in the callback.
  final ValueChanged<int>? onPageIndexChanged;
  /// Auswahlmodus.
  ///
  /// Selection mode.
  final TxSelectionMode selection;
  /// Kontrollierte Menge ausgewählter Kartenschlüssel.
  ///
  /// Controlled set of selected card keys.
  final Set<Object>? selectedCardKeys;
  /// Meldet selectedCardKeys; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports selectedCardKeys; update controlled state in the callback.
  final ValueChanged<Set<Object>>? onSelectedCardKeysChanged;
  /// Meldet selection; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports selection; update controlled state in the callback.
  final ValueChanged<TxSelection<T>>? onSelectionChanged;
  /// Meldet den über die Details-Aktion aktivierten Datensatz.
  ///
  /// Reports the record activated through the details action.
  final ValueChanged<T>? onCardClick;
  /// Meldet search; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports search; update controlled state in the callback.
  final ValueChanged<String>? onSearchChanged;
  /// noDataText: Text bei leerem Datenbestand.
  /// label: Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// noDataText: Text for an empty collection.
  /// label: Label or accessible name.
  final String noDataText, label;
  /// Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.
  ///
  /// Builds custom content; callback arguments and return type are given in the signature.
  final Widget Function(BuildContext context, T row, bool selected)?
  itemBuilder;
  /// mediaBuilder: Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.
  /// contentBuilder: Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.
  /// footerBuilder: Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.
  ///
  /// mediaBuilder: Builds custom content; callback arguments and return type are given in the signature.
  /// contentBuilder: Builds custom content; callback arguments and return type are given in the signature.
  /// footerBuilder: Builds custom content; callback arguments and return type are given in the signature.
  final Widget Function(BuildContext context, T row)? mediaBuilder,
      contentBuilder,
      footerBuilder;
  @override
  State<TxCardView<T>> createState() => _TxCardViewState<T>();
}

class _TxCardViewState<T> extends State<TxCardView<T>>
    with TxSourceState<TxCardView<T>, T> {
  @override
  Object? get sourceInput => widget.dataSource;
  @override
  List<T> get sourceFallback => <T>[];
  @override
  void sourceChanged() {
    if (boundSource?.loading ?? false) return;
    final before = widget.selectedCardKeys ?? _selected, next = _keys;
    if (before.length != next.length || !before.containsAll(next)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _select(next);
      });
    }
  }

  final _searchController = TextEditingController();
  String _search = '';
  int _page = 0;
  Set<Object> _selected = {};
  Set<Object> get _keys {
    if (widget.selection == TxSelectionMode.none) return {};
    final existing = sourceItems.map(widget.keyOf).toSet();
    final keys = (widget.selectedCardKeys ?? _selected)
        .where(
          (key) => boundSource != null
              ? boundSource!.containsKey(key) != false
              : existing.contains(key),
        )
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
        data: sourceItems.where((item) => keys.contains(widget.keyOf(item))),
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
      source
          .configure(
            pageIndex: page,
            searchValue: _search,
            searchExpr: [
              (row) =>
                  widget.searchTextOf?.call(row) ??
                  '${widget.titleOf(row)} ${widget.subtitleOf?.call(row) ?? ''}',
            ],
          )
          .catchError((_) => <T>[]);
    }
  }

  @override
  void didUpdateWidget(covariant TxCardView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageSize != widget.pageSize ||
        oldWidget.searchEnabled != widget.searchEnabled) {
      _page = 0;
    }
    if (oldWidget.pageSize != widget.pageSize) {
      boundSource
          ?.configure(pageSize: widget.pageSize)
          .catchError((_) => <T>[]);
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
    txValidateKeys(sourceItems, widget.keyOf);
    final tokens = txThemeOf(context),
        blocked =
            widget.disabled ||
            widget.loading ||
            (boundSource?.loading ?? false);
    final query = widget.searchEnabled ? _search.trim().toLowerCase() : '';
    final filtered = sourceItems.where((row) {
      final text =
          widget.searchTextOf?.call(row) ??
          '${widget.titleOf(row)} ${widget.subtitleOf?.call(row) ?? ''} ${widget.columns.map((field) => field.valueGetter(row) ?? '').join(' ')}';
      return boundSource != null || text.toLowerCase().contains(query);
    }).toList();
    final pageCount = math.max(
          1,
          ((boundSource?.totalCount ?? filtered.length) /
                  (boundSource?.pageSize ?? widget.pageSize))
              .ceil(),
        ),
        page = (widget.pageIndex ?? boundSource?.pageIndex ?? _page).clamp(
          0,
          pageCount - 1,
        ),
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
                      _pageTo(0, updateQuery: true);
                      widget.onSearchChanged?.call(text);
                    },
                  ),
                ),
              ),
            ),
          if (widget.loading || (boundSource?.loading ?? false))
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
                            .skip(
                              boundSource == null ? page * widget.pageSize : 0,
                            )
                            .take(
                              boundSource == null
                                  ? widget.pageSize
                                  : filtered.length,
                            ))
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
                  '${boundSource?.totalCount ?? filtered.length} Karten${widget.selection != TxSelectionMode.none ? ' · ${keys.length} ausgewählt' : ''}',
              disabled: blocked,
              onChanged: _pageTo,
            ),
          ),
        ],
      ),
    );
  }
}
