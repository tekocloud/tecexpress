import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'source.dart';

class TxCoordinate {
  const TxCoordinate(this.lat, this.lng);
  final double lat, lng;
}

class TxMapMarker extends TxCoordinate {
  const TxMapMarker(
    super.lat,
    super.lng, {
    required this.id,
    this.text,
    this.color,
  });
  final Object id;
  final String? text;
  final Color? color;
}

class TxMapRoute {
  const TxMapRoute({
    required this.id,
    required this.points,
    this.color = Colors.blue,
    this.width = 3,
  });
  final Object id;
  final List<TxCoordinate> points;
  final Color color;
  final double width;
}

abstract class TxGeoAdapter {
  Future<List<TxCoordinate>> geocode(
    String query, {
    TxCancellation? cancellation,
  });
  Future<List<TxCoordinate>> route(
    List<TxCoordinate> points, {
    TxCancellation? cancellation,
  });
}

Offset txProject(TxCoordinate point, double zoom) {
  final scale = 256 * math.pow(2, zoom),
      lat = point.lat.clamp(-85.05112878, 85.05112878) * math.pi / 180;
  return Offset(
    (point.lng + 180) / 360 * scale,
    (1 - math.log(math.tan(lat) + 1 / math.cos(lat)) / math.pi) / 2 * scale,
  );
}

TxCoordinate txUnproject(Offset point, double zoom) {
  final scale = 256 * math.pow(2, zoom),
      n = math.pi * (1 - 2 * point.dy / scale);
  return TxCoordinate(
    math.atan((math.exp(n) - math.exp(-n)) / 2) * 180 / math.pi,
    (point.dx / scale * 360 + 360) % 360 - 180,
  );
}

class TxMap extends StatefulWidget {
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
  final TxCoordinate center;
  final int zoom, minZoom, maxZoom;
  final String? tileUrl, attribution;
  final List<TxMapMarker> markers;
  final List<TxMapRoute> routes;
  final Object? dataSource, routeDataSource;
  final ValueChanged<TxCoordinate>? onCenterChanged;
  final ValueChanged<int>? onZoomChanged;
  final ValueChanged<TxMapMarker>? onMarkerClick;
  final double height;
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
