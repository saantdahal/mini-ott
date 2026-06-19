import '../entities/content_entity.dart';
import '../repositories/home_repository.dart';

class GetContinueWatchingUseCase {
  final HomeRepository repository;

  GetContinueWatchingUseCase(this.repository);

  Future<List<ContentEntity>> call() async {
    return repository.getContinueWatchingContent();
  }
}
