import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

bool _isError = false;

class ErrorDialog {
  static void show(
    BuildContext context,
    Exception error,
  ) async {
    if (!_isError) {
      _isError = true;
      return await showAdaptiveDialog(
        context: context,
        useSafeArea: true,
        builder: (_) {
          if (error.runtimeType == DioException) {
            return _NetworkErrorDialog(error as DioException);
          }

          return _DefaultErrorDialog(error);
        },
      );
    }
  }

  static void hide(BuildContext context) {
    if (_isError) {
      _isError = false;
      Navigator.pop(context);
    }
  }
}

class _NetworkErrorDialog extends StatelessWidget {
  const _NetworkErrorDialog(this.error);

  final DioException error;

  @override
  Widget build(BuildContext context) {
    final statusCode = error.response?.statusCode ?? 0;
    final message = error.response?.data['message'] ?? 'An error has occurred';

    return AlertDialog.adaptive(
      titleTextStyle: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      title: Text(
        switch (error.type) {
          DioExceptionType.sendTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.badCertificate ||
          DioExceptionType.connectionError ||
          DioExceptionType.connectionTimeout =>
            'Connection error',
          _ => switch (statusCode) {
              400 => 'Validation error',
              401 => 'Authentication error',
              403 => 'Access denied',
              _ => error.response?.data['error'] ?? 'Unknown error',
            },
        },
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (error.type) {
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
            switch (error.type) {
              DioExceptionType.sendTimeout ||
              DioExceptionType.receiveTimeout ||
              DioExceptionType.badCertificate ||
              DioExceptionType.connectionError ||
              DioExceptionType.connectionTimeout =>
                'Connection error',
              _ => message.runtimeType == List
                  ? (message as List).join('\n')
                  : (message ?? 'Unknown error'),
            },
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
                onPressed: () {
                  _isError = false;
                  Navigator.pop(context);
                },
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

class _DefaultErrorDialog extends StatelessWidget {
  const _DefaultErrorDialog(this.error);

  final dynamic error;

  @override
  Widget build(BuildContext context) {
    final message = (error as dynamic).message ?? error.toString();

    return AlertDialog.adaptive(
      titleTextStyle: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      title: const Text('An error has occurred'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.close_outlined,
            color: context.colorScheme.error,
            size: 52,
          ),
          const SizedBox(height: 4),
          Text(
            message ?? 'Unknown error',
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
                onPressed: () {
                  _isError = false;
                  Navigator.pop(context);
                },
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
