import 'package:flutter/material.dart';

import 'source.dart';

/// Auswahl eines Intervalls mit zwei Grenzen, Schritten und Mindest-/Höchstabstand.
///
/// Select an interval using two bounds, steps and minimum/maximum distances.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var range = const RangeValues(20, 80);
///   return StatefulBuilder(
///     builder: (context, setState) => TxRangeSlider(
///       value: range,
///       onChanged: (v) => setState(() => range = v),
///     ),
///   );
/// }
/// ```
class TxRangeSlider extends StatelessWidget {
  /// Auswahl eines Intervalls mit zwei Grenzen, Schritten und Mindest-/Höchstabstand.
  ///
  /// Select an interval using two bounds, steps and minimum/maximum distances.
  const TxRangeSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.minRange = 0,
    this.maxRange,
    this.disabled = false,
    this.readOnly = false,
    this.format,
    this.label = 'Bereich',
  });

  /// Aktueller Eingabe-/Optionswert.
  ///
  /// Current input/option value.
  final RangeValues value;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<RangeValues>? onChanged;

  /// min: Untere zulässige Grenze.
  /// max: Obere zulässige Grenze.
  /// step: Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden.
  /// minRange: Mindestabstand zwischen den Bereichsgrenzen.
  ///
  /// min: Lower allowed bound.
  /// max: Upper allowed bound.
  /// step: Step size; milliseconds for Vue date ranges.
  /// minRange: Minimum distance between range bounds.
  final double min, max, step, minRange;

  /// Höchstabstand zwischen den Bereichsgrenzen.
  ///
  /// Maximum distance between range bounds.
  final double? maxRange;

  /// disabled: Sperrt die Interaktion.
  /// readOnly: Verhindert Änderungen des Werts.
  ///
  /// disabled: Disables interaction.
  /// readOnly: Prevents value changes.
  final bool disabled, readOnly;

  /// Formatiert Bereichswerte für die Anzeige.
  ///
  /// Formats range values for display.
  final String Function(double)? format;

  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String label;
  @override
  Widget build(BuildContext context) {
    if (max <= min ||
        step <= 0 ||
        minRange < 0 ||
        minRange > max - min ||
        maxRange != null && maxRange! < minRange) {
      throw ArgumentError('Invalid range configuration');
    }
    final current = RangeValues(
      value.start.clamp(min, max),
      value.end.clamp(min, max),
    );
    double snap(double v) =>
        (min + ((v - min) / step).round() * step).clamp(min, max);
    String text(double v) =>
        format?.call(v) ?? v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RangeSlider(
            values: current,
            min: min,
            max: max,
            divisions: ((max - min) / step).round().clamp(1, 100000),
            labels: RangeLabels(text(current.start), text(current.end)),
            semanticFormatterCallback: text,
            onChanged: disabled || readOnly || onChanged == null
                ? null
                : (next) {
                    var a = snap(next.start), b = snap(next.end);
                    final maximum = maxRange ?? max - min;
                    if (a != current.start) {
                      a = a.clamp(
                        (b - maximum).clamp(min, max),
                        (b - minRange).clamp(min, max),
                      );
                    } else {
                      b = b.clamp(
                        (a + minRange).clamp(min, max),
                        (a + maximum).clamp(min, max),
                      );
                    }
                    onChanged?.call(RangeValues(a, b));
                  },
          ),
          if (!disabled && !readOnly && onChanged != null)
            _RangeDrag(
              value: current,
              min: min,
              max: max,
              step: step,
              onChanged: onChanged!,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(text(current.start)), Text(text(current.end))],
          ),
        ],
      ),
    );
  }
}

class _RangeDrag extends StatefulWidget {
  const _RangeDrag({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });
  final RangeValues value;
  final double min, max, step;
  final ValueChanged<RangeValues> onChanged;
  @override
  State<_RangeDrag> createState() => _RangeDragState();
}

