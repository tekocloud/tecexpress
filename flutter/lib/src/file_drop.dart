import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'file_api.dart';

/// Package-internal native/browser drop target with Flutter hit-test routing.
class TxFileDropTarget extends StatefulWidget {
  const TxFileDropTarget({
    super.key,
    required this.child,
    required this.onDrop,
    this.enabled = true,
  });
  final Widget child;
  final Future<void> Function(List<TxFile>) onDrop;
  final bool enabled;
  @override
  State<TxFileDropTarget> createState() => _DropState();
}

class _DropState extends State<TxFileDropTarget> {
  static final _states = <_DropState>{};
  static bool _initialized = false;
  static int _serial = 0;
  final _id = ++_serial;
  final _key = GlobalKey();
  RenderBox? get _box => _key.currentContext?.findRenderObject() as RenderBox?;
  @override
  void initState() {
    super.initState();
    _states.add(this);
    if (!_initialized) {
      _initialized = true;
      configureFileDrops(_route);
      WidgetsBinding.instance.addPersistentFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
      });
    }
  }

  static void _route(List<TxFile> files, double x, double y, int view) {
    final hit = HitTestResult();
    WidgetsBinding.instance.hitTestInView(hit, Offset(x, y), view);
    for (final entry in hit.path) {
      for (final state in _states) {
        if (state.mounted &&
            state.widget.enabled &&
            state._box == entry.target) {
          unawaited(
            state.widget.onDrop(files).catchError((Object e, StackTrace s) {
              FlutterError.reportError(
                FlutterErrorDetails(
                  exception: e,
                  stack: s,
                  library: 'tecexpress',
                ),
              );
            }),
          );
          return;
        }
      }
    }
    for (final file in files) {
      unawaited(file.dispose());
    }
  }

  static String _lastTargets = '';
  static void _publish() {
    final targets = <Map<String, Object>>[];
    for (final state in _states) {
      final box = state._box;
      if (!state.mounted ||
          !state.widget.enabled ||
          box == null ||
          !box.attached ||
          !box.hasSize) {
        continue;
      }
      final rect = MatrixUtils.transformRect(
        box.getTransformTo(null),
        Offset.zero & box.size,
      );
      targets.add({
        'id': state._id,
        'viewId': View.of(state.context).viewId,
        'left': rect.left,
        'top': rect.top,
        'right': rect.right,
        'bottom': rect.bottom,
      });
    }
    final signature = targets.toString();
    if (_lastTargets == signature) return;
    _lastTargets = signature;
    unawaited(
      updateFileDropTargets(targets).catchError((Object e) {
        // Widget tests have no native plugin; actual operations still report errors.
        _lastTargets = '';
      }),
    );
  }

  @override
  void dispose() {
    _states.remove(this);
    scheduleMicrotask(_publish);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    key: _key,
    behavior: HitTestBehavior.translucent,
    child: widget.child,
  );
}
