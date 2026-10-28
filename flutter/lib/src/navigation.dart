import 'source.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'editors.dart';
import 'models.dart';

/// Reiternavigation mit optionalem Inhalt des aktiven Reiters.
///
/// Tab navigation with optional content for the active tab.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   return TxTabs(
///     items: const [TxMenuItem('Home'), TxMenuItem('Settings')],
///     builder: (context, index) => Text('Page $index'),
///   );
/// }
/// ```
class TxTabs extends StatefulWidget {
  /// Reiternavigation mit optionalem Inhalt des aktiven Reiters.
  ///
  /// Tab navigation with optional content for the active tab.
  const TxTabs({
    super.key,
    this.items = const [],
    this.dataSource,
    this.selectedIndex,
    this.initialIndex = 0,
    this.onChanged,
    this.builder,
    this.disabled = false,
    this.label = 'Reiter',
    this.orientation = Axis.horizontal,
    this.swipeEnabled = false,
    this.animationEnabled = true,
  });
  /// Einträge; bei Datenbindung durch dataSource ersetzt.
  ///
  /// Entries; replaced by dataSource when bound.
  final List<TxMenuItem> items;
  /// Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  ///
  /// List, configuration or DataSource instance; takes precedence over items.
  final Object? dataSource;
  /// Nullbasierter aktiver Eintrag.
  ///
  /// Zero-based active entry.
  final int? selectedIndex;
  /// Anfänglicher Reiter im unkontrollierten Modus.
  ///
  /// Initial tab in uncontrolled mode.
  final int initialIndex;
  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<int>? onChanged;
  /// Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.
  ///
  /// Builds custom content; callback arguments and return type are given in the signature.
  final Widget Function(BuildContext context, int selectedIndex)? builder;
  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;
  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String label;
  /// Ausrichtung der Reiter.
  ///
  /// Tab orientation.
  final Axis orientation;
  /// swipeEnabled: Erlaubt Reiterwechsel durch Wischen.
  /// animationEnabled: Aktiviert Inhaltsübergänge.
  ///
  /// swipeEnabled: Allows switching tabs by swiping.
  /// animationEnabled: Enables content transitions.
  final bool swipeEnabled, animationEnabled;
  @override
  State<TxTabs> createState() => _TxTabsState();
}

