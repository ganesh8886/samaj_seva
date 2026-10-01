// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// /// Generic in-app browser screen used for ID Card, Certificate,
// /// and Edit Profile pages (which are still server-rendered PHP pages).
// class WebViewScreen extends StatefulWidget {
//   final String url;
//   final String title;
//
//   const WebViewScreen({super.key, required this.url, required this.title});
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late final WebViewController _controller;
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (_) => setState(() => _loading = true),
//           onPageFinished: (_) => setState(() => _loading = false),
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title)),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (_loading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Generic in-app browser screen used for ID Card, Certificate,
/// Proposal Dastavej, and Edit Profile pages (server-rendered PHP pages).
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
            _injectResponsiveScaling(); // NEW — fits wide desktop-style pages to phone width
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load page: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // NEW — same logic as PvcCardWebViewScreen: measures the page's real
  // (unscaled) width and shrinks it with a CSS transform so nothing gets
  // cut off on the right edge of the phone screen.
  Future<void> _injectResponsiveScaling() async {
    await _controller.runJavaScript('''
      (function() {
        var meta = document.querySelector('meta[name="viewport"]');
        if (!meta) {
          meta = document.createElement('meta');
          meta.name = 'viewport';
          document.head.appendChild(meta);
        }
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0';

        function scaleToFit() {
          var wrapper = document.getElementById('__scale_wrapper__');

          if (!wrapper) {
            wrapper = document.createElement('div');
            wrapper.id = '__scale_wrapper__';
            while (document.body.firstChild) {
              wrapper.appendChild(document.body.firstChild);
            }
            document.body.appendChild(wrapper);
            document.documentElement.style.margin = '0';
            document.documentElement.style.padding = '0';
            document.body.style.margin = '0';
            document.body.style.padding = '0';
          }

          wrapper.style.transform = 'none';
          wrapper.style.transformOrigin = 'top left';

          var naturalWidth = wrapper.scrollWidth;
          var naturalHeight = wrapper.scrollHeight;
          var screenWidth = window.innerWidth;

          if (naturalWidth <= 0) return;

          var scale = screenWidth / naturalWidth;
          if (scale > 1) scale = 1;

          wrapper.style.transform = 'scale(' + scale + ')';

          document.body.style.width = screenWidth + 'px';
          document.body.style.height = (naturalHeight * scale) + 'px';
          document.body.style.overflowX = 'hidden';
        }

        scaleToFit();
        setTimeout(scaleToFit, 300);
        setTimeout(scaleToFit, 1000);
        window.addEventListener('resize', scaleToFit);
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}