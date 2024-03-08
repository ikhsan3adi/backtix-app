import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final formatter = NumberFormat.simpleCurrency(
    locale: Constant.locale,
    decimalDigits: 0,
    name: '',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) return newValue;

    final double unformatted = Utils.unformatCurrency(newValue.text);
    final String newText = formatter.format(unformatted);

    final int unformattedStrLen = unformatted.toInt().toString().length;
    final int oldUnformattedStrLen =
        Utils.unformatCurrency(oldValue.text).toInt().toString().length;
    final bool isDeleting = oldUnformattedStrLen > unformattedStrLen;

    final int offset = newValue.selection.extent.offset;
    int newOffset = offset;

    if (isDeleting && unformattedStrLen % 3 == 0) {
      newOffset--;
    } else if (!isDeleting &&
        (unformattedStrLen > 1 && (unformattedStrLen - 1) % 3 == 0)) {
      newOffset++;
    }

    if (newOffset > newText.length) newOffset = newText.length;
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
