import 'source.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'theme.dart';

/// Schaltfläche mit Text, Symbol und Klickaktion.
///
/// Button with text, an icon and a click action.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var saved = false;
///   return StatefulBuilder(
///     builder: (context, setState) =>
///         TxButton(text: 'Save', onPressed: () => setState(() => saved = true)),
///   );
/// }
/// ```
class TxButton extends StatelessWidget {
  /// Schaltfläche mit Text, Symbol und Klickaktion.
  ///
  /// Button with text, an icon and a click action.
  const TxButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.disabled = false,
    this.type = TxButtonType.normal,
    this.icon,
  });

  /// Anzuzeigender Text.
  ///
  /// Text to display.
  final String? text;

  /// Inhalt beziehungsweise Zielwidget.
  ///
  /// Content or target widget.
  final Widget? child;

  /// Callback für pressed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for pressed; see the signature for arguments and return type.
  final VoidCallback? onPressed;

  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;

  /// Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur.
  ///
  /// Appearance/input type; see the signature for allowed values.
  final TxButtonType type;

  /// Symbol der Aktion.
  ///
  /// Action icon.
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final tokens = txThemeOf(context);
    final color = switch (type) {
      TxButtonType.danger => tokens.danger,
      TxButtonType.success => tokens.success,
      _ => tokens.accent,
    };
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          SizedBox(width: tokens.spacing),
        ],
        Flexible(child: child ?? Text(text ?? '')),
      ],
    );
    final callback = disabled ? null : onPressed;
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, tokens.controlHeight)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
        ),
      ),
    );
    return type == TxButtonType.primary
        ? FilledButton(onPressed: callback, style: style, child: content)
        : OutlinedButton(
            onPressed: callback,
            style: style.copyWith(
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? null
                    : (type == TxButtonType.normal ? tokens.text : color),
              ),
            ),
            child: content,
          );
  }
}

InputDecoration _decoration({
  String? label,
  String? placeholder,
  bool required = false,
  bool isValid = true,
  String validationMessage = 'Bitte Eingabe prüfen.',
}) => InputDecoration(
  labelText: label == null ? null : '$label${required ? ' *' : ''}',
  hintText: placeholder,
  errorText: isValid ? null : validationMessage,
);

/// Einzeilige Texteingabe; Änderungen über das Modell oder den Callback übernehmen.
///
/// Single-line text input; accept edits through its model or callback.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var text = '';
///   return StatefulBuilder(
///     builder: (context, setState) => TxTextBox(
///       label: 'Name',
///       initialValue: 'Alex',
///       onChanged: (v) => setState(() => text = v),
///     ),
///   );
/// }
/// ```
class TxTextBox extends StatelessWidget {
  /// Einzeilige Texteingabe; Änderungen über das Modell oder den Callback übernehmen.
  ///
  /// Single-line text input; accept edits through its model or callback.
  const TxTextBox({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValueChanged,
    this.label,
    this.placeholder,
    this.disabled = false,
    this.readOnly = false,
    this.required = false,
    this.isValid = true,
    this.validationMessage = 'Bitte Eingabe prüfen.',
    this.obscureText = false,
    this.keyboardType,
    this.focusNode,
  }) : assert(controller == null || initialValue == null);

  /// Externer Textcontroller; Entsorgung bleibt Aufgabe der Anwendung.
  ///
  /// External text controller; the application disposes it.
  final TextEditingController? controller;

  /// initialValue: Startwert im unkontrollierten Modus.
  /// label: Beschriftung beziehungsweise zugänglicher Name.
  /// placeholder: Hinweis bei leerer Eingabe.
  ///
  /// initialValue: Starting value in uncontrolled mode.
  /// label: Label or accessible name.
  /// placeholder: Hint for an empty input.
  final String? initialValue, label, placeholder;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<String>? onChanged;

  /// Meldet value; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports value; update controlled state in the callback.
  final ValueChanged<TxValueChange<String>>? onValueChanged;

  /// disabled: Sperrt die Interaktion.
  /// readOnly: Verhindert Änderungen des Werts.
  /// required: Kennzeichnet die erforderliche Eingabe.
  /// isValid: Steuert die Fehlerdarstellung; führt keine eigene Validierung aus.
  /// obscureText: Verbirgt die Texteingabe.
  ///
  /// disabled: Disables interaction.
  /// readOnly: Prevents value changes.
  /// required: Marks a required input.
  /// isValid: Controls error presentation; does not perform validation.
  /// obscureText: Obscures text input.
  final bool disabled, readOnly, required, isValid, obscureText;

