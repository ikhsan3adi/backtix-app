import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key, this.error});

  final DioException? error;

  static show(
    BuildContext context,
    DioException? error,
  ) {
    return showDialog(
      context: context,
      builder: (_) => ErrorDialog(error: error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusCode = error?.response?.statusCode ?? 0;

    return AlertDialog(
      title: Text(
        switch (statusCode) {
          400 => 'Validation error',
          401 => 'Authentication error',
          403 => 'Access denied',
          406 => 'Not acceptable',
          409 => 'Not available',
          500 => 'Server error',
          _ => 'Unknown error',
        },
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusCode >= 500 ? Icons.cloud_off_outlined : Icons.error_outline,
            color: context.colorScheme.error,
            size: 48,
          ),
          Text(
            error?.response?.data['message'] ?? 'Unknown error',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('OK'),
        )
      ],
    );
  }
}
