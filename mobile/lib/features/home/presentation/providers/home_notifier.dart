import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../di/home_di.dart';
import 'home_state.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  Future<void> fetchAllContent() async {
    state = state.copyWith(
      isLoading: true,
      actionType: HomeActionType.fetchingAll,
      errorMessage: null,
    );

    try {
      final homeRepository = ref.read(homeRepositoryProvider);
      final contentSections = await homeRepository
          .getContentGroupedByCategories();

      state = state.copyWith(
        isLoading: false,
        contentSections: contentSections,
        actionType: HomeActionType.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: HomeActionType.idle,
      );
    }
  }
}
