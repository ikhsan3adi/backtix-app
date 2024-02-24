import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      useSafeArea: true,
      context: context,
      builder: (_) => const DiscardChangesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      titleTextStyle: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      title: const Text('Discard Changes?'),
      content: const Text('Changes you made may not be saved'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Discard',
            style: TextStyle(color: context.colorScheme.error),
          ),
        ),
      ],
    );
  }
}
