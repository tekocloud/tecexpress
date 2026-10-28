import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'models.dart';

/// Dialog mit Titel und Inhalt. Vorereignisse können synchron abgebrochen werden; externe Sichtbarkeit bleibt maßgeblich.
///
/// Dialog with a title and content. Before-events can be cancelled synchronously; external visibility remains authoritative.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var visible = false;
///   return StatefulBuilder(
///     builder: (context, setState) => Column(
///       mainAxisSize: MainAxisSize.min,
///       children: [
///         TxButton(text: 'Open', onPressed: () => setState(() => visible = true)),
///         TxPopup(
///           visible: visible,
///           onVisibleChanged: (v) => setState(() => visible = v),
///           child: const Text('Hello'),
///         ),
///       ],
///     ),
///   );
/// }
/// ```
class TxPopup extends StatefulWidget {
  /// Dialog mit Titel und Inhalt. Vorereignisse können synchron abgebrochen werden; externe Sichtbarkeit bleibt maßgeblich.
  ///
  /// Dialog with a title and content. Before-events can be cancelled synchronously; external visibility remains authoritative.
  const TxPopup({
    super.key,
    required this.visible,
    required this.child,
    this.title = 'Dialog',
    this.actions = const [],
    this.onVisibleChanged,
    this.onShown,
    this.onHidden,
    this.showCloseButton = true,
    this.hideOnOutsideClick = false,
    this.width = 480,
    this.height,
    this.fullScreen = false,
    this.dragEnabled = false,
    this.resizeEnabled = false,
    this.alignment = Alignment.center,
    this.onShowing,
    this.onHiding,
  });
  /// visible: Steuert die Sichtbarkeit.
  /// showCloseButton: Zeigt die Schließen-Aktion.
  /// hideOnOutsideClick: Erlaubt Schließen über den Außenbereich.
  ///
  /// visible: Controls visibility.
  /// showCloseButton: Shows a close action.
  /// hideOnOutsideClick: Allows closing by clicking outside.
  final bool visible, showCloseButton, hideOnOutsideClick;
  /// Titel der Ansicht.
  ///
  /// View title.
  final String title;
  /// Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln.
  ///
  /// Width; Vue numbers use pixels, Flutter uses logical pixels.
  final double width;
  /// Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln.
  ///
  /// Height; Vue numbers use pixels, Flutter uses logical pixels.
  final double? height;
  /// fullScreen: Füllt den Bildschirm.
  /// dragEnabled: Erlaubt das Verschieben des Dialogs.
  /// resizeEnabled: Erlaubt Größenänderungen des Dialogs.
  ///
  /// fullScreen: Fills the screen.
  /// dragEnabled: Allows dragging the dialog.
  /// resizeEnabled: Allows resizing the dialog.
  final bool fullScreen, dragEnabled, resizeEnabled;
  /// Ausrichtung des Inhalts.
  ///
  /// Content alignment.
  final Alignment alignment;
  /// onShowing: Vor Anzeige: TxChange&lt;bool&gt;; cancel synchron setzen, um abzubrechen.
  /// onHiding: Vor benutzerinitiiertem Schließen: TxChange&lt;bool&gt;; synchron abbrechbar.
  ///
  /// onShowing: Before showing: TxChange&lt;bool&gt;; set cancel synchronously to abort.
  /// onHiding: Before user-initiated closing: TxChange&lt;bool&gt;; synchronously cancellable.
  final ValueChanged<TxChange<bool>>? onShowing, onHiding;
  /// Inhalt beziehungsweise Zielwidget.
  ///
  /// Content or target widget.
  final Widget child;
  /// Aktionen des Dialogs beziehungsweise der Karte.
  ///
  /// Dialog or card actions.
  final List<Widget> actions;
  /// Meldet visible; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports visible; update controlled state in the callback.
  final ValueChanged<bool>? onVisibleChanged;
  /// onShown: Nach Anzeige, ohne Payload.
  /// onHidden: Nach Verbergen, ohne Payload.
  ///
  /// onShown: After showing, without a payload.
  /// onHidden: After hiding, without a payload.
  final VoidCallback? onShown, onHidden;

