import 'dart:io';

import 'package:backtix_app/src/config/constant.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_geocoding/nominatim_geocoding.dart';

class LocationService {
  /// [Platform.operatingSystem] that supported by [Geolocator]
  static bool supportDeviceLocation = !Platform.isLinux;

  /// [Platform.operatingSystem] that supported by [geocoding]
  static bool geocodingSupported = Platform.isAndroid || Platform.isIOS;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      if (!(await Geolocator.openLocationSettings())) {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception('Location services are disabled.');
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  /// Use [NominatimGeocoding] if [Platform.operatingSystem] is not supported by [geocoding]
  static Future<String?> addressFromLatLong(LatLng latLng) async {
    if (!geocodingSupported) {
      try {
        final geocoding = await NominatimGeocoding.to.reverseGeoCoding(
          Coordinate(latitude: latLng.latitude, longitude: latLng.longitude),
          locale: Locale.ID,
        );
        return geocoding.address.requestStr;
      } catch (_) {
        return null;
      }
    }
    final placeMark = (await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
      localeIdentifier: Constant.locale,
    ))[0];
    return '${placeMark.name}, ${placeMark.street}, ${placeMark.thoroughfare}, ${placeMark.subThoroughfare}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.subAdministrativeArea} ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}';
  }
}