  /// Fehlermeldung bei isValid = false.
  ///
  /// Error message when isValid is false.
  final String validationMessage;

  /// Gewünschte Bildschirmtastatur.
  ///
  /// Requested on-screen keyboard type.
  final TextInputType? keyboardType;

  /// Externer Fokuscontroller.
  ///
  /// External focus controller.
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => _TxTextInput(
    controller: controller,
    initialValue: initialValue,
    onChanged: onChanged,
    onValueChanged: onValueChanged,
    label: label,
    placeholder: placeholder,
    disabled: disabled,
    readOnly: readOnly,
    required: required,
    isValid: isValid,
    validationMessage: validationMessage,
    obscureText: obscureText,
    keyboardType: keyboardType,
    focusNode: focusNode,
  );
}

/// Mehrzeilige Texteingabe mit konfigurierbarer Zeilenzahl.
///
/// Multiline text input with a configurable row count.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var text = '';
///   return StatefulBuilder(
///     builder: (context, setState) => TxTextArea(
///       label: 'Notes',
///       rows: 4,
///       onChanged: (v) => setState(() => text = v),
///     ),
///   );
/// }
/// ```
class TxTextArea extends StatelessWidget {
  /// Mehrzeilige Texteingabe mit konfigurierbarer Zeilenzahl.
  ///
  /// Multiline text input with a configurable row count.
  const TxTextArea({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValueChanged,
    this.label,
    this.placeholder,
    this.rows = 3,
    this.disabled = false,
    this.readOnly = false,
    this.required = false,
    this.isValid = true,
    this.validationMessage = 'Bitte Eingabe prüfen.',
    this.focusNode,
  }) : assert(controller == null || initialValue == null),
       assert(rows > 0);

  /// Externer Textcontroller; Entsorgung bleibt Aufgabe der Anwendung.
  ///
  /// External text controller; the application disposes it.
  final TextEditingController? controller;

  /// initialValue: Startwert im unkontrollierten Modus.
  /// label: Beschriftung beziehungsweise zugänglicher Name.
  /// placeholder: Hinweis bei leerer Eingabe.
  ///
  /// initialValue: Starting value in uncontrolled mode.
  /// label: Label or accessible name.
  /// placeholder: Hint for an empty input.
  final String? initialValue, label, placeholder;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<String>? onChanged;

  /// Meldet value; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports value; update controlled state in the callback.
  final ValueChanged<TxValueChange<String>>? onValueChanged;

  /// Sichtbare Textzeilen.
  ///
  /// Visible text rows.
  final int rows;

  /// disabled: Sperrt die Interaktion.
  /// readOnly: Verhindert Änderungen des Werts.
  /// required: Kennzeichnet die erforderliche Eingabe.
  /// isValid: Steuert die Fehlerdarstellung; führt keine eigene Validierung aus.
  ///
  /// disabled: Disables interaction.
  /// readOnly: Prevents value changes.
  /// required: Marks a required input.
  /// isValid: Controls error presentation; does not perform validation.
  final bool disabled, readOnly, required, isValid;

  /// Fehlermeldung bei isValid = false.
  ///
  /// Error message when isValid is false.
  final String validationMessage;

  /// Externer Fokuscontroller.
  ///
  /// External focus controller.
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => _TxTextInput(
    controller: controller,
    initialValue: initialValue,
    onChanged: onChanged,
    onValueChanged: onValueChanged,
    label: label,
    placeholder: placeholder,
    rows: rows,
    disabled: disabled,
    readOnly: readOnly,
    required: required,
    isValid: isValid,
    validationMessage: validationMessage,
    focusNode: focusNode,
  );
}

class _TxTextInput extends StatefulWidget {
  const _TxTextInput({
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValueChanged,
    this.label,
    this.placeholder,
    this.rows = 1,
    this.disabled = false,
    this.readOnly = false,
    this.required = false,
    this.isValid = true,
    this.validationMessage = '',
    this.obscureText = false,
    this.keyboardType,
    this.focusNode,
  });
  final TextEditingController? controller;
  final String? initialValue, label, placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<TxValueChange<String>>? onValueChanged;
  final int rows;
  final bool disabled, readOnly, required, isValid, obscureText;
  final String validationMessage;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  @override
  State<_TxTextInput> createState() => _TxTextInputState();
}

