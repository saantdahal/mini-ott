import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'splash_notifier.dart';
import 'splash_state.dart';

final splashNotifierProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
