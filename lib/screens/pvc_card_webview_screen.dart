import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'karyakarta_dashboard_screen.dart';

/// Shows a certificate / ID-card / PDF-style HTML page (Dastavej, PVC card,
/// Membership Certificate, Claim form, Proposal form, Receipt, etc.) inside
/// a WebView, auto-fitted to the phone's screen width.
///
/// SWIPE UPDATE:
/// If the HTML page contains two stacked sections for "front" and "back"
/// (detected by id/class containing "front"/"back", or by falling back to
/// the first two visible top-level children of <body>), this now turns
/// them into a horizontally swipeable pager using CSS scroll-snap, instead
/// of showing them one after another vertically. Each side is fitted to
/// the screen width independently, with small dot indicators at the
/// bottom showing which side you're on.
///
/// If only one page-like section is found (or the detection is not
/// confident), it falls back to the original single-page "zoom to fit"
/// behavior — nothing breaks for pages that aren't front/back cards.
///
/// WHY `zoom` INSTEAD OF `transform: scale()`:
/// `transform` does NOT affect page layout/flow, so after scaling you'd
/// have to manually recompute body width/height — fragile once fonts,
/// the QR code, or a seal image load late and change natural size.
/// CSS `zoom` is a real layout property (supported by Chromium/Android
/// WebView): the browser reflows at the new size, so there's no leftover
/// blank space and no manual width/height math needed. We re-run the fit
/// function a few times and on any DOM mutation (MutationObserver) so
/// late-loading images/QR codes don't break it.
class PvcCardWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const PvcCardWebViewScreen({
    super.key,
    required this.url,
    this.title = 'Document',
  });

  @override
  State<PvcCardWebViewScreen> createState() => _PvcCardWebViewScreenState();
}