class _TxTextInputState extends State<_TxTextInput> {
  late TextEditingController _controller;
  late String _previous;
  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _previous = _controller.text;
  }

  @override
  void didUpdateWidget(_TxTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final text = _controller.text;
      if (oldWidget.controller == null) _controller.dispose();
      _controller = widget.controller ?? TextEditingController(text: text);
    }
    _previous = _controller.text;
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    focusNode: widget.focusNode,
    enabled: !widget.disabled,
    readOnly: widget.readOnly,
    obscureText: widget.obscureText,
    minLines: widget.rows,
    maxLines: widget.rows,
    keyboardType:
        widget.keyboardType ??
        (widget.rows > 1 ? TextInputType.multiline : TextInputType.text),
    decoration: _decoration(
      label: widget.label,
      placeholder: widget.placeholder,
      required: widget.required,
      isValid: widget.isValid,
      validationMessage: widget.validationMessage,
    ),
    onChanged: (value) {
      if (widget.disabled || widget.readOnly) return;
      final previous = _previous;
      _previous = value;
      widget.onChanged?.call(value);
      if (previous != value) {
        widget.onValueChanged?.call(
          TxValueChange(value: value, previousValue: previous),
        );
      }
    },
  );
}

/// Zahleneingabe mit Grenzen und Schritten. Ein leerer Wert ergibt null.
///
/// Numeric input with bounds and steps. An empty input produces null.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   num? amount = 10;
///   return StatefulBuilder(
///     builder: (context, setState) => TxNumberBox(
///       value: amount,
///       min: 0,
///       max: 100,
///       onChanged: (v) => setState(() => amount = v),
///     ),
///   );
/// }
/// ```
class TxNumberBox extends StatefulWidget {
  /// Zahleneingabe mit Grenzen und Schritten. Ein leerer Wert ergibt null.
  ///
  /// Numeric input with bounds and steps. An empty input produces null.
  const TxNumberBox({
    super.key,
    this.value,
    this.initialValue,
    this.onChanged,
    this.onValueChanged,
    this.label,
    this.placeholder,
    this.min,
    this.max,
    this.step = 1,
    this.disabled = false,
    this.readOnly = false,
    this.isValid = true,
    this.validationMessage = 'Bitte Eingabe prüfen.',
  });

  /// value: Aktueller Eingabe-/Optionswert.
  /// initialValue: Startwert im unkontrollierten Modus.
  /// min: Untere zulässige Grenze.
  /// max: Obere zulässige Grenze.
  ///
  /// value: Current input/option value.
  /// initialValue: Starting value in uncontrolled mode.
  /// min: Lower allowed bound.
  /// max: Upper allowed bound.
  final num? value, initialValue, min, max;

  /// Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden.
  ///
  /// Step size; milliseconds for Vue date ranges.
  final num step;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<num?>? onChanged;

  /// Meldet value; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports value; update controlled state in the callback.
  final ValueChanged<TxValueChange<num?>>? onValueChanged;

  /// label: Beschriftung beziehungsweise zugänglicher Name.
  /// placeholder: Hinweis bei leerer Eingabe.
  ///
  /// label: Label or accessible name.
  /// placeholder: Hint for an empty input.
  final String? label, placeholder;

  /// disabled: Sperrt die Interaktion.
  /// readOnly: Verhindert Änderungen des Werts.
  /// isValid: Steuert die Fehlerdarstellung; führt keine eigene Validierung aus.
  ///
  /// disabled: Disables interaction.
  /// readOnly: Prevents value changes.
  /// isValid: Controls error presentation; does not perform validation.
  final bool disabled, readOnly, isValid;

  /// Fehlermeldung bei isValid = false.
  ///
  /// Error message when isValid is false.
  final String validationMessage;
  @override
  State<TxNumberBox> createState() => _TxNumberBoxState();
}

class _TxNumberBoxState extends State<TxNumberBox> {
  late TextEditingController _controller;
  num? _previous;
  @override
  void initState() {
    super.initState();
    _previous = widget.value ?? widget.initialValue;
    _controller = TextEditingController(text: _previous?.toString() ?? '');
  }

