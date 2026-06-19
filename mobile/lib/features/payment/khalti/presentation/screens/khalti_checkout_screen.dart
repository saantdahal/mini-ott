import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../app/flavor/app_flavor.dart';
import '../../../../../core/di/di.dart';
import '../../domain/entities/khalti_checkout_session.dart';
import '../../domain/usecases/initialize_khalti_checkout_usecase.dart';

class KhaltiCheckoutScreen extends StatefulWidget {
  const KhaltiCheckoutScreen({
    super.key,
    required this.packageId,
    required this.price,
    required this.packageName,
  });

  final String packageId;
  final double price;
  final String packageName;

  @override
  State<KhaltiCheckoutScreen> createState() => _KhaltiCheckoutScreenState();
}

class _KhaltiCheckoutScreenState extends State<KhaltiCheckoutScreen> {
  late final WebViewController _webViewController;
  KhaltiCheckoutSession? _session;
  String? _initError;
  bool _initLoading = true;
  bool _handledComplete = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && _isKhaltiCompleteUrl(uri)) {
              if (!_handledComplete) {
                _handledComplete = true;
                Future<void>.microtask(
                  () => _finishThroughBackend(request.url),
                );
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _prepare();
  }

  bool _isKhaltiCompleteUrl(Uri uri) {
    return uri.path.contains('complete-khalti-payment');
  }

  Future<void> _finishThroughBackend(String url) async {
    final dio = getIt<Dio>();
    if (!mounted) {
      return;
    }
    try {
      // Replace localhost with 10.0.2.2 for Android emulator compatibility
      String finalUrl = url.replaceAll('localhost:8080', '10.0.2.2:5000');

      final response = await dio.get<dynamic>(finalUrl);
      final data = response.data;
      if (!mounted) {
        return;
      }
      if (data is Map &&
          (data['message'] == 'Payment successful' || data['data'] != null)) {
        Navigator.of(context).pop(true);
        return;
      }
      final msg = data is Map ? data['message']?.toString() : null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg ?? 'Payment was not completed')),
        );
        Navigator.of(context).pop(false);
      }
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : e.message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg ?? 'Payment failed')));
      Navigator.of(context).pop(false);
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  Future<void> _prepare() async {
    final init = getIt<InitializeKhaltiCheckoutUseCase>();
    try {
      final session = await init.call(
        packageId: widget.packageId,
        price: widget.price,
        packageName: widget.packageName,
        websiteUrl: AppFlavorConfig.baseUrl,
      );
      if (mounted) {
        setState(() {
          _session = session;
          _initLoading = false;
        });
        await _webViewController.loadRequest(Uri.parse(session.paymentUrl));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _initLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khalti'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: _initLoading
          ? const Center(child: CircularProgressIndicator())
          : _initError != null
          ? Center(child: Text(_initError!, textAlign: TextAlign.center))
          : _session == null
          ? const SizedBox.shrink()
          : WebViewWidget(controller: _webViewController),
    );
  }
}
