import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'source.dart';

/// Geografische Breite und Länge in Grad.
///
/// Geographic latitude and longitude in degrees.
///
/// ```dart
/// const point = TxCoordinate(52.52, 13.405);
/// print(point.lat);
/// ```
class TxCoordinate {
  /// Geografische Breite und Länge in Grad.
  ///
  /// Geographic latitude and longitude in degrees.
  const TxCoordinate(this.lat, this.lng);
  /// lat: Geografische Breite in Grad.
  /// lng: Geografische Länge in Grad.
  ///
  /// lat: Latitude in degrees.
  /// lng: Longitude in degrees.
  final double lat, lng;
}

/// Koordinate mit eindeutiger ID und optionalem Popuptext und Farbe.
///
/// Coordinate with a unique ID and optional popup text and color.
///
/// ```dart
/// const marker = TxMapMarker(52.52, 13.405, id: 'berlin', text: 'Berlin');
/// print(marker.text);
/// ```
class TxMapMarker extends TxCoordinate {
  /// Koordinate mit eindeutiger ID und optionalem Popuptext und Farbe.
  ///
  /// Coordinate with a unique ID and optional popup text and color.
  const TxMapMarker(
    super.lat,
    super.lng, {
    required this.id,
    this.text,
    this.color,
  });
  /// Eindeutige stabile ID.
  ///
  /// Unique stable ID.
  final Object id;
  /// Anzuzeigender Text.
  ///
  /// Text to display.
  final String? text;
  /// Darstellungsfarbe.
  ///
  /// Display color.
  final Color? color;
}

/// Darzustellende Routenlinie aus Koordinaten; berechnet keine Route.
///
/// Route line to draw from coordinates; it does not calculate a route.
///
/// ```dart
/// const route = TxMapRoute(id: 'walk', points: [TxCoordinate(52.52, 13.405), TxCoordinate(52.53, 13.41)]);
/// print(route.points.length);
/// ```
class TxMapRoute {
  /// Darzustellende Routenlinie aus Koordinaten; berechnet keine Route.
  ///
  /// Route line to draw from coordinates; it does not calculate a route.
  const TxMapRoute({
    required this.id,
    required this.points,
    this.color = Colors.blue,
    this.width = 3,
  });
  /// Eindeutige stabile ID.
  ///
  /// Unique stable ID.
  final Object id;
  /// Koordinaten der Routenlinie in Reihenfolge.
  ///
  /// Route line coordinates in order.
  final List<TxCoordinate> points;
  /// Darstellungsfarbe.
  ///
  /// Display color.
  final Color color;
  /// Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln.
  ///
  /// Width; Vue numbers use pixels, Flutter uses logical pixels.
  final double width;
}

/// Vertrag eigener Geocoding-/Routing-Dienste. Dienste selbst aufrufen und Ergebnisse an die Karte binden.
///
/// Contract for custom geocoding/routing services. Call services yourself and bind results to the map.
///
/// ```dart
/// // An implementation is supplied by your application.
/// Future<void> locate(TxGeoAdapter adapter) async {
///   final points = await adapter.geocode('Berlin');
///   if (points.length >= 2) print(await adapter.route(points));
/// }
/// print(locate);
/// ```
abstract class TxGeoAdapter {
  /// Fragt den eigenen Geodienst nach Koordinaten für einen Suchtext.
  ///
  /// Queries a custom geographic service for coordinates matching text.
  Future<List<TxCoordinate>> geocode(
    String query, {
    TxCancellation? cancellation,
  });
  /// Fragt den eigenen Routingdienst nach einer Route durch die Wegpunkte.
  ///
  /// Queries a custom routing service for a route through waypoints.
  Future<List<TxCoordinate>> route(
    List<TxCoordinate> points, {
    TxCancellation? cancellation,
  });
}

/// Projiziert geografische Koordinaten in Web-Mercator-Weltpixel bei gegebenem Zoom; begrenzt die Breite auf etwa ±85,05°.
///
/// Parameter: point mit lat/lng in Grad und zoom. Rückgabe synchron: { x, y } in Vue, Offset in Dart; Weltpixel, keine Pixel relativ zum sichtbaren Kartenausschnitt.
///
/// Projects geographic coordinates to Web Mercator world pixels at a given zoom; clamps latitude to about ±85.05°.
///
/// Parameters: point with lat/lng in degrees and zoom. Synchronous return: { x, y } in Vue, Offset in Dart; world pixels, not pixels relative to the visible viewport.
///
/// ```dart
/// print(txProject(const TxCoordinate(52.52, 13.405), 5));
/// ```
Offset txProject(TxCoordinate point, double zoom) {
  final scale = 256 * math.pow(2, zoom),
      lat = point.lat.clamp(-85.05112878, 85.05112878) * math.pi / 180;
  return Offset(
    (point.lng + 180) / 360 * scale,
    (1 - math.log(math.tan(lat) + 1 / math.cos(lat)) / math.pi) / 2 * scale,
  );
}

