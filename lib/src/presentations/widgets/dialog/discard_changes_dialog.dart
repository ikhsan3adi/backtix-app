import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';

class DiscardChangesDialog {
  static Future<bool?> show(BuildContext context) {
    return showAdaptiveDialog<bool>(
      useSafeArea: true,
      context: context,
      builder: (_) => const ConfirmDialog(
        title: 'Discard Changes?',
        contentText: 'Changes you made may not be saved',
        cancelText: 'Keep',
        confirmText: 'Discard',
      ),
    );
  }
}
