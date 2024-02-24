import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EventImageDescriptionDialog extends StatefulWidget {
  const EventImageDescriptionDialog({
    super.key,
    this.description,
  });

  final String? description;

  static Future<String?> show(BuildContext context, {String? description}) {
    return showAdaptiveDialog<String>(
      context: context,
      builder: (_) => EventImageDescriptionDialog(description: description),
    );
  }

  @override
  State<EventImageDescriptionDialog> createState() => _State();
}

class _State extends State<EventImageDescriptionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      titleTextStyle: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      title: const Text('Add image description'),
      content: CustomTextFormField(
        controller: _controller,
        minLines: 3,
        maxLength: 255,
        decoration: const InputDecoration(
          labelText: 'Image description',
          alignLabelWithHint: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.value.text),
          child: Text(
            'Done',
            style: TextStyle(color: context.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