  @override
  void didUpdateWidget(TxNumberBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previous = widget.value;
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emit(num? value) {
    final previous = _previous;
    _previous = value;
    widget.onChanged?.call(value);
    if (previous != value) {
      widget.onValueChanged?.call(
        TxValueChange(value: value, previousValue: previous),
      );
    }
  }

  void _step(int direction) {
    if (widget.disabled || widget.readOnly) return;
    if (widget.step <= 0 || !widget.step.isFinite) {
      throw ArgumentError('step muss positiv und endlich sein.');
    }
    num next = (_previous ?? 0) + direction * widget.step;
    if (widget.min != null && next < widget.min!) next = widget.min!;
    if (widget.max != null && next > widget.max!) next = widget.max!;
    _controller.text = next.toString();
    _emit(next);
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    enabled: !widget.disabled,
    readOnly: widget.readOnly,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-+]'))],
    decoration:
        _decoration(
          label: widget.label,
          placeholder: widget.placeholder,
          isValid: widget.isValid,
          validationMessage: widget.validationMessage,
        ).copyWith(
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Wert verringern',
                icon: const Icon(Icons.remove, size: 16),
                onPressed: widget.disabled || widget.readOnly
                    ? null
                    : () => _step(-1),
              ),
              IconButton(
                tooltip: 'Wert erhöhen',
                icon: const Icon(Icons.add, size: 16),
                onPressed: widget.disabled || widget.readOnly
                    ? null
                    : () => _step(1),
              ),
            ],
          ),
        ),
    onChanged: (text) {
      if (widget.disabled || widget.readOnly) return;
      final value = num.tryParse(text.replaceAll(',', '.'));
      if (text.isNotEmpty && value == null) return;
      if (value != null &&
          ((widget.min != null && value < widget.min!) ||
              (widget.max != null && value > widget.max!))) {
        return;
      }
      _emit(value);
    },
  );
}

/// Kontrollkästchen für einen booleschen Wert.
///
/// Checkbox for a boolean value.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var enabled = true;
///   return StatefulBuilder(
///     builder: (context, setState) => TxCheckBox(
///       value: enabled,
///       label: 'Active',
///       onChanged: (v) => setState(() => enabled = v),
///     ),
///   );
/// }
/// ```
class TxCheckBox extends StatefulWidget {
  /// Kontrollkästchen für einen booleschen Wert.
  ///
  /// Checkbox for a boolean value.
  const TxCheckBox({
    super.key,
    this.value,
    this.initialValue = false,
    this.label,
    this.onChanged,
    this.disabled = false,
    this.readOnly = false,
    this.isValid = true,
    this.validationMessage = 'Bitte Eingabe prüfen.',
  });

  /// Aktueller Eingabe-/Optionswert.
  ///
  /// Current input/option value.
  final bool? value;

  /// initialValue: Startwert im unkontrollierten Modus.
  /// disabled: Sperrt die Interaktion.
  /// readOnly: Verhindert Änderungen des Werts.
  /// isValid: Steuert die Fehlerdarstellung; führt keine eigene Validierung aus.
  ///
  /// initialValue: Starting value in uncontrolled mode.
  /// disabled: Disables interaction.
  /// readOnly: Prevents value changes.
  /// isValid: Controls error presentation; does not perform validation.
  final bool initialValue, disabled, readOnly, isValid;

  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String? label;

  /// Fehlermeldung bei isValid = false.
  ///
  /// Error message when isValid is false.
  final String validationMessage;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<bool>? onChanged;
  @override
  State<TxCheckBox> createState() => _TxCheckBoxState();
}

class _TxCheckBoxState extends State<TxCheckBox> {
  late bool _value = widget.initialValue;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: widget.label == null ? null : Text(widget.label!),
        value: widget.value ?? _value,
        isError: !widget.isValid,
        onChanged: widget.disabled || widget.readOnly
            ? null
            : (value) {
                setState(() => _value = value!);
                widget.onChanged?.call(value!);
              },
      ),
      if (!widget.isValid)
        Text(
          widget.validationMessage,
          style: TextStyle(color: txThemeOf(context).danger),
        ),
    ],
  );
}

