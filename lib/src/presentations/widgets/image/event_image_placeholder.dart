import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventImagePlaceholder extends StatelessWidget {
  const EventImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorScheme.primaryContainer,
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.calendar,
          color: context.colorScheme.primary,
          size: 48,
        ),
      ),
    );
  }
}
