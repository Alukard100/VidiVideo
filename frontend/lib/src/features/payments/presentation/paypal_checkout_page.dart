import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalCheckoutPage extends StatefulWidget {
  const PayPalCheckoutPage({
    required this.approvalUrl,
    super.key,
  });

  final String approvalUrl;

  @override
  State<PayPalCheckoutPage> createState() =>
      _PayPalCheckoutPageState();
}

class _PayPalCheckoutPageState
    extends State<PayPalCheckoutPage> {
  late final WebViewController _controller;

  bool _isLoading = true;

  static const _successUrl =
      'https://vidivideo.local/paypal/success';

  static const _cancelUrl =
      'https://vidivideo.local/paypal/cancel';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setBackgroundColor(
        Colors.white,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = true;
            });
          },

          onPageFinished: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = false;
            });
          },

          onNavigationRequest: (request) {
            final url = request.url;

            if (url.startsWith(_successUrl)) {
              Navigator.of(context).pop(true);

              return NavigationDecision.prevent;
            }

            if (url.startsWith(_cancelUrl)) {
              Navigator.of(context).pop(false);

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          onWebResourceError: (error) {
            if (error.isForMainFrame != true) {
              return;
            }

            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.approvalUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'PayPal Checkout',
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              _controller.reload();
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),

          if (_isLoading)
            const IgnorePointer(
              child: ColoredBox(
                color: Color(0x33FFFFFF),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}