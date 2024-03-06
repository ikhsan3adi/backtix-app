import 'package:backtix_app/src/config/constant.dart';
import 'package:intl/intl.dart';

export 'currency_input_formatter.dart';
export 'debouncer.dart';
export 'file_picker.dart';

class Utils {
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
      locale: Constant.locale,
    ).format(numberOrString);
  }

  /// example: IDR 1.200
  static String toCurrency(dynamic numberOrString) {
    return NumberFormat.currency(
      // locale: Intl.getCurrentLocale(),
      locale: Constant.locale,
      decimalDigits: 0,
    ).format(numberOrString);
  }
}
