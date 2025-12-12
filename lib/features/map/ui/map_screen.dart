import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    _loadImageSize();
    // Optional precache for smoother first paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(_assetPath), context);
    });
  }

  Future<void> _loadImageSize() async {
    try {
      final ByteData data = await rootBundle.load(_assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Image image = await decodeImageFromList(bytes);
      if (mounted) {
        setState(() {
          _imageSize = Size(image.width.toDouble(), image.height.toDouble());
        });
      }
    } catch (_) {
      // If the asset is missing, keep _imageSize null and show an error UI below
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.map),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final size = _imageSize;
    if (size == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(context.l10n.loadingMap)
          ],
        ),
      );
    }

    final bounds = LatLngBounds(
      const LatLng(0, 0),
      LatLng(size.height, size.width),
    );

    return FlutterMap(
      options: MapOptions(
        crs: const CrsSimple(),
        initialCenter: LatLng(size.height / 2, size.width / 2),
        initialZoom: 0,
        minZoom: -4,
        maxZoom: 4,
        interactionOptions: const InteractionOptions(
          flags: ~InteractiveFlag.doubleTapDragZoom, // Disable double-tap-drag zoom for simpler interaction
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
    );
  }
}
