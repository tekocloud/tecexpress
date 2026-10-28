import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Semantische Farben und Maße als ThemeExtension. copyWith überschreibt einzelne Tokens, lerp interpoliert zwischen Themes.
///
/// Semantic colors and dimensions as a ThemeExtension. copyWith replaces individual tokens; lerp interpolates between themes.
///
/// ```dart
/// final tokens = TxThemeData.light.copyWith(accent: Colors.indigo, radius: 12);
/// print(tokens.lerp(TxThemeData.dark, 0.5).accent);
/// ```
@immutable
class TxThemeData extends ThemeExtension<TxThemeData> {
  /// Semantische Farben und Maße als ThemeExtension. copyWith überschreibt einzelne Tokens, lerp interpoliert zwischen Themes.
  ///
  /// Semantic colors and dimensions as a ThemeExtension. copyWith replaces individual tokens; lerp interpolates between themes.
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

  /// background: Hintergrundfarbe.
  /// surface: Farbe primärer Oberflächen.
  /// surfaceAlt: Farbe alternativer Oberflächen.
  /// text: Anzuzeigender Text.
  /// muted: Farbe sekundärer Texte.
  /// border: Rahmenfarbe.
  /// accent: Akzentfarbe.
  /// onAccent: Textfarbe auf Akzentflächen.
  /// hover: Hintergrund bei Hover.
  /// selection: Auswahlmodus.
  /// danger: Fehlerfarbe.
  /// success: Erfolgsfarbe.
  /// focus: Fokusfarbe.
  ///
  /// background: Background color.
  /// surface: Primary surface color.
  /// surfaceAlt: Alternate surface color.
  /// text: Text to display.
  /// muted: Secondary text color.
  /// border: Border color.
  /// accent: Accent color.
  /// onAccent: Text color on accent surfaces.
  /// hover: Hover background.
  /// selection: Selection mode.
  /// danger: Error color.
  /// success: Success color.
  /// focus: Focus color.
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

  /// radius: Eckenradius in logischen Pixeln.
  /// spacing: Grundabstand in logischen Pixeln.
  /// controlHeight: Grundhöhe von Eingaben in logischen Pixeln.
  ///
  /// radius: Corner radius in logical pixels.
  /// spacing: Base spacing in logical pixels.
  /// controlHeight: Base input height in logical pixels.
  final double radius, spacing, controlHeight;

  /// Helle Standardtokens beziehungsweise helles Material-Theme.
  ///
  /// Default light tokens or light Material theme.
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

  /// Dunkle Standardtokens beziehungsweise dunkles Material-Theme.
  ///
  /// Default dark tokens or dark Material theme.
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

  /// Erzeugt eine Kopie mit den angegebenen Änderungen; alle übrigen Werte bleiben erhalten.
  ///
  /// Creates a copy with the supplied changes; preserves other values.
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

  /// Interpoliert Tokens zum anderen Theme mit Faktor t; null behält dieses Theme bei.
  ///
  /// Interpolates tokens toward another theme by factor t; null preserves this theme.
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

/// Erstellt helle oder dunkle Material-Themes mit tecexpress-Tokens.
///
/// Creates light or dark Material themes with tecexpress tokens.
///
/// ```dart
/// final light = TxTheme.light();
/// final dark = TxTheme.dark();
/// print(MaterialApp(theme: light, darkTheme: dark));
/// ```
abstract final class TxTheme {
  /// Helle Standardtokens beziehungsweise helles Material-Theme.
  ///
  /// Default light tokens or light Material theme.
  static ThemeData light({TxThemeData tokens = TxThemeData.light}) =>
      _build(Brightness.light, tokens);

  /// Dunkle Standardtokens beziehungsweise dunkles Material-Theme.
  ///
  /// Default dark tokens or dark Material theme.
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

/// Liest die ThemeExtension des Kontexts; ohne Extension gelten passende helle/dunkle Standardtokens.
///
/// Parameter context benötigt einen Theme-Vorfahren. Rückgabe synchron TxThemeData; ohne eigene Extension werden Standardtokens passend zur Helligkeit geliefert.
///
/// Reads the context ThemeExtension; without an extension it returns matching light/dark default tokens.
///
/// Parameter context needs a Theme ancestor. Synchronously returns TxThemeData; without a custom extension, defaults matching brightness are returned.
///
/// ```dart
/// Color accent(BuildContext context) => txThemeOf(context).accent;
/// print(accent);
/// ```
TxThemeData txThemeOf(BuildContext context) =>
    Theme.of(context).extension<TxThemeData>() ??
    (Theme.of(context).brightness == Brightness.dark
        ? TxThemeData.dark
        : TxThemeData.light);

/// Material-Lokalisierungsdelegates und unterstützte deutsche/englische Locales für MaterialApp.
///
/// Material localization delegates and supported German/English locales for MaterialApp.
///
/// ```dart
/// print(MaterialApp(localizationsDelegates: TxLocalizations.delegates, supportedLocales: TxLocalizations.supportedLocales));
/// ```
abstract final class TxLocalizations {
  /// In MaterialApp.localizationsDelegates einbinden.
  ///
  /// Assign to MaterialApp.localizationsDelegates.
  static const delegates = GlobalMaterialLocalizations.delegates;

  /// In MaterialApp.supportedLocales einbinden.
  ///
  /// Assign to MaterialApp.supportedLocales.
  static const supportedLocales = [Locale('de'), Locale('en')];
}
