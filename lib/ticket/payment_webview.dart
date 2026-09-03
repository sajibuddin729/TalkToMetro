import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// SSLCommerz In-App Payment Gateway WebView Screen
/// Displays the official SSLCommerz Gateway Page directly inside the app.
/// Intercepts redirect URLs (success, fail, cancel) and extracts validation parameters (val_id).
class SSLCommerzWebViewPage extends StatefulWidget {
  final String initialUrl;
  final String successUrl;
  final String failUrl;
  final String cancelUrl;

  const SSLCommerzWebViewPage({
    super.key,
    required this.initialUrl,
    required this.successUrl,
    required this.failUrl,
    required this.cancelUrl,
  });

  @override
  State<SSLCommerzWebViewPage> createState() => _SSLCommerzWebViewPageState();
}

class _SSLCommerzWebViewPageState extends State<SSLCommerzWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
            _checkNavigationUrl(url);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
            _checkNavigationUrl(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            final String url = request.url;
            final bool handled = _checkNavigationUrl(url);
            if (handled) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  /// Intercept SSLCommerz callback redirects
  bool _checkNavigationUrl(String url) {
    if (url.startsWith(widget.successUrl)) {
      final uri = Uri.parse(url);
      final valId = uri.queryParameters['val_id'] ?? '';
      final tranId = uri.queryParameters['tran_id'] ?? '';
      final cardType = uri.queryParameters['card_type'] ?? '';

      Navigator.of(context).pop({
        'status': 'SUCCESS',
        'val_id': valId,
        'tran_id': tranId,
        'card_type': cardType,
      });
      return true;
    } else if (url.startsWith(widget.failUrl)) {
      Navigator.of(context).pop({
        'status': 'FAILED',
        'message': 'Payment failed on SSLCommerz gateway.',
      });
      return true;
    } else if (url.startsWith(widget.cancelUrl)) {
      Navigator.of(context).pop({
        'status': 'CANCELLED',
        'message': 'Payment cancelled by user.',
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'SSLCommerz Gateway',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop({
              'status': 'CANCELLED',
              'message': 'Payment cancelled by user.',
            });
          },
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoading || _progress < 1.0)
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: Colors.grey.shade200,
                color: Colors.green.shade700,
                minHeight: 3,
              ),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
