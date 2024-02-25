import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    this.title = 'Confirmation',
    this.contentText = 'Are you sure?',
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.onCancel,
    this.onConfirm,
  });

  static Future<bool?> show(BuildContext context) async {
    return await showAdaptiveDialog(
      useSafeArea: true,
      context: context,
      builder: (_) => const ConfirmDialog(),
    );
  }

  final String title;
  final String contentText;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      titleTextStyle: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      title: Text(title),
      content: Text(contentText),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: onConfirm ?? () => Navigator.pop(context, true),
          child: Text(
            confirmText,
            style: TextStyle(color: context.colorScheme.error),
          ),
        ),
      ],
    );
  }
}
