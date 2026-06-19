import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coin_notifier.dart';
import 'coin_state.dart';

export 'coin_notifier.dart';
export 'coin_state.dart';

final coinNotifierProvider = NotifierProvider<CoinNotifier, CoinState>(
  CoinNotifier.new,
);
