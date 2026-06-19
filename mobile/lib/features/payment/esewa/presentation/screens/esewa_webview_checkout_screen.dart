import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../core/di/di.dart';
import '../../domain/entities/esewa_epay_init_result.dart';
import '../../domain/usecases/initialize_esewa_webview_session_usecase.dart';

class EsewaWebviewCheckoutScreen extends StatefulWidget {
  const EsewaWebviewCheckoutScreen({
    super.key,
    required this.packageId,
    required this.price,
    required this.productName,
  });

  final String packageId;
  final double price;
  final String productName;

  @override
  State<EsewaWebviewCheckoutScreen> createState() =>
      _EsewaWebviewCheckoutScreenState();
}

class _EsewaWebviewCheckoutScreenState
    extends State<EsewaWebviewCheckoutScreen> {
  late final WebViewController _webViewController;
  String? _initError;
  bool _loading = true;
  bool _verifying = false;
  bool _handledComplete = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..enableZoom(false)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && uri.path.contains('complete-esewa-payment')) {
              if (!_handledComplete) {
                _handledComplete = true;
                final hasData = uri.queryParameters.containsKey('data');
                if (hasData) {
                  Future<void>.microtask(
                    () => _finishThroughBackend(request.url),
                  );
                } else {
                  Future<void>.microtask(() {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment was not completed'),
                        ),
                      );
                      Navigator.of(context).pop(false);
                    }
                  });
                }
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _prepare();
  }

  Future<void> _finishThroughBackend(String url) async {
    final dio = getIt<Dio>();
    if (!mounted) return;

    setState(() => _verifying = true);

    final uri = Uri.tryParse(url);
    final callbackData = uri?.queryParameters['data'];
    if (callbackData == null || callbackData.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment was not completed')),
        );
        Navigator.of(context).pop(false);
      }
      return;
    }

    try {
      var safeUrl = uri!
          .replace(queryParameters: {'data': callbackData})
          .toString();

      // Replace localhost with 10.0.2.2 for Android emulator compatibility
      safeUrl = safeUrl.replaceAll('localhost:8080', '10.0.2.2:5000');

      final response = await dio.get<dynamic>(safeUrl);
      final data = response.data;
      if (!mounted) return;

      if (data is Map &&
          (data['message'] == 'Payment successful' || data['data'] != null)) {
        Navigator.of(context).pop(true);
        return;
      }

      final msg = data is Map
          ? data['message']?.toString()
          : 'Payment was not completed';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg ?? 'Payment was not completed')),
        );
        Navigator.of(context).pop(false);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : e.message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg ?? 'Payment failed')));
      Navigator.of(context).pop(false);
    } catch (_) {
      if (mounted) Navigator.of(context).pop(false);
    }
  }

  Future<void> _prepare() async {
    final init = getIt<InitializeEsewaWebviewSessionUseCase>();
    try {
      final session = await init.call(
        packageId: widget.packageId,
        price: widget.price,
        productName: widget.productName,
      );
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      await _loadEsewaForm(session);
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadEsewaForm(EsewaEpayInitResult session) async {
    final params = {
      'amount': session.totalAmount,
      'tax_amount': '0',
      'total_amount': session.totalAmount,
      'transaction_uuid': session.paymentId,
      'product_code': session.productCode,
      'product_service_charge': '0',
      'product_delivery_charge': '0',
      'success_url': session.successUrl,
      'failure_url': session.failureUrl,
      'signed_field_names': session.signedFieldNames,
      'signature': session.signature,
    };

    final inputs = params.entries
        .map(
          (e) => '<input type="hidden" name="${e.key}" value="${e.value}" />',
        )
        .join('\n');

    final html =
        '''
<!DOCTYPE html>
<html>
<body onload="document.forms[0].submit()">
  <form action="${session.gatewayActionUrl}" method="POST">
    $inputs
  </form>
</body>
</html>
''';

    await _webViewController.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eSewa'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_initError != null) {
      return Center(child: Text(_initError!, textAlign: TextAlign.center));
    }
    if (_verifying) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verifying payment...'),
          ],
        ),
      );
    }
    return WebViewWidget(controller: _webViewController);
  }
}
