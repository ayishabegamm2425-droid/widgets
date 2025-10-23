import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TodayHistoryInlineWidget extends StatefulWidget {
  const TodayHistoryInlineWidget({Key? key}) : super(key: key);

  @override
  State<TodayHistoryInlineWidget> createState() => _TodayHistoryInlineWidgetState();
}

class _TodayHistoryInlineWidgetState extends State<TodayHistoryInlineWidget> {
  bool _isLoading = true;
  bool _hasError = false;

  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.red,
      height: 500, //  give height to avoid layout error
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (!_hasError)
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://9000-firebase-studio-1754972587182.cluster-isls3qj2gbd5qs4jkjqvhahfv6.cloudworkstations.dev/mobileresources/today-in-history"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    _isLoading = false;
                  });
                },
                onReceivedError: (controller, request, error) {
                  setState(() {
                    _hasError = true;
                    _isLoading = false;
                  });
                },
              ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_hasError)
              const Center(
                child: Text(
                  'Failed to load Today in History',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