  /// Öffnet die native Overlay-Alternative; den Rückgabevertrag der jeweiligen Signatur beachten.
  ///
  /// Opens the native overlay alternative; follow the return contract in the signature.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    List<Widget> actions = const [],
    double width = 480,
    bool hideOnOutsideClick = false,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: hideOnOutsideClick,
    builder: (context) => _PopupSurface(
      title: title,
      width: width,
      actions: actions,
      showCloseButton: true,
      child: child,
    ),
  );

  @override
  State<TxPopup> createState() => _TxPopupState();
}

class _TxPopupState extends State<TxPopup> {
  DialogRoute<void>? _route;
  final _revision = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(TxPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedule();
  }

  void _schedule() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    _revision.value++;
    _reconcile();
  });
  void _reconcile() {
    if (!mounted) return;
    if (widget.visible && _route == null) {
      final event = TxChange(true);
      widget.onShowing?.call(event);
      if (event.cancel) return;
      final navigator = Navigator.of(context, rootNavigator: true);
      final route = DialogRoute<void>(
        context: context,
        barrierDismissible: widget.hideOnOutsideClick,
        builder: (_) => ValueListenableBuilder(
          valueListenable: _revision,
          builder: (_, revision, child) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              final event = TxChange(false);
              widget.onHiding?.call(event);
              if (!event.cancel) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: _PopupSurface(
              title: widget.title,
              width: widget.width,
              actions: widget.actions,
              showCloseButton: widget.showCloseButton,
              height: widget.height,
              fullScreen: widget.fullScreen,
              dragEnabled: widget.dragEnabled,
              resizeEnabled: widget.resizeEnabled,
              alignment: widget.alignment,
              child: widget.child,
            ),
          ),
        ),
      );
      _route = route;
      navigator.push(route).then((_) {
        if (!mounted) return;
        if (_route == route) _route = null;
        widget.onVisibleChanged?.call(false);
        widget.onHidden?.call();
      });
      widget.onShown?.call();
    } else if (!widget.visible && _route != null) {
      final route = _route!;
      _route = null;
      route.navigator?.removeRoute(route);
    }
  }

  @override
  void dispose() {
    final route = _route;
    _route = null;
    if (route != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => route.navigator?.removeRoute(route),
      );
    }
    // A route can animate out after this owner leaves the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) => _revision.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _PopupSurface extends StatefulWidget {
  const _PopupSurface({
    required this.title,
    required this.width,
    required this.child,
    required this.actions,
    required this.showCloseButton,
    this.height,
    this.fullScreen = false,
    this.dragEnabled = false,
    this.resizeEnabled = false,
    this.alignment = Alignment.center,
  });
  final String title;
  final double width;
  final Widget child;
  final List<Widget> actions;
  final bool showCloseButton;
  final double? height;
  final bool fullScreen, dragEnabled, resizeEnabled;
  final Alignment alignment;
  @override
  State<_PopupSurface> createState() => _PopupSurfaceState();
}

