import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'models.dart';
import 'theme.dart';

class TxButton extends StatelessWidget {
  const TxButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.disabled = false,
    this.type = TxButtonType.normal,
    this.icon,
  });
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool disabled;
  final TxButtonType type;
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

class TxTextBox extends StatelessWidget {
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
  final TextEditingController? controller;
  final String? initialValue, label, placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<TxValueChange<String>>? onValueChanged;
  final bool disabled, readOnly, required, isValid, obscureText;
  final String validationMessage;
  final TextInputType? keyboardType;
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

class TxTextArea extends StatelessWidget {
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
  final TextEditingController? controller;
  final String? initialValue, label, placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<TxValueChange<String>>? onValueChanged;
  final int rows;
  final bool disabled, readOnly, required, isValid;
  final String validationMessage;
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

class TxNumberBox extends StatefulWidget {
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
  final num? value, initialValue, min, max;
  final num step;
  final ValueChanged<num?>? onChanged;
  final ValueChanged<TxValueChange<num?>>? onValueChanged;
  final String? label, placeholder;
  final bool disabled, readOnly, isValid;
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

class TxCheckBox extends StatefulWidget {
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
  final bool? value;
  final bool initialValue, disabled, readOnly, isValid;
  final String? label;
  final String validationMessage;
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

class TxSwitch extends StatefulWidget {
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
  final bool? value;
  final bool initialValue, disabled, readOnly, isValid;
  final String validationMessage;
  final String? label;
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

class TxSelectBox<T> extends StatefulWidget {
  const TxSelectBox({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.placeholder = 'Bitte wählen',
    this.disabled = false,
    this.readOnly = false,
    this.isValid = true,
    this.validationMessage = 'Bitte Eingabe prüfen.',
  });
  final List<TxItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String placeholder, validationMessage;
  final bool disabled, readOnly, isValid;
  @override
  State<TxSelectBox<T>> createState() => _TxSelectBoxState<T>();
}

class _TxSelectBoxState<T> extends State<TxSelectBox<T>> {
  T? _value;
  @override
  void didUpdateWidget(covariant TxSelectBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.value ?? _value;
    final valid = widget.items.any((item) => item.value == selected)
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

class TxDateBox extends StatefulWidget {
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
  final DateTime? value, initialValue, min, max;
  final ValueChanged<DateTime?>? onChanged;
  final String? label;
  final bool disabled, readOnly, isValid;
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
                : DateFormat.yMd(
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(value),
          ),
        ),
      ),
    );
  }
}
