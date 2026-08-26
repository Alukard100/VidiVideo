import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalOnboardingPage
    extends StatefulWidget {
  const PayPalOnboardingPage({
    required this.onboardingUrl,
    super.key,
  });

  final String onboardingUrl;

  @override
  State<PayPalOnboardingPage>
      createState() =>
          _PayPalOnboardingPageState();
}

class _PayPalOnboardingPageState
    extends State<PayPalOnboardingPage> {
  late final WebViewController _controller;

  bool _isLoading = true;

  static const _successUrl =
      'https://vidivideo.local/paypal/onboarding-success';

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
          onNavigationRequest:
              (request) {
            if (request.url.startsWith(
                _successUrl)) {
              Navigator.of(context)
                  .pop(true);

              return NavigationDecision
                  .prevent;
            }

            return NavigationDecision
                .navigate;
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame !=
                true) {
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
        Uri.parse(
            widget.onboardingUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Connect PayPal'),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF111827),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          if (_isLoading)
            const Center(
              child:
                  CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}