class _PopupSurfaceState extends State<_PopupSurface> {
  Offset _offset = Offset.zero;
  double? _width, _height;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          Navigator.of(context).maybePop(),
    },
    child: Focus(
      autofocus: true,
      child: Transform.translate(
        offset: _offset,
        child: Dialog(
          alignment: widget.alignment,
          insetPadding: widget.fullScreen
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.fullScreen
                  ? MediaQuery.sizeOf(context).width
                  : _width ?? widget.width,
              maxHeight: widget.fullScreen
                  ? MediaQuery.sizeOf(context).height
                  : _height ??
                        widget.height ??
                        MediaQuery.sizeOf(context).height * .9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: widget.fullScreen
                    ? MediaQuery.sizeOf(context).height - 40
                    : _height ?? widget.height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onPanUpdate: widget.dragEnabled && !widget.fullScreen
                          ? (details) =>
                                setState(() => _offset += details.delta)
                          : null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (widget.showCloseButton)
                            IconButton(
                              tooltip: 'Dialog schließen',
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.close),
                            ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: widget.child,
                        ),
                      ),
                    ),
                    if (widget.actions.isNotEmpty) ...[
                      const Divider(),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.actions,
                      ),
                    ],
                    if (widget.resizeEnabled && !widget.fullScreen)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onPanUpdate: (details) => setState(() {
                            _width =
                                ((_width ?? widget.width) + details.delta.dx)
                                    .clamp(
                                      240,
                                      MediaQuery.sizeOf(context).width - 40,
                                    );
                            _height =
                                ((_height ?? widget.height ?? 320) +
                                        details.delta.dy)
                                    .clamp(
                                      160,
                                      MediaQuery.sizeOf(context).height * .9,
                                    );
                          }),
                          child: const Icon(Icons.open_in_full, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Hinweis zum Zielinhalt mit Verzögerung und optional eigenem Inhalt.
///
/// Hint for target content with a delay and optional custom content.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   return const TxTooltip(text: 'More information', child: Text('Help'));
/// }
/// ```
class TxTooltip extends StatefulWidget {
  /// Hinweis zum Zielinhalt mit Verzögerung und optional eigenem Inhalt.
  ///
  /// Hint for target content with a delay and optional custom content.
  const TxTooltip({
    super.key,
    required this.text,
    required this.child,
    this.disabled = false,
    this.waitDuration = Duration.zero,
    this.showDuration = const Duration(seconds: 3),
    this.preferBelow = false,
    this.triggerMode = TooltipTriggerMode.longPress,
    this.visible,
    this.content,
  });
  /// Anzuzeigender Text.
  ///
  /// Text to display.
  final String text;
  /// Inhalt beziehungsweise Zielwidget.
  ///
  /// Content or target widget.
  final Widget child;
  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;
  /// waitDuration: Wartezeit vor dem Tooltip.
  /// showDuration: Dauer des Tooltips nach Aktivierung.
  ///
  /// waitDuration: Delay before the tooltip.
  /// showDuration: Tooltip duration after activation.
  final Duration waitDuration, showDuration;
  /// Bevorzugt die Position unter dem Ziel.
  ///
  /// Prefers placement below the target.
  final bool preferBelow;
  /// Native Tooltip-Aktivierungsart.
  ///
  /// Native tooltip trigger mode.
  final TooltipTriggerMode triggerMode;
  /// Steuert die Sichtbarkeit.
  ///
  /// Controls visibility.
  final bool? visible;
  /// Eigener Inhalt beziehungsweise Dateiinhalt als Blob.
  ///
  /// Custom content or file contents as a Blob.
  final Widget? content;
  @override
  State<TxTooltip> createState() => _TxTooltipState();
}

class _TxTooltipState extends State<TxTooltip> {
  final _tooltip = GlobalKey<TooltipState>();
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant TxTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.visible == true && !widget.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.visible == true) {
          _tooltip.currentState?.ensureTooltipVisible();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.disabled || widget.visible == false
      ? widget.child
      : Tooltip(
          key: _tooltip,
          message: widget.content == null ? widget.text : null,
          richMessage: widget.content == null
              ? null
              : WidgetSpan(child: widget.content!),
          waitDuration: widget.visible == true
              ? Duration.zero
              : widget.waitDuration,
          showDuration: widget.visible == true
              ? const Duration(days: 365)
              : widget.showDuration,
          preferBelow: widget.preferBelow,
          triggerMode: widget.visible == true
              ? TooltipTriggerMode.manual
              : widget.triggerMode,
          child: widget.child,
        );
}

/// Statusfarben einer Meldung: Info, Erfolg, Warnung oder Fehler.
///
/// Notification status colors: info, success, warning or error.
///
/// ```dart
/// print(TxToastType.values);
/// ```
enum TxToastType { info, success, warning, error }

/// Zeitlich begrenzte Statusmeldung; Sichtbarkeitsänderungen in der Anwendung übernehmen.
///
/// Timed status message; accept visibility changes in the application.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var visible = false;
///   return StatefulBuilder(
///     builder: (context, setState) => Column(
///       mainAxisSize: MainAxisSize.min,
///       children: [
///         TxButton(
///           text: 'Notify',
///           onPressed: () => setState(() => visible = true),
///         ),
///         TxToast(
///           visible: visible,
///           message: 'Saved',
///           onVisibleChanged: (v) => setState(() => visible = v),
///         ),
///       ],
///     ),
///   );
/// }
/// ```
class TxToast extends StatefulWidget {
  /// Zeitlich begrenzte Statusmeldung; Sichtbarkeitsänderungen in der Anwendung übernehmen.
  ///
  /// Timed status message; accept visibility changes in the application.
  const TxToast({
    super.key,
    required this.visible,
    required this.message,
    this.onVisibleChanged,
    this.type = TxToastType.info,
    this.displayTime = const Duration(milliseconds: 3500),
  });
  /// Steuert die Sichtbarkeit.
  ///
  /// Controls visibility.
  final bool visible;
  /// Meldungstext.
  ///
  /// Notification text.
  final String message;
  /// Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur.
  ///
  /// Appearance/input type; see the signature for allowed values.
  final TxToastType type;
  /// Anzeigedauer; 0 beziehungsweise Duration.zero bleibt offen.
  ///
  /// Display duration; 0 or Duration.zero stays open.
  final Duration displayTime;
  /// Meldet visible; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports visible; update controlled state in the callback.
  final ValueChanged<bool>? onVisibleChanged;

  /// Öffnet die native Overlay-Alternative; den Rückgabevertrag der jeweiligen Signatur beachten.
  ///
  /// Opens the native overlay alternative; follow the return contract in the signature.
  static void show(
    BuildContext context,
    String message, {
    TxToastType type = TxToastType.info,
    Duration displayTime = const Duration(milliseconds: 3500),
  }) {
    final tokens = txThemeOf(context);
    final color = switch (type) {
      TxToastType.error => tokens.danger,
      TxToastType.success => tokens.success,
      _ => tokens.accent,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        duration: displayTime > Duration.zero
            ? displayTime
            : const Duration(days: 365),
        showCloseIcon: true,
      ),
    );
  }

  @override
  State<TxToast> createState() => _TxToastState();
}