/// Schalter für einen booleschen Wert.
///
/// Switch for a boolean value.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   var enabled = true;
///   return StatefulBuilder(
///     builder: (context, setState) => TxSwitch(
///       value: enabled,
///       label: 'Active',
///       onChanged: (v) => setState(() => enabled = v),
///     ),
///   );
/// }
/// ```
class TxSwitch extends StatefulWidget {
  /// Schalter für einen booleschen Wert.
  ///
  /// Switch for a boolean value.
  const TxSwitch({
    super.key,
    this.value,
    this.initialValue = false,
    this.label,
    this.onChanged,
    this.disabled = false,
    this.readOnly = false,
    this.isValid = true,
    this.validationMessage = 'Bitte Eingabe prüfen.',
  });

  /// Aktueller Eingabe-/Optionswert.
  ///
  /// Current input/option value.
  final bool? value;

  /// initialValue: Startwert im unkontrollierten Modus.
  /// disabled: Sperrt die Interaktion.
  /// readOnly: Verhindert Änderungen des Werts.
  /// isValid: Steuert die Fehlerdarstellung; führt keine eigene Validierung aus.
  ///
  /// initialValue: Starting value in uncontrolled mode.
  /// disabled: Disables interaction.
  /// readOnly: Prevents value changes.
  /// isValid: Controls error presentation; does not perform validation.
  final bool initialValue, disabled, readOnly, isValid;

  /// Fehlermeldung bei isValid = false.
  ///
  /// Error message when isValid is false.
  final String validationMessage;

  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String? label;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<bool>? onChanged;
  @override
  State<TxSwitch> createState() => _TxSwitchState();
}

class _TxSwitchState extends State<TxSwitch> {
  late bool _value = widget.initialValue;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: widget.label == null ? null : Text(widget.label!),
        value: widget.value ?? _value,
        onChanged: widget.disabled || widget.readOnly
            ? null
            : (value) {
                setState(() => _value = value);
                widget.onChanged?.call(value);
              },
      ),
      if (!widget.isValid)
        Text(
          widget.validationMessage,
          style: TextStyle(color: txThemeOf(context).danger),
        ),
    ],
  );
}

/// Einfachauswahl aus einer Liste oder Datenquelle.
///
/// Single selection from a list or data source.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   const options = [
///     TxItem(value: 1, text: 'One'),
///     TxItem(value: 2, text: 'Two'),
///   ];
///   int? choice = 1;
///   return StatefulBuilder(
///     builder: (context, setState) => TxSelectBox<int>(
///       items: options,
///       value: choice,
///       onChanged: (v) => setState(() => choice = v),
///     ),
///   );
/// }
/// ```
class TxSelectBox<T> extends StatefulWidget {
  /// Einfachauswahl aus einer Liste oder Datenquelle.
  ///
  /// Single selection from a list or data source.
  const TxSelectBox({
    super.key,
    this.items = const [],
    this.dataSource,
    this.value,
    this.onChanged,
    this.label,
    this.placeholder = 'Bitte wählen',
    this.disabled = false,
    this.readOnly = false,
    this.isValid = true,
    this.validationMessage = 'Bitte Eingabe prüfen.',
  });

  /// Einträge; bei Datenbindung durch dataSource ersetzt.
  ///
  /// Entries; replaced by dataSource when bound.
  final List<TxItem<T>> items;

  /// Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  ///
  /// List, configuration or DataSource instance; takes precedence over items.
  final Object? dataSource;

  /// Aktueller Eingabe-/Optionswert.
  ///
  /// Current input/option value.
  final T? value;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<T?>? onChanged;

  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String? label;

  /// placeholder: Hinweis bei leerer Eingabe.
  /// validationMessage: Fehlermeldung bei isValid = false.
  ///
  /// placeholder: Hint for an empty input.
  /// validationMessage: Error message when isValid is false.
  final String placeholder, validationMessage;

  /// disabled: Sperrt die Interaktion.
  /// readOnly: Verhindert Änderungen des Werts.
  /// isValid: Steuert die Fehlerdarstellung; führt keine eigene Validierung aus.
  ///
  /// disabled: Disables interaction.
  /// readOnly: Prevents value changes.
  /// isValid: Controls error presentation; does not perform validation.
  final bool disabled, readOnly, isValid;
  @override
  State<TxSelectBox<T>> createState() => _TxSelectBoxState<T>();
}

