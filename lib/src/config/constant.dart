import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo _packageInfo = GetIt.I<PackageInfo>();

class Constant {
  static String appName = 'BackTix';
  static String appLabel = _packageInfo.appName;
  static String packageName = _packageInfo.packageName;
  static String version = _packageInfo.version;
  static String buildNumber = _packageInfo.buildNumber;

  static String apiBaseUrl = dotenv.env['API_BASE_URL']!;

  static String googleClientId = dotenv.env['GOOGLE_CLIENT_ID']!;
  static String googleServerClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID']!;

  static String midtransMerchantBaseUrl = dotenv.env['MIDTRANS_MERCHANT_BASE_URL']!;
  static String midtransClientKey = kDebugMode
      ? dotenv.env['MIDTRANS_CLIENT_KEY_SANDBOX']!
      : dotenv.env['MIDTRANS_CLIENT_KEY']!;

  static String googleMapsUrlFromLatLong({
    required double lat,
    required double long,
  }) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
  }

  static const String locale = 'id_ID';

  /// example: IDR 1.2k
  static String toSimpleCurrency(dynamic numberOrString) {
    return NumberFormat.compactSimpleCurrency(
      // locale: Intl.getCurrentLocale(),
      locale: locale,
    ).format(numberOrString);
  }

  /// example: IDR 1.200,00
  static String toCurrency(dynamic numberOrString) {
    return NumberFormat.currency(
      // locale: Intl.getCurrentLocale(),
      locale: locale,
    ).format(numberOrString);
  }
}