class _TxTabsState extends State<TxTabs>
    with TxSourceState<TxTabs, TxMenuItem> {
  @override
  Object? get sourceInput => widget.dataSource;
  @override
  List<TxMenuItem> get sourceFallback => widget.items;

  late int _index = widget.initialIndex;
  final _focusNodes = <FocusNode>[];
  int get _selected {
    final index = widget.selectedIndex ?? _index;
    return index >= 0 &&
            index < sourceItems.length &&
            !sourceItems[index].disabled
        ? index
        : sourceItems.indexWhere((item) => !item.disabled);
  }

  void _select(int index, {bool focus = false}) {
    if (widget.disabled || sourceItems[index].disabled) return;
    setState(() => _index = index);
    widget.onChanged?.call(index);
    if (focus) _focusNodes[index].requestFocus();
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    while (_focusNodes.length < sourceItems.length) {
      _focusNodes.add(FocusNode());
    }
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: widget.label,
          child: SingleChildScrollView(
            scrollDirection: widget.orientation,
            child: Flex(
              direction: widget.orientation,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(sourceItems.length, (index) {
                return Focus(
                  onKeyEvent: (_, event) {
                    if (event is! KeyDownEvent || widget.disabled) {
                      return KeyEventResult.ignored;
                    }
                    final enabled = List.generate(
                      sourceItems.length,
                      (i) => i,
                    ).where((i) => !sourceItems[i].disabled).toList();
                    if (enabled.isEmpty) return KeyEventResult.ignored;
                    final current = enabled.indexOf(index);
                    int next;
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                        event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      next = enabled[(current + 1) % enabled.length];
                    } else if (event.logicalKey ==
                            LogicalKeyboardKey.arrowLeft ||
                        event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      next =
                          enabled[(current - 1 + enabled.length) %
                              enabled.length];
                    } else if (event.logicalKey == LogicalKeyboardKey.home) {
                      next = enabled.first;
                    } else if (event.logicalKey == LogicalKeyboardKey.end) {
                      next = enabled.last;
                    } else {
                      return KeyEventResult.ignored;
                    }
                    _select(next, focus: true);
                    return KeyEventResult.handled;
                  },
                  child: Semantics(
                    selected: selected == index,
                    child: TextButton(
                      focusNode: _focusNodes[index],
                      onPressed: widget.disabled || sourceItems[index].disabled
                          ? null
                          : () => _select(index),
                      style: selected == index
                          ? TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            )
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (sourceItems[index].icon != null) ...[
                            Icon(sourceItems[index].icon, size: 18),
                            const SizedBox(width: 6),
                          ],
                          Text(sourceItems[index].text),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const Divider(height: 1),
        if (selected >= 0 && widget.builder != null)
          GestureDetector(
            onHorizontalDragEnd: widget.swipeEnabled
                ? (details) {
                    final enabled = List.generate(
                          sourceItems.length,
                          (i) => i,
                        ).where((i) => !sourceItems[i].disabled).toList(),
                        i = selected;
                    final next =
                        enabled.indexOf(i) +
                        ((details.primaryVelocity ?? 0) < 0 ? 1 : -1);
                    if (next >= 0 && next < enabled.length) {
                      _select(enabled[next]);
                    }
                  }
                : null,
            child: AnimatedSwitcher(
              duration:
                  widget.animationEnabled &&
                      !MediaQuery.disableAnimationsOf(context)
                  ? const Duration(milliseconds: 180)
                  : Duration.zero,
              child: Padding(
                key: ValueKey(selected),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: widget.builder!(context, selected),
              ),
            ),
          ),
      ],
    );
  }
}

/// Werkzeugleiste mit Hauptinhalt und nachgestellten Aktionen.
///
/// Toolbar with primary content and trailing actions.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   return TxToolbar(
///     children: [TxButton(text: 'Save', onPressed: () {})],
///     after: const [Text('Ready')],
///   );
/// }
/// ```
class TxToolbar extends StatelessWidget {
  /// Werkzeugleiste mit Hauptinhalt und nachgestellten Aktionen.
  ///
  /// Toolbar with primary content and trailing actions.
  const TxToolbar({
    super.key,
    this.children = const [],
    this.after = const [],
    this.label = 'Werkzeugleiste',
  });
  /// children: Unterfilter beziehungsweise enthaltene Widgets.
  /// after: Nachgestellte Toolbar-Aktionen.
  ///
  /// children: Child filters or contained widgets.
  /// after: Trailing toolbar actions.
  final List<Widget> children, after;
  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
        if (after.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: after,
          ),
      ],
    ),
  );
}

/// Flache Liste von Menüaktionen; verschachtelte Aktionen gehören ins ContextMenu.
///
/// Flat list of menu actions; use ContextMenu for nested actions.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var saved = false;
///   return StatefulBuilder(
///     builder: (context, setState) => TxMenu(
///       items: const [TxMenuItem('Home')],
///       onItemClick: (item, index) => setState(() => saved = true),
///     ),
///   );
/// }
/// ```
class TxMenu extends StatelessWidget {
  /// Flache Liste von Menüaktionen; verschachtelte Aktionen gehören ins ContextMenu.
  ///
  /// Flat list of menu actions; use ContextMenu for nested actions.
  const TxMenu({
    super.key,
    this.items = const [],
    this.dataSource,
    this.onItemClick,
    this.disabled = false,
    this.label = 'Menü',
  });
  /// Einträge; bei Datenbindung durch dataSource ersetzt.
  ///
  /// Entries; replaced by dataSource when bound.
  final List<TxMenuItem> items;
  /// Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  ///
  /// List, configuration or DataSource instance; takes precedence over items.
  final Object? dataSource;
  /// Meldet den aktivierten Eintrag; Parameter gemäß der Callbacksignatur.
  ///
  /// Reports the activated entry; arguments follow the callback signature.
  final void Function(TxMenuItem item, int index)? onItemClick;
  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;
  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String label;
  @override
  Widget build(BuildContext context) => TxDataSourceBuilder<TxMenuItem>(
    dataSource: dataSource ?? items,
    builder: (context, rows, source) => Semantics(
      label: label,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          rows.length,
          (index) => TxButton(
            text: rows[index].text,
            icon: rows[index].icon,
            disabled: disabled || rows[index].disabled,
            onPressed: () => onItemClick?.call(rows[index], index),
          ),
        ),
      ),
    ),
  );
}
