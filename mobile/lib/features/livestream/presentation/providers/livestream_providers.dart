import "package:flutter_riverpod/flutter_riverpod.dart";

import "livestream_notifier.dart";
import "livestream_state.dart";

final livestreamNotifierProvider =
    NotifierProvider<LivestreamNotifier, LivestreamState>(LivestreamNotifier.new);