class _TxSelectBoxState<T> extends State<TxSelectBox<T>>
    with TxSourceState<TxSelectBox<T>, TxItem<T>> {
  @override
  Object? get sourceInput => widget.dataSource;
  @override
  List<TxItem<T>> get sourceFallback => widget.items;

  T? _value;
  @override
  void didUpdateWidget(covariant TxSelectBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.value ?? _value;
    final valid = sourceItems.any((item) => item.value == selected)
        ? selected
        : null;
    return InputDecorator(
      decoration: _decoration(
        label: widget.label,
        isValid: widget.isValid,
        validationMessage: widget.validationMessage,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          isDense: true,
          value: valid,
          hint: Text(widget.placeholder),
          items: widget.items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  enabled: !item.disabled,
                  child: Text(
                    item.text,
                    style: item.disabled
                        ? TextStyle(color: Theme.of(context).disabledColor)
                        : null,
                  ),
                ),
              )
              .toList(),
          onChanged: widget.disabled || widget.readOnly
              ? null
              : (value) {
                  setState(() => _value = value);
                  widget.onChanged?.call(value);
                },
        ),
      ),
    );
  }
}

/// Datumseingabe mit unterer und oberer Grenze.
///
/// Date input with lower and upper bounds.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   DateTime? date = DateTime(2026, 10, 28);
///   return StatefulBuilder(
///     builder: (context, setState) =>
///         TxDateBox(value: date, onChanged: (v) => setState(() => date = v)),
///   );
/// }
/// ```
class TxDateBox extends StatefulWidget {
  /// Datumseingabe mit unterer und oberer Grenze.
  ///
  /// Date input with lower and upper bounds.
  const TxDateBox({
    super.key,
    this.value,
    this.initialValue,
    this.onChanged,
    this.label,
    this.min,
    this.max,
    this.disabled = false,
    this.readOnly = false,
    this.isValid = true,
    this.validationMessage = 'Bitte Eingabe prüfen.',
  });

  /// value: Aktueller Eingabe-/Optionswert.
  /// initialValue: Startwert im unkontrollierten Modus.
  /// min: Untere zulässige Grenze.
  /// max: Obere zulässige Grenze.
  ///
  /// value: Current input/option value.
  /// initialValue: Starting value in uncontrolled mode.
  /// min: Lower allowed bound.
  /// max: Upper allowed bound.
  final DateTime? value, initialValue, min, max;

  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
  final ValueChanged<DateTime?>? onChanged;

  /// Beschriftung beziehungsweise zugänglicher Name.
  ///
  /// Label or accessible name.
  final String? label;

  /// disabled: Sperrt die Interaktion.
  /// readOnly: Verhindert Änderungen des Werts.
  /// isValid: Steuert die Fehlerdarstellung; führt keine eigene Validierung aus.
  ///
  /// disabled: Disables interaction.
  /// readOnly: Prevents value changes.
  /// isValid: Controls error presentation; does not perform validation.
  final bool disabled, readOnly, isValid;

  /// Fehlermeldung bei isValid = false.
  ///
  /// Error message when isValid is false.
  final String validationMessage;
  @override
  State<TxDateBox> createState() => _TxDateBoxState();
}

class _TxDateBoxState extends State<TxDateBox> {
  late DateTime? _value = widget.initialValue;
  @override
  void didUpdateWidget(TxDateBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value ?? _value;
    final blocked = widget.disabled || widget.readOnly;
    return Semantics(
      label: widget.label ?? 'Datum',
      button: true,
      enabled: !blocked,
      child: InkWell(
        onTap: blocked
            ? null
            : () async {
                final first = widget.min ?? DateTime(1900),
                    last = widget.max ?? DateTime(2200);
                var initial = value ?? DateTime.now();
                if (initial.isBefore(first)) initial = first;
                if (initial.isAfter(last)) initial = last;
                final selected = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: first,
                  lastDate: last,
                );
                if (!mounted ||
                    selected == null ||
                    widget.disabled ||
                    widget.readOnly) {
                  return;
                }
                setState(() => _value = selected);
                widget.onChanged?.call(selected);
              },
        child: InputDecorator(
          decoration:
              _decoration(
                label: widget.label,
                isValid: widget.isValid,
                validationMessage: widget.validationMessage,
              ).copyWith(
                enabled: !widget.disabled,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
          child: Text(
            value == null
                ? 'Datum wählen'
                : MaterialLocalizations.of(context).formatCompactDate(value),
          ),
        ),
      ),
    );
  }
}
