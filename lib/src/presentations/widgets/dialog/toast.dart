import 'dart:io';

import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toast {
  static final bool _supported = Platform.isAndroid || Platform.isIOS || kIsWeb;

  /// show [SnackBar] if [Platform.operatingSystem] is not supported
  /// and providing [BuildContext] parameter
  static Future<bool?> show(
    BuildContext? context, {
    required String msg,
    bool cancelActive = true,
  }) async {
    if (!_supported) return context?.showSimpleTextSnackBar(msg);

    if (cancelActive) await cancel();
    return await Fluttertoast.showToast(msg: msg);
  }

  static Future<bool?> cancel() async => await Fluttertoast.cancel();
}
