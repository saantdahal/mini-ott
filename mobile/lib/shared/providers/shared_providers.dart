import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}

class AppErrorMessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setError(String? message) {
    state = message;
  }

  void clear() {
    state = null;
  }
}

final appLoadingProvider = NotifierProvider<AppLoadingNotifier, bool>(
  AppLoadingNotifier.new,
);

final appErrorMessageProvider =
    NotifierProvider<AppErrorMessageNotifier, String?>(
      AppErrorMessageNotifier.new,
    );
