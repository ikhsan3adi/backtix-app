import 'dart:io';

import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';

class UnsupportedPlatformPage extends StatelessWidget {
  const UnsupportedPlatformPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Unsupported'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_outlined,
            color: context.theme.disabledColor,
            size: 52,
          ),
          const SizedBox(height: 8),
          Text(
            'Unsupported on ${Platform.operatingSystem}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