class _RangeDragState extends State<_RangeDrag> {
  RangeValues? _initial;
  double _delta = 0;
  void _shift(double delta, RangeValues value) {
    final shift = delta.clamp(widget.min - value.start, widget.max - value.end);
    widget.onChanged(RangeValues(value.start + shift, value.end + shift));
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Ausgewählten Bereich verschieben',
    onIncrease: () => _shift(widget.step, widget.value),
    onDecrease: () => _shift(-widget.step, widget.value),
    child: LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          _initial = widget.value;
          _delta = 0;
        },
        onPanUpdate: (details) {
          _delta += details.delta.dx;
          final span = widget.max - widget.min,
              delta =
                  (_delta / constraints.maxWidth * span / widget.step).round() *
                  widget.step;
          _shift(delta, _initial ?? widget.value);
        },
        child: SizedBox(
          height: 16,
          child: Stack(
            children: [
              Positioned(
                left:
                    (widget.value.start - widget.min) /
                    (widget.max - widget.min) *
                    constraints.maxWidth,
                right:
                    (widget.max - widget.value.end) /
                    (widget.max - widget.min) *
                    constraints.maxWidth,
                top: 5,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Intervallauswahl über einer einfachen Flächen-, Linien- oder Balkenserie.
///
/// Interval selection over a simple area, line or bar series.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var range = const RangeValues(20, 80);
///   return StatefulBuilder(
///     builder: (context, setState) => TxRangeSelector<double>(
///       value: range,
///       min: 0,
///       max: 100,
///       items: const [20, 80],
///       argumentOf: (v) => v,
///       valueOf: (v) => v / 2,
///       onChanged: (v) => setState(() => range = v),
///     ),
///   );
/// }
/// ```
class TxRangeSelector<T> extends StatelessWidget {
  /// Intervallauswahl über einer einfachen Flächen-, Linien- oder Balkenserie.
  ///
  /// Interval selection over a simple area, line or bar series.
  factory TxRangeSelector.date({
    Key? key,
    required DateTimeRange value,
    required DateTime min,
    required DateTime max,
    Duration step = const Duration(days: 1),
    ValueChanged<DateTimeRange>? onChanged,
    List<T> items = const [],
    Object? dataSource,
    required DateTime Function(T) argumentOf,
    required double Function(T) valueOf,
    String Function(DateTime)? format,
    String seriesType = 'area',
    bool disabled = false,
  }) => TxRangeSelector<T>(
    key: key,
    value: RangeValues(
      value.start.millisecondsSinceEpoch.toDouble(),
      value.end.millisecondsSinceEpoch.toDouble(),
    ),
    min: min.millisecondsSinceEpoch.toDouble(),
    max: max.millisecondsSinceEpoch.toDouble(),
    step: step.inMilliseconds.toDouble(),
    onChanged: onChanged == null
        ? null
        : (v) => onChanged(
            DateTimeRange(
              start: DateTime.fromMillisecondsSinceEpoch(v.start.round()),
              end: DateTime.fromMillisecondsSinceEpoch(v.end.round()),
            ),
          ),
    items: items,
    dataSource: dataSource,
    argumentOf: (v) => argumentOf(v).millisecondsSinceEpoch.toDouble(),
    valueOf: valueOf,
    format: (v) {
      final date = DateTime.fromMillisecondsSinceEpoch(v.round());
      return format?.call(date) ?? '${date.day}.${date.month}.${date.year}';
    },
    seriesType: seriesType,
    disabled: disabled,
  );

  /// Intervallauswahl über einer einfachen Flächen-, Linien- oder Balkenserie.
  ///
  /// Interval selection over a simple area, line or bar series.
  const TxRangeSelector({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    this.onChanged,
    this.items = const [],
    this.dataSource,
    required this.argumentOf,
    required this.valueOf,
    this.format,
    this.seriesType = 'area',
    this.disabled = false,
  });

  /// Aktueller Eingabe-/Optionswert.
  ///
  /// Current input/option value.
  final RangeValues value;

  /// min: Untere zulässige Grenze.
  /// max: Obere zulässige Grenze.
  /// step: Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden.
  ///
  /// min: Lower allowed bound.
  /// max: Upper allowed bound.
  /// step: Step size; milliseconds for Vue date ranges.
  final double min, max, step;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<RangeValues>? onChanged;

  /// Einträge; bei Datenbindung durch dataSource ersetzt.
  ///
  /// Entries; replaced by dataSource when bound.
  final List<T> items;

  /// Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  ///
  /// List, configuration or DataSource instance; takes precedence over items.
  final Object? dataSource;

  /// argumentOf: Getter der numerischen oder zeitlichen X-Achse.
  /// valueOf: Getter des numerischen Serienwerts.
  ///
  /// argumentOf: Getter for the numeric or date X axis.
  /// valueOf: Getter for the numeric series value.
  final double Function(T) argumentOf, valueOf;

  /// Formatiert Bereichswerte für die Anzeige.
  ///
  /// Formats range values for display.
  final String Function(double)? format;

  /// Seriendarstellung area/line/bar.
  ///
  /// Series appearance: area/line/bar.
  final String seriesType;

  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;
  @override
  Widget build(BuildContext context) => TxDataSourceBuilder<T>(
    dataSource: dataSource ?? items,
    builder: (context, rows, source) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          width: double.infinity,
          child: CustomPaint(
            painter: _RangePainter(
              rows.map((v) => Offset(argumentOf(v), valueOf(v))).toList(),
              min,
              max,
              Theme.of(context).colorScheme.primary,
              seriesType,
            ),
          ),
        ),
        TxRangeSlider(
          value: value,
          min: min,
          max: max,
          step: step,
          onChanged: onChanged,
          disabled: disabled,
          format: format,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final value = min + (max - min) * i / 4;
            return Text(
              format?.call(value) ?? value.toStringAsFixed(0),
              style: Theme.of(context).textTheme.bodySmall,
            );
          }),
        ),
      ],
    ),
  );
}

class _RangePainter extends CustomPainter {
  _RangePainter(this.points, this.min, this.max, this.color, this.type);
  final List<Offset> points;
  final double min, max;
  final Color color;
  final String type;
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || max <= min) return;
    final high = points.fold<double>(1, (v, p) => p.dy > v ? p.dy : v);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (points[i].dx - min) / (max - min) * size.width,
          y = size.height - points[i].dy / high * size.height;
      if (type == 'bar') {
        canvas.drawRect(
          Rect.fromLTWH(x, y, size.width / points.length * .8, size.height - y),
          Paint()..color = color,
        );
      } else if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    if (type == 'bar') return;
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (type == 'area') {
      path.lineTo(
        (points.last.dx - min) / (max - min) * size.width,
        size.height,
      );
      path.lineTo(
        (points.first.dx - min) / (max - min) * size.width,
        size.height,
      );
      path.close();
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: .2));
    }
  }

  @override
  bool shouldRepaint(covariant _RangePainter oldDelegate) => true;
}
