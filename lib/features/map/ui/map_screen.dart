import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../l10n/l10n_extension.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const String _assetPath = 'lib/assets/maps/FullMap.png';

  Size? _imageSize;
  bool _assetLoadFailed = false;

  // Fallback logical size to avoid perpetual loading
  // Actual image size is 6527 x 6400
  static const Size _fallbackSize = Size(6527, 6400);

  @override
  void initState() {
    super.initState();
    // Non-blocking precache (won't throw)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(_assetPath), context).catchError((_) {});
    });
    _resolveImageSize();
  }

  void _resolveImageSize() {
    final ImageProvider provider = const AssetImage(_assetPath);
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, _) {
        final img = imageInfo.image;
        setState(() {
          _imageSize = Size(img.width.toDouble(), img.height.toDouble());
          _assetLoadFailed = false;
        });
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        setState(() {
          _assetLoadFailed = true;
          // keep _imageSize null so we use fallback
        });
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final Size logicalSize = _imageSize ?? _fallbackSize;
    final bounds = LatLngBounds(
      const LatLng(0, 0),
      LatLng(logicalSize.height, logicalSize.width),
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.map)),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              crs: const CrsSimple(),
              initialCenter: LatLng(logicalSize.height / 2, logicalSize.width / 2),
              initialZoom: 0,
              minZoom: -4,
              maxZoom: 4,
              interactionOptions: const InteractionOptions(
                flags: ~InteractiveFlag.doubleTapDragZoom,
              ),
              // Apply bounds even with fallback; it will update naturally when _imageSize arrives
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
                'No se pudo cargar el mapa. Asegúrate de que el asset exista: $path',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
