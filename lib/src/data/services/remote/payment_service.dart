import 'dart:io';

import 'package:backtix_app/src/data/models/purchase/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  /// [midtransSdk] not null when [isSdkSupported] is true
  PaymentService({MidtransSDK? midtransSdk}) : _midtransSdk = midtransSdk {
    _midtransSdk?.setTransactionFinishedCallback((result) {
      if (kDebugMode) print(result.toJson());
    });
  }

  final MidtransSDK? _midtransSdk;

  /// supported on Android & IOS
  static final isSdkSupported = Platform.isAndroid || Platform.isIOS;

  Future<bool> startPaymentFlow(TransactionModel transaction) async {
    if (isSdkSupported && _midtransSdk != null) {
      try {
        await _midtransSdk.setUIKitCustomSetting(
          skipCustomerDetailsPages: true,
        );
        await _midtransSdk.startPaymentUiFlow(token: transaction.token);
        return true;
      } catch (e) {
        if (kDebugMode) print(e.toString());
        return false;
      }
    }

    if (transaction.redirectUrl == null) return false;

    return await launchUrl(Uri.parse(transaction.redirectUrl!));
  }
}
