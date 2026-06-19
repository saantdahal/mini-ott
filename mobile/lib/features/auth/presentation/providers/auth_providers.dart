import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'auth_state.dart';

export 'auth_notifier.dart';
export 'auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
