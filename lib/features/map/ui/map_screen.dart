import 'dart:async';
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

  // Tamaño de respaldo (tamaño real que indicaste: 6527x6400)
  static const Size _fallbackSize = Size(7700, 6400);

  ImageStream? _stream;
  ImageStreamListener? _listener;

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

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.map)),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              crs: const CrsSimple(),
              initialCenter: LatLng(scaled.height / 2, scaled.width / 2),
              initialZoom: 0,
              // Aseguramos que la rotación sea 0 desde el inicio
              initialRotation: 0,
              minZoom: -4,
              maxZoom: 4,
              // Deshabilitamos rotación y el gesto de arrastre con doble toque para zoom
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all &
                ~InteractiveFlag.rotate &
                ~InteractiveFlag.doubleTapDragZoom,
              ),
              cameraConstraint: CameraConstraint.contain(bounds: bounds),
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
            ],
          ),
          if (_assetLoadFailed)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _ErrorBanner(path: _assetPath),
            ),
        ],
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