class _PvcCardWebViewScreenState extends State<PvcCardWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
    // Let OUR fit-to-screen / pager script control zoom instead of the
    // user's pinch gesture fighting with it on first load. Pinch-zoom
    // still works after the page settles — this only affects the initial
    // programmatic zoom we apply. Horizontal swipe between front/back is
    // handled by native scroll (CSS scroll-snap), not by enableZoom.
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
            _injectFitAndPaginate();
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _error = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _injectFitAndPaginate() async {
    await _controller.runJavaScript('''
      (function() {
        // Avoid double-installing if onPageFinished somehow fires twice.
        if (window.__pagerInstalled__) {
          window.__runFit__ && window.__runFit__();
          return;
        }
        window.__pagerInstalled__ = true;

        // 1. Proper mobile viewport meta tag.
        var meta = document.querySelector('meta[name="viewport"]');
        if (!meta) {
          meta = document.createElement('meta');
          meta.name = 'viewport';
          document.head.appendChild(meta);
        }
        meta.setAttribute(
          'content',
          'width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=5.0, user-scalable=yes'
        );

        // 2. Base resets + pager / dot-indicator CSS.
        var style = document.createElement('style');
        style.innerHTML = `
          html, body {
            margin: 0 !important;
            padding: 0 !important;
            height: 100%;
          }
          * { box-sizing: border-box; }
          #__pagerRoot__ {
            display: flex;
            flex-direction: row;
            width: 100vw;
            height: 100vh;
            overflow-x: auto;
            overflow-y: hidden;
            scroll-snap-type: x mandatory;
            -webkit-overflow-scrolling: touch;
          }
          .__pagerPage__ {
            flex: 0 0 100vw;
            width: 100vw;
            height: 100vh;
            max-width: 100vw;
            scroll-snap-align: start;
            scroll-snap-stop: always;
            overflow-y: auto;
            overflow-x: hidden;
            display: flex;
            align-items: flex-start;
            justify-content: center;
          }
          .__pagerPage__ > * { transform-origin: top center; }
          #__pagerDots__ {
            position: fixed;
            left: 0; right: 0; bottom: 14px;
            display: flex;
            justify-content: center;
            gap: 8px;
            z-index: 999999;
            pointer-events: none;
          }
          #__pagerDots__ span {
            width: 8px; height: 8px; border-radius: 50%;
            background: rgba(255,255,255,0.45);
            box-shadow: 0 0 0 1px rgba(0,0,0,0.25);
            transition: background 0.15s ease;
          }
          #__pagerDots__ span.__active__ { background: #ffffff; }
        `;
        document.head.appendChild(style);

        // 3. Hide any "Back to Portal / Close Tab" style buttons that only
        //    make sense on desktop.
        function hideDesktopOnlyButtons() {
          var all = document.querySelectorAll('a, button, div, span');
          for (var i = 0; i < all.length; i++) {
            var el = all[i];
            var text = (el.innerText || '').trim();
            if (text.indexOf('Back to Portal') !== -1 || text.indexOf('Close Tab') !== -1) {
              var target = el.closest('a, button, .btn') || el;
              target.style.setProperty('display', 'none', 'important');
            }
          }
        }

        // 4. Find the front/back sections.
        function findPages() {
          var front = document.querySelector('[id*="front" i], [class*="front" i]');
          var back  = document.querySelector('[id*="back" i], [class*="back" i]');
          // Don't let a stray "Back to Portal" link count as the back side.
          if (front && front.tagName === 'A') front = null;
          if (back && back.tagName === 'A') back = null;

          if (front && back && front !== back) return [front, back];

          // Fallback: first two visible top-level children of <body>.
          var candidates = [];
          var children = document.body.children;
          for (var i = 0; i < children.length; i++) {
            var el = children[i];
            var tag = el.tagName.toLowerCase();
            if (tag === 'script' || tag === 'style' || tag === 'link' || tag === 'meta' || tag === 'noscript') continue;
            if (el.id === '__pagerRoot__' || el.id === '__pagerDots__') continue;
            if (el.offsetWidth === 0 && el.offsetHeight === 0) continue;
            candidates.push(el);
            if (candidates.length === 2) break;
          }
          return candidates.length === 2 ? candidates : null;
        }

        var pages = findPages();

        // Old single-page zoom-to-fit behaviour — used as a fallback when
        // we can't confidently find two separate front/back sections.
        function singlePageFit() {
          document.body.style.zoom = 1;
          var naturalWidth = Math.max(
            document.documentElement.scrollWidth,
            document.body.scrollWidth
          );
          var screenWidth = window.innerWidth;
          if (naturalWidth > screenWidth && naturalWidth > 0) {
            var scale = screenWidth / naturalWidth;
            if (scale > 1) scale = 1;
            document.body.style.zoom = scale;
          } else {
            document.body.style.zoom = 1;
          }
        }

        if (!pages) {
          window.__runFit__ = function() {
            hideDesktopOnlyButtons();
            singlePageFit();
          };
          window.__runFit__();
          setTimeout(window.__runFit__, 150);
          setTimeout(window.__runFit__, 500);
          setTimeout(window.__runFit__, 1200);
          setTimeout(window.__runFit__, 2500);
          window.addEventListener('resize', window.__runFit__);
          window.addEventListener('orientationchange', function() {
            setTimeout(window.__runFit__, 300);
          });
          return;
        }

        // 5. Build the swipeable pager and move front/back into it.
        var root = document.createElement('div');
        root.id = '__pagerRoot__';

        var wrappers = pages.map(function(pageEl) {
          var wrap = document.createElement('div');
          wrap.className = '__pagerPage__';
          pageEl.parentNode.removeChild(pageEl);
          wrap.appendChild(pageEl);
          root.appendChild(wrap);
          return wrap;
        });

        document.body.insertBefore(root, document.body.firstChild);

        var dots = document.createElement('div');
        dots.id = '__pagerDots__';
        wrappers.forEach(function(_, i) {
          var d = document.createElement('span');
          if (i === 0) d.className = '__active__';
          dots.appendChild(d);
        });
        document.body.appendChild(dots);

        // 6. Fit each page's real content to the screen width, independently.
        function fitPage(wrap) {
          var content = wrap.firstElementChild;
          if (!content) return;
          content.style.zoom = 1;
          var naturalWidth = content.scrollWidth;
          var screenWidth = window.innerWidth;
          if (naturalWidth > 0 && naturalWidth > screenWidth) {
            var scale = screenWidth / naturalWidth;
            if (scale > 1) scale = 1;
            content.style.zoom = scale;
          } else {
            content.style.zoom = 1;
          }
        }

        function fitAllPages() {
          wrappers.forEach(fitPage);
        }

        window.__runFit__ = function() {
          hideDesktopOnlyButtons();
          fitAllPages();
        };

        // Run now, then a few more times shortly after — fonts, the QR
        // code and the round seal/logo image in certificates often finish
        // loading a moment after onPageFinished fires, which changes the
        // natural content width.
        window.__runFit__();
        setTimeout(window.__runFit__, 150);
        setTimeout(window.__runFit__, 500);
        setTimeout(window.__runFit__, 1200);
        setTimeout(window.__runFit__, 2500);

        // Re-fit whenever the DOM changes inside the pager (e.g. an image
        // finishes loading and its real dimensions get applied).
        try {
          var observer = new MutationObserver(function() {
            window.__runFit__();
          });
          observer.observe(root, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['src', 'style']
          });
        } catch (e) {}

        window.addEventListener('resize', window.__runFit__);
        window.addEventListener('orientationchange', function() {
          setTimeout(window.__runFit__, 300);
        });

        // Re-fit every time an image inside the pager finishes loading.
        var imgs = root.querySelectorAll('img');
        for (var j = 0; j < imgs.length; j++) {
          imgs[j].addEventListener('load', window.__runFit__);
        }

        // 7. Keep the dot indicator in sync with the swipe position.
        var scrollTimer = null;
        root.addEventListener('scroll', function() {
          if (scrollTimer) clearTimeout(scrollTimer);
          scrollTimer = setTimeout(function() {
            var idx = Math.round(root.scrollLeft / window.innerWidth);
            var dotEls = dots.querySelectorAll('span');
            for (var k = 0; k < dotEls.length; k++) {
              dotEls[k].classList.toggle('__active__', k === idx);
            }
          }, 80);
        });
      })();
    ''');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: KColors.orange ?? const Color(0xFF1B1442),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _error = null;
                _loading = true;
              });
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            // const Center(child: CircularProgressIndicator(color: Colors.white)),
            const Center(child: CircularProgressIndicator(color: KColors.primary)),
          if (_error != null)
            Container(
              color: Colors.black87,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _loading = true;
                      });
                      _controller.reload();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}