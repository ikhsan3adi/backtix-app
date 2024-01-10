import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
    final message = error?.response?.data['message'];

    return AlertDialog(
      titleTextStyle: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      title: Text(
        switch (statusCode) {
          400 => 'Validation error',
          401 => 'Authentication error',
          403 => 'Access denied',
          _ => error?.response?.data['error'] ?? 'Unknown error',
        },
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (error?.type) {
              DioExceptionType.badResponse => statusCode >= 500
                  ? Icons.cloud_off_outlined
                  : Icons.error_outline,
              DioExceptionType.sendTimeout ||
              DioExceptionType.receiveTimeout ||
              DioExceptionType.badCertificate ||
              DioExceptionType.connectionError ||
              DioExceptionType.connectionTimeout =>
                Icons.wifi_off_outlined,
              _ => Icons.bug_report_outlined,
            },
            color: context.colorScheme.error,
            size: 52,
          ),
          const SizedBox(height: 4),
          Text(
            message.runtimeType == List
                ? (message as List).join('\n')
                : (error?.response?.data['message'] ?? 'Unknown error'),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('OK'),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
