import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_notifier.dart';
import 'home_state.dart';

export 'home_notifier.dart';
export 'home_state.dart';
export 'home_ui_providers.dart';

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
