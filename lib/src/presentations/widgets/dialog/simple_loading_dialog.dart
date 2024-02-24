import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

bool _isLoading = false;

class SimpleLoadingDialog extends StatelessWidget {
  const SimpleLoadingDialog({super.key});

  static void show(BuildContext context) async {
    _isLoading = true;
    return await showAdaptiveDialog<void>(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      builder: (_) => const SimpleLoadingDialog(),
    );
  }

  static void hide(BuildContext context) {
    if (_isLoading) {
      _isLoading = false;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SpinKitFadingFour(color: Colors.white);
  }
}
