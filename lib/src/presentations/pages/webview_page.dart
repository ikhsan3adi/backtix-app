import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

final bool _supported =
    Platform.isAndroid || Platform.isIOS || Platform.isMacOS || kIsWeb;

class WebViewPage extends StatelessWidget {
  const WebViewPage({super.key, required this.url, this.title});

  final String url;
  final String? title;

  /// if supported, open inappwebview, otherwise launch url on external browser
  static Future<void> show(
    BuildContext context, {
    required String url,
    String? title,
  }) async {
    if (_supported) {
      return await showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (_) => WebViewPage(
          url: url,
          title: title,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await launchUrl(Uri.parse(url));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title ?? 'WebView', overflow: TextOverflow.ellipsis),
      ),
      body: _supported
          ? InAppWebView(initialUrlRequest: URLRequest(url: WebUri(url)))
          : Center(
              child: Text(
                'WebView not supported on ${Platform.operatingSystem}\nUrl: $url',
              ),
            ),
    );
  }
}
