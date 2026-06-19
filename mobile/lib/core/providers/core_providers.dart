import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../di/di.dart';
import '../network/api/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return getIt<ApiClient>();
});

class AuthState {
  const AuthState({required this.isLoggedIn});

  final bool isLoggedIn;

  AuthState copyWith({bool? isLoggedIn}) {
    return AuthState(isLoggedIn: isLoggedIn ?? this.isLoggedIn);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoggedIn: false));

  void signIn() {
    state = state.copyWith(isLoggedIn: true);
  }

  void signOut() {
    state = state.copyWith(isLoggedIn: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
