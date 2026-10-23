import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Semantic tokens shared by all tecexpress widgets.
@immutable
class TxThemeData extends ThemeExtension<TxThemeData> {
  const TxThemeData({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.muted,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.hover,
    required this.selection,
    required this.danger,
    required this.success,
    required this.focus,
    this.radius = 8,
    this.spacing = 8,
    this.controlHeight = 40,
  });

  final Color background,
      surface,
      surfaceAlt,
      text,
      muted,
      border,
      accent,
      onAccent,
      hover,
      selection,
      danger,
      success,
      focus;
  final double radius, spacing, controlHeight;

  static const light = TxThemeData(
    background: Color(0xfff3f5fa),
    surface: Colors.white,
    surfaceAlt: Color(0xfff7f9fc),
    text: Color(0xff172339),
    muted: Color(0xff53627a),
    border: Color(0xffc7d0df),
    accent: Color(0xff365bc6),
    onAccent: Colors.white,
    hover: Color(0xffe9eefb),
    selection: Color(0xffe1eaff),
    danger: Color(0xffb42338),
    success: Color(0xff137553),
    focus: Color(0xff315dd6),
  );
  static const dark = TxThemeData(
    background: Color(0xff101725),
    surface: Color(0xff182236),
    surfaceAlt: Color(0xff1d2a40),
    text: Color(0xffedf2fc),
    muted: Color(0xffb0bfd6),
    border: Color(0xff465974),
    accent: Color(0xffa9beff),
    onAccent: Color(0xff132348),
    hover: Color(0xff283c5c),
    selection: Color(0xff2b416b),
    danger: Color(0xffff9cad),
    success: Color(0xff7bdbb4),
    focus: Color(0xffb5c8ff),
  );

  @override
  TxThemeData copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? text,
    Color? muted,
    Color? border,
    Color? accent,
    Color? onAccent,
    Color? hover,
    Color? selection,
    Color? danger,
    Color? success,
    Color? focus,
    double? radius,
    double? spacing,
    double? controlHeight,
  }) => TxThemeData(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    border: border ?? this.border,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    hover: hover ?? this.hover,
    selection: selection ?? this.selection,
    danger: danger ?? this.danger,
    success: success ?? this.success,
    focus: focus ?? this.focus,
    radius: radius ?? this.radius,
    spacing: spacing ?? this.spacing,
    controlHeight: controlHeight ?? this.controlHeight,
  );

  @override
  TxThemeData lerp(covariant TxThemeData? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    double size(double a, double b) => a + (b - a) * t;
    return TxThemeData(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      text: mix(text, other.text),
      muted: mix(muted, other.muted),
      border: mix(border, other.border),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      hover: mix(hover, other.hover),
      selection: mix(selection, other.selection),
      danger: mix(danger, other.danger),
      success: mix(success, other.success),
      focus: mix(focus, other.focus),
      radius: size(radius, other.radius),
      spacing: size(spacing, other.spacing),
      controlHeight: size(controlHeight, other.controlHeight),
    );
  }
}

/// Material themes using tecexpress tokens. Supply both to MaterialApp.
abstract final class TxTheme {
  static ThemeData light({TxThemeData tokens = TxThemeData.light}) =>
      _build(Brightness.light, tokens);
  static ThemeData dark({TxThemeData tokens = TxThemeData.dark}) =>
      _build(Brightness.dark, tokens);
  static ThemeData _build(Brightness brightness, TxThemeData tokens) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: tokens.accent,
          brightness: brightness,
        ).copyWith(
          primary: tokens.accent,
          onPrimary: tokens.onAccent,
          surface: tokens.surface,
          onSurface: tokens.text,
          error: tokens.danger,
          outline: tokens.border,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.background,
      extensions: [tokens],
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: tokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
          borderSide: BorderSide(color: tokens.border),
        ),
      ),
      dividerColor: tokens.border,
      cardTheme: CardThemeData(
        color: tokens.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: tokens.border),
        ),
      ),
    );
  }
}

TxThemeData txThemeOf(BuildContext context) =>
    Theme.of(context).extension<TxThemeData>() ??
    (Theme.of(context).brightness == Brightness.dark
        ? TxThemeData.dark
        : TxThemeData.light);

/// Install these delegates in MaterialApp for German date pickers and controls.
abstract final class TxLocalizations {
  static const delegates = GlobalMaterialLocalizations.delegates;
  static const supportedLocales = [Locale('de'), Locale('en')];
}