/// Wandelt Web-Mercator-Weltpixel beim gleichen Zoom zurück in geografische Koordinaten.
///
/// Parameter: Vue x, y, zoom; Dart Offset point, zoom. Rückgabe synchron TxCoordinate mit lat/lng in Grad; denselben Zoom wie bei txProject verwenden.
///
/// Converts Web Mercator world pixels back to geographic coordinates at the same zoom.
///
/// Parameters: Vue x, y, zoom; Dart Offset point, zoom. Synchronously returns TxCoordinate with lat/lng in degrees; use the same zoom as txProject.
///
/// ```dart
/// final pixel = txProject(const TxCoordinate(52.52, 13.405), 5);
/// print(txUnproject(pixel, 5).lat);
/// ```
TxCoordinate txUnproject(Offset point, double zoom) {
  final scale = 256 * math.pow(2, zoom),
      n = math.pi * (1 - 2 * point.dy / scale);
  return TxCoordinate(
    math.atan((math.exp(n) - math.exp(-n)) / 2) * 180 / math.pi,
    (point.dx / scale * 360 + 360) % 360 - 180,
  );
}

/// Karte mit Pan/Zoom, Markern und Routenlinien. Ohne tileUrl bleibt die Fläche neutral; Quellen und Attribution richtet die Anwendung ein.
///
/// Map with pan/zoom, markers and route lines. Without tileUrl the background is neutral; the application configures sources and attribution.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   return const TxMap(
///     markers: [TxMapMarker(52.52, 13.405, id: 'berlin', text: 'Berlin')],
///   );
/// }
/// ```
class TxMap extends StatefulWidget {
  /// Karte mit Pan/Zoom, Markern und Routenlinien. Ohne tileUrl bleibt die Fläche neutral; Quellen und Attribution richtet die Anwendung ein.
  ///
  /// Map with pan/zoom, markers and route lines. Without tileUrl the background is neutral; the application configures sources and attribution.
  const TxMap({
    super.key,
    this.center = const TxCoordinate(52.52, 13.405),
    this.zoom = 5,
    this.minZoom = 1,
    this.maxZoom = 19,
    this.tileUrl,
    this.attribution,
    this.markers = const [],
    this.dataSource,
    this.routes = const [],
    this.routeDataSource,
    this.onCenterChanged,
    this.onZoomChanged,
    this.onMarkerClick,
    this.height = 360,
    this.disabled = false,
  });
  /// Geografischer Kartenmittelpunkt.
  ///
  /// Geographic map center.
  final TxCoordinate center;
  /// zoom: Kartenzoomstufe.
  /// minZoom: Kleinste Zoomstufe.
  /// maxZoom: Größte Zoomstufe.
  ///
  /// zoom: Map zoom level.
  /// minZoom: Minimum zoom level.
  /// maxZoom: Maximum zoom level.
  final int zoom, minZoom, maxZoom;
  /// tileUrl: Kachel-URL mit Platzhaltern {z}/{x}/{y}.
  /// attribution: Quellen-/Lizenzhinweis des Kartenanbieters.
  ///
  /// tileUrl: Tile URL with {z}/{x}/{y} placeholders.
  /// attribution: Map provider attribution/license text.
  final String? tileUrl, attribution;
  /// Darzustellende Kartenmarker.
  ///
  /// Map markers to display.
  final List<TxMapMarker> markers;
  /// Darzustellende Routenlinien.
  ///
  /// Route lines to display.
  final List<TxMapRoute> routes;
  /// dataSource: Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  /// routeDataSource: Separate Datenquelle für Routenlinien.
  ///
  /// dataSource: List, configuration or DataSource instance; takes precedence over items.
  /// routeDataSource: Separate data source for route lines.
  final Object? dataSource, routeDataSource;
  /// Meldet center; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports center; update controlled state in the callback.
  final ValueChanged<TxCoordinate>? onCenterChanged;
  /// Meldet zoom; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports zoom; update controlled state in the callback.
  final ValueChanged<int>? onZoomChanged;
  /// Aktivierter TxMapMarker.
  ///
  /// Activated TxMapMarker.
  final ValueChanged<TxMapMarker>? onMarkerClick;
  /// Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln.
  ///
  /// Height; Vue numbers use pixels, Flutter uses logical pixels.
  final double height;
  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;
  @override
  State<TxMap> createState() => _TxMapState();
}

