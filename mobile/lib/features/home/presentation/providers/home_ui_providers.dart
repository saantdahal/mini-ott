import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedContentIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  bool isSaved(String id) => state.contains(id);
}

final savedContentIdsProvider =
    NotifierProvider<SavedContentIds, Set<String>>(SavedContentIds.new);
