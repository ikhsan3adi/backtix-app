import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:intl/intl.dart';

class Constant {
  static String apiBaseUrl = dotenv.env['API_BASE_URL']!;

  static String googleClientId = dotenv.env['GOOGLE_CLIENT_ID']!;
  static String googleServerClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID']!;

  static String midtransClientKey = dotenv.env['MIDTRANS_CLIENT_KEY']!;
  static String midtransMerchantBaseUrl = dotenv.env['MIDTRANS_MERCHANT_BASE_URL']!;

  static String googleMapsUrlFromLatLong({
    required double lat,
    required double long,
  }) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
  }

  /// example: IDR 1.2k
  static String toSimpleCurrency(dynamic numberOrString) {
    return NumberFormat.compactSimpleCurrency(
      // locale: Intl.getCurrentLocale(),
      locale: 'id_ID',
    ).format(numberOrString);
  }

  /// example: IDR 1.200,00
  static String toCurrency(dynamic numberOrString) {
    return NumberFormat.currency(
      // locale: Intl.getCurrentLocale(),
      locale: 'id_ID',
    ).format(numberOrString);
  }
}
