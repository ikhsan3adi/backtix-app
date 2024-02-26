import 'dart:async';
import 'dart:io';

import 'package:backtix_app/src/data/models/purchase/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  /// supported on Android & IOS
  static final isSdkSupported = Platform.isAndroid || Platform.isIOS;

  final MidtransSDK? _midtransSdk;

  /// [midtransSdk] not null when [isSdkSupported] is true
  PaymentService({MidtransSDK? midtransSdk}) : _midtransSdk = midtransSdk {
    _midtransSdk?.setUIKitCustomSetting(skipCustomerDetailsPages: true);
    _midtransSdk?.setTransactionFinishedCallback((result) {
      _completer?.complete(!result.isTransactionCanceled);
      if (kDebugMode) print(result.toJson());
    });
  }

  Completer<bool>? _completer;

  Future<bool> startPaymentFlow(TransactionModel transaction) async {
    if (isSdkSupported && _midtransSdk != null) {
      try {
        _completer = Completer<bool>();

        await _midtransSdk.startPaymentUiFlow(token: transaction.token);

        return await _completer?.future ?? false;
      } catch (e) {
        if (kDebugMode) print(e.toString());
        return false;
      }
    }

    if (transaction.redirectUrl == null) return false;

    return await launchUrl(Uri.parse(transaction.redirectUrl!));
  }
}
