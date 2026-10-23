import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'editors.dart';
import 'models.dart';

class TxTabs extends StatefulWidget {
  const TxTabs({
    super.key,
    required this.items,
    this.selectedIndex,
    this.initialIndex = 0,
    this.onChanged,
    this.builder,
    this.disabled = false,
    this.label = 'Reiter',
  });
  final List<TxMenuItem> items;
  final int? selectedIndex;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final Widget Function(BuildContext context, int selectedIndex)? builder;
  final bool disabled;
  final String label;
  @override
  State<TxTabs> createState() => _TxTabsState();
}

class _TxTabsState extends State<TxTabs> {
  late int _index = widget.initialIndex;
  final _focusNodes = <FocusNode>[];
  int get _selected {
    final index = widget.selectedIndex ?? _index;
    return index >= 0 &&
            index < widget.items.length &&
            !widget.items[index].disabled
        ? index
        : widget.items.indexWhere((item) => !item.disabled);
  }

  void _select(int index, {bool focus = false}) {
    if (widget.disabled || widget.items[index].disabled) return;
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
    while (_focusNodes.length < widget.items.length) {
      _focusNodes.add(FocusNode());
    }
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: widget.label,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.items.length, (index) {
                return Focus(
                  onKeyEvent: (_, event) {
                    if (event is! KeyDownEvent || widget.disabled) {
                      return KeyEventResult.ignored;
                    }
                    final enabled = List.generate(
                      widget.items.length,
                      (i) => i,
                    ).where((i) => !widget.items[i].disabled).toList();
                    if (enabled.isEmpty) return KeyEventResult.ignored;
                    final current = enabled.indexOf(index);
                    int next;
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      next = enabled[(current + 1) % enabled.length];
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowLeft) {
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
                      onPressed: widget.disabled || widget.items[index].disabled
                          ? null
                          : () => _select(index),
                      style: selected == index
                          ? TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            )
                          : null,
                      child: Text(widget.items[index].text),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const Divider(height: 1),
        if (selected >= 0 && widget.builder != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: widget.builder!(context, selected),
          ),
      ],
    );
  }
}

class TxToolbar extends StatelessWidget {
  const TxToolbar({
    super.key,
    this.children = const [],
    this.after = const [],
    this.label = 'Werkzeugleiste',
  });
  final List<Widget> children, after;
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

class TxMenu extends StatelessWidget {
  const TxMenu({
    super.key,
    required this.items,
    this.onItemClick,
    this.disabled = false,
    this.label = 'Menü',
  });
  final List<TxMenuItem> items;
  final void Function(TxMenuItem item, int index)? onItemClick;
  final bool disabled;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        items.length,
        (index) => TxButton(
          text: items[index].text,
          icon: items[index].icon,
          disabled: disabled || items[index].disabled,
          onPressed: () => onItemClick?.call(items[index], index),
        ),
      ),
    ),
  );
}
