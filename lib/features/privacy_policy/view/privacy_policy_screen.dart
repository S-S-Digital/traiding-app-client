import 'package:aspiro_trade/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      ) // Обязательно для работы скрипта
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            
            _controller.runJavaScript("document.body.style.zoom = '1.5';");
          },
        ),
      );

    await _controller.loadFlutterAsset('assets/html/privacy.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Политика конфиденциальности'),
        centerTitle: true,
        leading: const AutoLeadingButton(),
      ),
      body: Stack(
        children: [
          // Основной контент
          WebViewWidget(controller: _controller),
        ],
      ),
    );
  }
}
