import 'dart:async';

import 'package:flutter/material.dart';

import 'source.dart';
import 'navigation.dart';
import 'models.dart';
import 'overlays.dart';

class TxTabPanel extends StatelessWidget {
  const TxTabPanel({
    super.key,
    this.items = const [],
    this.dataSource,
    this.selectedIndex,
    this.onChanged,
    required this.builder,
    this.disabled = false,
    this.orientation = Axis.horizontal,
    this.swipeEnabled = false,
    this.animationEnabled = true,
  });
  final List<TxMenuItem> items;
  final Object? dataSource;
  final int? selectedIndex;
  final ValueChanged<int>? onChanged;
  final Widget Function(BuildContext, int) builder;
  final bool disabled;
  final Axis orientation;
  final bool swipeEnabled, animationEnabled;
  @override
  Widget build(BuildContext context) => TxTabs(
    items: items,
    dataSource: dataSource,
    selectedIndex: selectedIndex,
    onChanged: onChanged,
    builder: builder,
    disabled: disabled,
    orientation: orientation,
    swipeEnabled: swipeEnabled,
    animationEnabled: animationEnabled,
  );
}

class TxLoadPanel extends StatefulWidget {
  const TxLoadPanel({
    super.key,
    this.visible,
    this.dataSource,
    this.message = 'Wird geladen …',
    this.delay = Duration.zero,
    this.shading = true,
    this.child,
  });
  final bool? visible;
  final TxDataSource<dynamic>? dataSource;
  final String message;
  final Duration delay;
  final bool shading;
  final Widget? child;
  @override
  State<TxLoadPanel> createState() => _TxLoadPanelState();
}

class _TxLoadPanelState extends State<TxLoadPanel> {
  Timer? _timer;
  bool _shown = false;
  @override
  void initState() {
    super.initState();
    widget.dataSource?.addListener(_changed);
    _update();
  }

  @override
  void didUpdateWidget(covariant TxLoadPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.dataSource?.removeListener(_changed);
    widget.dataSource?.addListener(_changed);
    _update();
  }

  void _changed() {
    if (mounted) setState(_update);
  }

  void _update() {
    _timer?.cancel();
    if (!(widget.visible ?? widget.dataSource?.loading ?? false)) {
      _shown = false;
    } else if (widget.delay == Duration.zero) {
      _shown = true;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _shown = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.dataSource?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = Semantics(
      liveRegion: true,
      label: widget.message,
      child: ColoredBox(
        color: widget.shading ? Colors.black38 : Colors.transparent,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      widget.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return widget.child == null
        ? _shown
              ? overlay
              : const SizedBox.shrink()
        : Stack(
            children: [
              widget.child!,
              if (_shown) Positioned.fill(child: overlay),
            ],
          );
  }
}

class TxNotifyHandle {
  TxNotifyHandle(this.close, this.update);
  final VoidCallback close;
  final void Function({
    String? message,
    TxToastType? type,
    Duration? displayTime,
  })
  update;
}

final _notifyStacks = Expando<Map<Alignment, _NotifyStack>>();

class _NotifyItem {
  _NotifyItem(this.message, this.type, this.actionText, this.onAction);
  String message;
  TxToastType type;
  final String? actionText;
  final VoidCallback? onAction;
  Timer? timer;
  late VoidCallback close;
}

class _NotifyStack {
  _NotifyStack(this.overlay, this.position);
  final OverlayState overlay;
  final Alignment position;
  final items = <_NotifyItem>[];
  late final OverlayEntry entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: SafeArea(
        child: Align(
          alignment: position,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(8),
                          color: switch (item.type) {
                            TxToastType.error => Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                            TxToastType.success => Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            TxToastType.warning => Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
                            _ => Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Semantics(
                                      liveRegion: true,
                                      child: Text(item.message),
                                    ),
                                  ),
                                  if (item.actionText != null)
                                    TextButton(
                                      onPressed: item.onAction,
                                      child: Text(item.actionText!),
                                    ),
                                  IconButton(
                                    tooltip: 'Meldung schließen',
                                    onPressed: item.close,
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

TxNotifyHandle txNotify(
  BuildContext context, {
  required String message,
  TxToastType type = TxToastType.info,
  Duration displayTime = const Duration(milliseconds: 3500),
  Alignment position = Alignment.bottomRight,
  String? actionText,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.of(context),
      groups = _notifyStacks[Overlay.of(context)] ??=
          <Alignment, _NotifyStack>{};
  final fresh = !groups.containsKey(position),
      stack = groups.putIfAbsent(
        position,
        () => _NotifyStack(overlay, position),
      ),
      item = _NotifyItem(message, type, actionText, onAction);
  var closed = false;
  void close() {
    if (closed) return;
    closed = true;
    item.timer?.cancel();
    stack.items.remove(item);
    if (stack.items.isEmpty) {
      groups.remove(position);
      stack.entry.remove();
      stack.entry.dispose();
    } else {
      stack.entry.markNeedsBuild();
    }
  }

  void schedule(Duration duration) {
    item.timer?.cancel();
    if (duration > Duration.zero) item.timer = Timer(duration, close);
  }

  item.close = close;
  stack.items.add(item);
  if (fresh) {
    overlay.insert(stack.entry);
  } else {
    stack.entry.markNeedsBuild();
  }
  schedule(displayTime);
  return TxNotifyHandle(close, ({
    String? message,
    TxToastType? type,
    Duration? displayTime,
  }) {
    if (closed) return;
    item.message = message ?? item.message;
    item.type = type ?? item.type;
    stack.entry.markNeedsBuild();
    if (displayTime != null) schedule(displayTime);
  });
}
