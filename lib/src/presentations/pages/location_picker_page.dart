import 'dart:math';

import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/data/services/remote/location_service.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerPage extends StatefulWidget {
  LocationPickerPage({
    super.key,
    double? latitude,
    double? longitude,
  }) : initialLocation = (latitude != null && longitude != null)
            ? LatLng(latitude, longitude)
            : const LatLng(-6.92165, 107.60693); // Alun-alun Bandung

  final LatLng initialLocation;

  @override
  PointToLatlngPage createState() => PointToLatlngPage();
}

class PointToLatlngPage extends State<LocationPickerPage> {
  final _debouncer = Debouncer();

  final _mapController = MapController();

  final _latLng = ValueNotifier<LatLng?>(null);
  final _address = ValueNotifier<String?>(null);

  static const double _pointSize = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updatePoint(context));
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _latLng.dispose();
    _address.dispose();
    _mapController.dispose();
    super.dispose();
  }

  double _getPointX(BuildContext context) => context.width / 2;
  double _getPointY(BuildContext context) => context.height / 2;

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: Constant.packageName,
        tileProvider: CancellableNetworkTileProvider(),
      );

  void updatePoint(BuildContext context) {
    _latLng.value = _mapController.camera.pointToLatLng(
      Point(_getPointX(context), _getPointY(context)),
    );
    setAddress();
  }

  void setAddress() {
    _address.value = null;
    _debouncer.run(() async {
      if (_latLng.value == null) return;
      _address.value = await LocationService.addressFromLatLong(_latLng.value!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          style: IconButton.styleFrom(backgroundColor: Colors.black38),
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onPositionChanged: (_, __) => updatePoint(context),
              initialCenter: widget.initialLocation,
            ),
            children: [
              openStreetMapTileLayer,
            ],
          ),
          Positioned(
            top: _getPointY(context) - _pointSize + 2.5,
            left: _getPointX(context) - _pointSize / 2,
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                size: _pointSize,
                color: Colors.red[600],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ResponsivePadding(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder(
                valueListenable: _address,
                builder: (_, address, __) {
                  return Chip(
                    label: Text(
                      address ?? 'Loading...',
                      maxLines: 4,
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                onPressed: () {
                  if (_latLng.value == null) return;
                  context.pop(_latLng.value);
                },
                icon: const Icon(Icons.location_searching),
                label: const Text('Select Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
