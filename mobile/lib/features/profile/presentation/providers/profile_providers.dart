import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_notifier.dart';
import 'profile_state.dart';

export 'profile_notifier.dart';
export 'profile_state.dart';

final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