class _TxToastState extends State<TxToast> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _controller;
  ScaffoldMessengerState? _messenger;
  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(TxToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible ||
        widget.message != oldWidget.message ||
        widget.displayTime != oldWidget.displayTime ||
        widget.type != oldWidget.type) {
      _schedule();
    }
  }

  void _schedule() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    if (_messenger?.mounted == true) _controller?.close();
    _controller = null;
    if (!widget.visible) return;
    final tokens = txThemeOf(context);
    final color = switch (widget.type) {
      TxToastType.error => tokens.danger,
      TxToastType.success => tokens.success,
      _ => tokens.accent,
    };
    _messenger = ScaffoldMessenger.of(context);
    final controller = _messenger!.showSnackBar(
      SnackBar(
        content: Text(widget.message),
        backgroundColor: color,
        showCloseIcon: true,
        duration: widget.displayTime > Duration.zero
            ? widget.displayTime
            : const Duration(days: 365),
      ),
    );
    _controller = controller;
    controller.closed.then((_) {
      if (mounted && _controller == controller) {
        _controller = null;
        widget.onVisibleChanged?.call(false);
      }
    });
  });
  @override
  void dispose() {
    final controller = _controller;
    final messenger = _messenger;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messenger?.mounted == true) controller?.close();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Zugängliche Ladeanzeige mit Beschriftung.
///
/// Accessible loading indicator with a label.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   return const TxLoadIndicator(label: 'Loading');
/// }
/// ```
class TxLoadIndicator extends StatelessWidget {
  /// Zugängliche Ladeanzeige mit Beschriftung.
  ///
  /// Accessible loading indicator with a label.
  const TxLoadIndicator({
    super.key,
    this.visible = true,
    this.label = 'Wird geladen …',
  });
  /// Steuert die Sichtbarkeit.
  ///
  /// Controls visibility.
  final bool visible;
  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String label;
  @override
  Widget build(BuildContext context) => !visible
      ? const SizedBox.shrink()
      : Semantics(
          liveRegion: true,
          label: label,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: MediaQuery.disableAnimationsOf(context)
                    ? const Icon(Icons.hourglass_empty, size: 18)
                    : const CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Flexible(child: Text(label)),
            ],
          ),
        );
}
