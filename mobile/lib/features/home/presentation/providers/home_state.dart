import '../models/content_section.dart';

enum HomeActionType { idle, fetchingAll }

class HomeState {
  const HomeState({
    this.isLoading = false,
    this.contentSections = const [],
    this.errorMessage,
    this.actionType = HomeActionType.idle,
  });

  final bool isLoading;
  final List<ContentSection> contentSections;
  final String? errorMessage;
  final HomeActionType actionType;

  HomeState copyWith({
    bool? isLoading,
    List<ContentSection>? contentSections,
    String? errorMessage,
    HomeActionType? actionType,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      contentSections: contentSections ?? this.contentSections,
      errorMessage: errorMessage ?? this.errorMessage,
      actionType: actionType ?? this.actionType,
    );
  }
}
