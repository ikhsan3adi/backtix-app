import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotFoundWidget extends StatelessWidget {
  const NotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          FontAwesomeIcons.faceMehBlank,
          color: context.theme.disabledColor,
          size: 52,
        ),
        const SizedBox(height: 8),
        Text(
          'Not found',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.disabledColor,
          ),
        ),
      ],
    );
  }
}
