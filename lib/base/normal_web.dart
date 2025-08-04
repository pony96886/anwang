import 'package:deepseek/base/basewidget.dart';
import 'package:deepseek/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deepseek/util/fake_ui.dart'
    if (dart.library.html) 'package:deepseek/util/real_ui.dart' as ui;
import 'package:universal_html/html.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NormalWeb extends BaseWidget {
  const NormalWeb({Key? key, this.url}) : super(key: key);
  final String? url;

  @override
  State<NormalWeb> createState() => _NormalWebState();

  @override
  State<StatefulWidget> cState() {
    // TODO: implement cState
    return _NormalWebState();
  }
}

class _NormalWebState extends BaseWidgetState<NormalWeb> {
  String _url = "";
  WebViewController? _controller;

  //web
  Widget htmlWeb() {
    final IFrameElement _iframeElement = IFrameElement();
    _iframeElement.src = _url;
    _iframeElement.style.border = 'none';
    _iframeElement.style.width = '100%';
    _iframeElement.style.height = '100%';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => _iframeElement,
    );
    Widget _iframeWidget;
    _iframeWidget = HtmlElementView(
      key: UniqueKey(),
      viewType: 'iframeElement',
    );
    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: true,
          child: Center(
            child: _iframeWidget,
          ),
        ),
      ],
    );
  }

  //android and ios
  Widget othersWeb() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
    return Center(
      child: WebViewWidget(controller: _controller!),
    );
  }

  @override
  void onCreate() {
    // TODO: implement onCreate
    _url = Uri.decodeComponent(widget.url ?? "");
  }

  @override
  Widget pageBody(BuildContext context) {
    return kIsWeb ? htmlWeb() : othersWeb();
  }

  @override
  void onDestroy() {
    // TODO: implement onDestroy
  }
}
