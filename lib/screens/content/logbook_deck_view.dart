import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/log_palette.dart';

class LogbookDeckView extends StatefulWidget {
  final String endpoint;
  const LogbookDeckView({super.key, required this.endpoint});

  @override
  State<LogbookDeckView> createState() => _LogbookDeckViewState();
}

class _LogbookDeckViewState extends State<LogbookDeckView> {
  static const _lastUrlKey = 'log.lastUrl';

  InAppWebViewController? _controller;
  bool _loading = true;
  String? _startUrl;

  @override
  void initState() {
    super.initState();
    _resolveStart();
  }

  Future<void> _resolveStart() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_lastUrlKey);
    setState(() {
      _startUrl = (saved != null && saved.startsWith('http'))
          ? saved
          : widget.endpoint;
    });
  }

  Future<void> _remember(WebUri? uri) async {
    if (uri == null) return;
    final s = uri.toString();
    if (!s.startsWith('http')) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUrlKey, s);
  }

  Future<void> _handleBack() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      controller.goBack();
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_startUrl == null) {
      return const Scaffold(
        backgroundColor: LogPalette.paper,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: LogPalette.paper,
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest:
                    URLRequest(url: WebUri(_startUrl!)),
                initialSettings: InAppWebViewSettings(
                  transparentBackground: true,
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptEnabled: true,
                  useHybridComposition: true,
                  allowsInlineMediaPlayback: true,
                  supportZoom: false,
                ),
                onWebViewCreated: (c) => _controller = c,
                onLoadStart: (c, uri) {
                  if (mounted) setState(() => _loading = true);
                },
                onLoadStop: (c, uri) async {
                  await _remember(uri);
                  if (mounted) setState(() => _loading = false);
                },
                onReceivedError: (c, req, err) {
                  if (mounted) setState(() => _loading = false);
                },
                onUpdateVisitedHistory: (c, uri, isReload) {
                  _remember(uri);
                },
              ),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(
                    color: LogPalette.navy,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
