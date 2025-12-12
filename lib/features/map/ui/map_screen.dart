import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../l10n/l10n_extension.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Ruta confirmada por ti
  static const String _assetPath = 'lib/assets/maps/FullMap.png';

  Size? _imageSize; // tamaño real cuando se resuelva
  bool _assetLoadFailed = false;

  static const Size _fallbackSize = Size(7700, 6400);

  ImageStream? _stream;
  ImageStreamListener? _listener;

  // Estado de selección
  bool _selectMode = false;
  LatLng? _p1;
  LatLng? _p2;

  // Estado de interacción con rutas
  int? _activeRouteId; // resalta la ruta tocada

  // Áreas predefinidas (P1/P2) con color y nombre "tipo Pokémon"
  late final List<_RouteArea> _routes = [
    _RouteArea(1, 'Ruta 1', const LatLng(31.166, 18.900), const LatLng(40.200, 13.509), const Color(0xFF1E88E5)),
    _RouteArea(2, 'Ruta 2', const LatLng(67.553, 13.506), const LatLng(49.521, 18.889), const Color(0xFFD81B60)),
    _RouteArea(3, 'Ruta 3', const LatLng(74.251, 21.599), const LatLng(69.756, 40.504), const Color(0xFF43A047)),
    _RouteArea(4, 'Ruta 4', const LatLng(78.729, 35.097), const LatLng(74.215, 59.409), const Color(0xFFFB8C00)),
    _RouteArea(5, 'Ruta 5', const LatLng(73.032, 60.719), const LatLng(63.082, 67.254), const Color(0xFF8E24AA)),
    _RouteArea(6, 'Ruta 6', const LatLng(54.477, 62.149), const LatLng(45.474, 67.495), const Color(0xFF5E35B1)),
    _RouteArea(7, 'Ruta 7', const LatLng(60.723, 54.009), const LatLng(56.227, 59.415), const Color(0xFF039BE5)),
    _RouteArea(8, 'Ruta 8', const LatLng(60.743, 72.374), const LatLng(56.237, 86.415), const Color(0xFF00897B)),
    _RouteArea(9, 'Ruta 9', const LatLng(78.776, 70.173), const LatLng(74.213, 86.414), const Color(0xFF7CB342)),
    _RouteArea(10, 'Ruta 10', const LatLng(78.776, 86.455), const LatLng(67.449, 91.808), const Color(0xFFFDD835)),
    _RouteArea(11, 'Ruta 11', const LatLng(42.732, 70.181), const LatLng(38.209, 86.441), const Color(0xFFFB8C00)),
    _RouteArea(12, 'Ruta 12', const LatLng(56.243, 86.416), const LatLng(29.162, 91.805), const Color(0xFFE53935)),
    _RouteArea(13, 'Ruta 13', const LatLng(24.781, 91.797), const LatLng(29.230, 75.587), const Color(0xFF6D4C41)),
    _RouteArea(14, 'Ruta 14', const LatLng(29.216, 70.208), const LatLng(15.730, 75.606), const Color(0xFF546E7A)),
    _RouteArea(15, 'Ruta 15', const LatLng(15.730, 70.217), const LatLng(20.204, 54.006), const Color(0xFF26A69A)),
    _RouteArea(16, 'Ruta 16', const LatLng(60.753, 40.520), const LatLng(57.313, 29.716), const Color(0xFFAB47BC)),
    _RouteArea(17, 'Ruta 17', const LatLng(57.288, 29.716), const LatLng(20.244, 35.122), const Color(0xFF29B6F6)),
    _RouteArea(18, 'Ruta 18', const LatLng(20.219, 29.707), const LatLng(15.772, 40.678), const Color(0xFFFF7043)),
    _RouteArea(19, 'Ruta 19', const LatLng(13.495, 45.951), const LatLng(0.018, 51.290), const Color(0xFF9CCC65)),
    _RouteArea(20, 'Ruta 20', const LatLng(4.474, 45.926), const LatLng(0.018, 18.703), const Color(0xFFA1887F)),
    _RouteArea(21, 'Ruta 21', const LatLng(4.499, 18.878), const LatLng(26.924, 13.539), const Color(0xFF8D6E63)),
    _RouteArea(22, 'Ruta 22', const LatLng(47.222, 10.823), const LatLng(41.842, 0.008), const Color(0xFF78909C)),
    _RouteArea(23, 'Ruta 23', const LatLng(47.231, 5.398), const LatLng(87.743, 0.008), const Color(0xFF455A64)),
  ];

  @override
  void initState() {
    super.initState();
    // Precarga no bloqueante
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(_assetPath), context).catchError((_) {});
    });
    _resolveImageSize();
  }

  void _resolveImageSize() {
    final provider = const AssetImage(_assetPath);
    _stream = provider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
          (imageInfo, _) {
        final img = imageInfo.image;
        if (!mounted) return;
        setState(() {
          _imageSize = Size(img.width.toDouble(), img.height.toDouble());
          _assetLoadFailed = false;
        });
        _removeListener();
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        setState(() {
          _assetLoadFailed = true; // usaremos fallback
        });
        _removeListener();
      },
    );
    _stream!.addListener(_listener!);
  }

  void _removeListener() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  // Escala alto/ ancho de la imagen para que quepan en [-90,90] y [-180,180] respectivamente,
  // preservando la relación de aspecto (necesario por la validación de LatLngBounds).
  Size _scaledSize(Size original) {
    const double maxLat = 90.0;
    const double maxLng = 180.0;
    if (original.width <= 0 || original.height <= 0) {
      return const Size(1, 1);
    }
    final s = (maxLat / original.height).clamp(0.0, double.infinity);
    final t = (maxLng / original.width).clamp(0.0, double.infinity);
    final scale = s < t ? s : t; // más restrictivo
    return Size(original.width * scale, original.height * scale);
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = _imageSize ?? _fallbackSize;
    final scaled = _scaledSize(base);

    // Para CrsSimple usamos (lat, lng) como (y, x) en unidades arbitrarias,
    // pero dentro de los límites válidos.
    final bounds = LatLngBounds(
      const LatLng(0, 0),
      LatLng(scaled.height, scaled.width),
    );

    // Construye capas de selección si hay puntos
    final List<Widget> selectionLayers = [];
    final rect = _computeRect(_p1, _p2);
    if (rect != null) {
      selectionLayers.add(PolygonLayer(
        polygons: [
          Polygon(
            points: [
              LatLng(rect.top, rect.left),
              LatLng(rect.top, rect.right),
              LatLng(rect.bottom, rect.right),
              LatLng(rect.bottom, rect.left),
            ],
            color: Colors.blueAccent.withOpacity(0.18),
            borderColor: Colors.blueAccent,
            borderStrokeWidth: 3.5,
          ),
        ],
      ));
    }
    if (_p1 != null || _p2 != null) {
      final markers = <Marker>[];
      if (_p1 != null) {
        markers.add(
          Marker(
            point: _p1!,
            width: 28,
            height: 28,
            child: const _Pin(label: 'P1'),
          ),
        );
      }
      if (_p2 != null) {
        markers.add(
          Marker(
            point: _p2!,
            width: 28,
            height: 28,
            child: const _Pin(label: 'P2'),
          ),
        );
      }
      selectionLayers.add(MarkerLayer(markers: markers));
    }

    // Polígonos de rutas coloreados y etiquetados dentro del área, centrados y con tamaño dinámico
    final routesPolygons = _routes.map((r) {
      final areaRect = _computeRect(r.p1, r.p2)!;
      final points = [
        LatLng(areaRect.top, areaRect.left),
        LatLng(areaRect.top, areaRect.right),
        LatLng(areaRect.bottom, areaRect.right),
        LatLng(areaRect.bottom, areaRect.left),
      ];

      final double fontSize = _labelFontSizeForRect(areaRect);
      final bool isActive = r.id == _activeRouteId;

      return Polygon(
        points: points,
        color: (isActive ? r.color.withOpacity(0.32) : r.color.withOpacity(0.22)),
        borderColor: isActive ? Colors.white : r.color,
        borderStrokeWidth: isActive ? 3.5 : 3.0,
        isFilled: true,
        label: r.name,
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 0)),
            Shadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 0)),
          ],
        ),
        labelPlacement: PolygonLabelPlacement.centroid,
      );
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1420), Color(0xFF0B0E16)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              children: [
                // Mapa dentro de una "card" con bordes redondeados (UI consistente)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF101316),
                      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        crs: const CrsSimple(),
                        initialCenter: LatLng(scaled.height / 2, scaled.width / 2),
                        initialZoom: 0,
                        initialRotation: 0,
                        minZoom: -4,
                        maxZoom: 4,
                        // Fondo del mapa en gris oscuro para que las partes transparentes del PNG se vean oscuras
                        backgroundColor: const Color(0xFF121417),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all &
                          ~InteractiveFlag.rotate &
                          ~InteractiveFlag.doubleTapDragZoom,
                        ),
                        cameraConstraint: CameraConstraint.contain(bounds: bounds),
                        onTap: (tapPos, latLng) {
                          // Si estamos en modo selección, manejamos P1/P2
                          if (_selectMode) {
                            setState(() {
                              if (_p1 == null) {
                                _p1 = _clampToBounds(latLng, bounds);
                              } else if (_p2 == null) {
                                _p2 = _clampToBounds(latLng, bounds);
                              } else {
                                _p1 = _clampToBounds(latLng, bounds);
                                _p2 = null;
                              }
                            });
                            return;
                          }

                          // Si NO estamos en modo selección, hacemos las áreas "tappables"
                          // Buscamos si el tap cae dentro de alguna ruta (rectángulo del área)
                          for (final r in _routes) {
                            final rect = _computeRect(r.p1, r.p2)!;
                            final lat = latLng.latitude;
                            final lng = latLng.longitude;
                            final inside = lat >= rect.top &&
                                lat <= rect.bottom &&
                                lng >= rect.left &&
                                lng <= rect.right;
                            if (inside) {
                              setState(() {
                                _activeRouteId = r.id;
                              });
                              _showRouteSheet(context, r);
                              break;
                            }
                          }
                        },
                      ),
                      children: [
                        OverlayImageLayer(
                          overlayImages: [
                            OverlayImage(
                              bounds: bounds,
                              opacity: 1.0,
                              imageProvider: const AssetImage(_assetPath),
                            ),
                          ],
                        ),

                        // Polígonos de rutas (coloreados y etiquetados)
                        PolygonLayer(polygons: routesPolygons),

                        // Capas de selección interactiva del usuario
                        ...selectionLayers,
                      ],
                    ),
                  ),
                ),

                // Header moderno
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _ModernHeader(
                    title: context.l10n.map,
                  ),
                ),

                // Panel de acciones (modo selección)
                Positioned(
                  top: 88,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _selectMode
                                  ? [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]
                                  : [const Color(0xFF1E2A78), const Color(0xFF283593)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectMode = !_selectMode;
                                if (!_selectMode) {
                                  _p1 = null;
                                  _p2 = null;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectMode ? Icons.close : Icons.crop_free,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectMode ? 'Salir selección' : 'Seleccionar área',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_assetLoadFailed) _ErrorBanner(path: _assetPath),
                    ],
                  ),
                ),

                // Banner informativo con coordenadas cuando haya puntos
                if (_p1 != null || _p2 != null)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: _InfoBanner(
                      p1: _p1,
                      p2: _p2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRouteSheet(BuildContext context, _RouteArea r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121417),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    r.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Has tocado el área seleccionada.',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Garantiza que el punto caiga dentro de bounds (por seguridad)
  LatLng _clampToBounds(LatLng p, LatLngBounds b) {
    final lat = p.latitude.clamp(b.south, b.north);
    final lng = p.longitude.clamp(b.west, b.east);
    return LatLng(lat.toDouble(), lng.toDouble());
  }

  // Calcula rectángulo eje-alineado entre dos puntos (lat = Y, lng = X)
  _AxisRect? _computeRect(LatLng? a, LatLng? b) {
    if (a == null || b == null) return null;
    final top = mathMin(a.latitude, b.latitude);
    final bottom = mathMax(a.latitude, b.latitude);
    final left = mathMin(a.longitude, b.longitude);
    final right = mathMax(a.longitude, b.longitude);
    return _AxisRect(top: top, bottom: bottom, left: left, right: right);
  }

  // Tamaño de fuente dinámico según dimensiones del área (en unidades del mapa CRS simple)
  double _labelFontSizeForRect(_AxisRect rect) {
    final minDim = math.min(rect.width, rect.height);
    // Ajuste empírico: escala por el tamaño mínimo del rectángulo.
    // Clampa para que nunca sea demasiado pequeño ni enorme.
    return minDim.clamp(9.0, 22.0);
  }

  double mathMin(double x, double y) => x < y ? x : y;
  double mathMax(double x, double y) => x > y ? x : y;
}