class _TxMapState extends State<TxMap> {
  late TxCoordinate _center = widget.center;
  late int _zoom = widget.zoom;
  TxMapMarker? _selected;
  @override
  void didUpdateWidget(covariant TxMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.center != widget.center) _center = widget.center;
    if (oldWidget.zoom != widget.zoom) _zoom = widget.zoom;
  }

  void _zoomTo(int value) {
    if (widget.disabled) return;
    setState(() => _zoom = value.clamp(widget.minZoom, widget.maxZoom));
    widget.onZoomChanged?.call(_zoom);
  }

  @override
  Widget build(BuildContext context) => TxDataSourceBuilder<TxMapMarker>(
    dataSource: widget.dataSource ?? widget.markers,
    builder: (context, markers, source) => TxDataSourceBuilder<TxMapRoute>(
      dataSource: widget.routeDataSource ?? widget.routes,
      builder: (context, routes, routeSource) => SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, widget.height),
                c = txProject(_center, _zoom.toDouble()),
                top = c - Offset(size.width / 2, size.height / 2),
                count = math.pow(2, _zoom).toInt();
            Offset pixel(TxCoordinate v) =>
                txProject(v, _zoom.toDouble()) - top;
            final tiles = <Widget>[];
            if (widget.tileUrl != null) {
              for (
                var x = (top.dx / 256).floor();
                x <= ((top.dx + size.width) / 256).floor();
                x++
              ) {
                for (
                  var y = math.max(0, (top.dy / 256).floor());
                  y <=
                      math.min(
                        count - 1,
                        ((top.dy + size.height) / 256).floor(),
                      );
                  y++
                ) {
                  final url = widget.tileUrl!
                      .replaceAll('{z}', '$_zoom')
                      .replaceAll('{x}', '${x % count}')
                      .replaceAll('{y}', '$y');
                  tiles.add(
                    Positioned(
                      left: x * 256 - top.dx,
                      top: y * 256 - top.dy,
                      width: 256,
                      height: 256,
                      child: Image.network(
                        url,
                        fit: BoxFit.fill,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xffdddddd),
                          child: Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
            }
            return Semantics(
              label: 'Interaktive Karte',
              child: ClipRect(
                child: GestureDetector(
                  onPanUpdate: widget.disabled
                      ? null
                      : (details) {
                          setState(
                            () => _center = txUnproject(
                              txProject(_center, _zoom.toDouble()) -
                                  details.delta,
                              _zoom.toDouble(),
                            ),
                          );
                          widget.onCenterChanged?.call(_center);
                        },
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Stack(
                      children: [
                        ...tiles,
                        if (widget.tileUrl == null)
                          const Center(
                            child: Text('Kachelquelle konfigurieren'),
                          ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _RoutePainter(routes, pixel),
                            ),
                          ),
                        ),
                        ...markers.map((marker) {
                          final v = pixel(marker);
                          return Positioned(
                            left: v.dx - 20,
                            top: v.dy - 20,
                            child: IconButton(
                              tooltip: marker.text ?? '${marker.id}',
                              onPressed: widget.disabled
                                  ? null
                                  : () {
                                      setState(() => _selected = marker);
                                      widget.onMarkerClick?.call(marker);
                                    },
                              icon: Icon(
                                Icons.location_on,
                                color:
                                    marker.color ??
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Column(
                            children: [
                              IconButton.filled(
                                tooltip: 'Vergrößern',
                                onPressed: widget.disabled
                                    ? null
                                    : () => _zoomTo(_zoom + 1),
                                icon: const Icon(Icons.add),
                              ),
                              IconButton.filled(
                                tooltip: 'Verkleinern',
                                onPressed: widget.disabled
                                    ? null
                                    : () => _zoomTo(_zoom - 1),
                                icon: const Icon(Icons.remove),
                              ),
                            ],
                          ),
                        ),
                        if (_selected != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Text(_selected!.text ?? '${_selected!.id}'),
                                    IconButton(
                                      tooltip: 'Schließen',
                                      onPressed: () =>
                                          setState(() => _selected = null),
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (widget.attribution != null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: ColoredBox(
                              color: Theme.of(context).colorScheme.surface,
                              child: Text(
                                widget.attribution!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.routes, this.pixel);
  final List<TxMapRoute> routes;
  final Offset Function(TxCoordinate) pixel;
  @override
  void paint(Canvas canvas, Size size) {
    for (final route in routes) {
      final path = Path();
      for (var i = 0; i < route.points.length; i++) {
        final p = pixel(route.points[i]);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = route.color
          ..strokeWidth = route.width
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => true;
}