class _ModernHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _ModernHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  height: 62,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF5C6BC0), // indigo lighten
                        Color(0xFF26C6DA), // cyan
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      _HeaderIconButton(
                        icon: Icons.my_location_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 6),
                      _HeaderIconButton(
                        icon: Icons.more_horiz_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _HeaderIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _AxisRect {
  final double top;
  final double bottom;
  final double left;
  final double right;
  const _AxisRect({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  double get width => (right - left).abs();
  double get height => (bottom - top).abs();
}

class _Pin extends StatelessWidget {
  final String label;
  const _Pin({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.location_on, color: Colors.red.shade600, size: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final LatLng? p1;
  final LatLng? p2;

  const _InfoBanner({required this.p1, required this.p2});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBoth = p1 != null && p2 != null;

    String coordsLine(LatLng? p, String name) {
      if (p == null) return '$name: —';
      // lat = Y, lng = X (CRS simple), con más precisión
      return '$name: (lat=${p.latitude.toStringAsFixed(3)}, lng=${p.longitude.toStringAsFixed(3)})';
    }

    String areaLine() {
      if (!hasBoth) return '';
      final w = (p2!.longitude - p1!.longitude).abs();
      final h = (p2!.latitude - p1!.latitude).abs();
      return 'Área: ancho=${w.toStringAsFixed(3)}, alto=${h.toStringAsFixed(3)} (unidades mapa)';
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.stacked_line_chart, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Selección de área',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(coordsLine(p1, 'P1'))),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(coordsLine(p2, 'P2'))),
                ],
              ),
              if (hasBoth) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.crop_square, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(areaLine())),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String path;
  const _ErrorBanner({required this.path});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No se pudo cargar el mapa. Verifica que exista el asset: $path',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteArea {
  final int id;
  final String name;
  final LatLng p1;
  final LatLng p2;
  final Color color;
  const _RouteArea(this.id, this.name, this.p1, this.p2, this.color);
}