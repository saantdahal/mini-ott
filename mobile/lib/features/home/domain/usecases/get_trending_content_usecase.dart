import '../entities/content_entity.dart';
import '../repositories/home_repository.dart';

class GetTrendingContentUseCase {
  final HomeRepository repository;

  GetTrendingContentUseCase(this.repository);

  Future<List<ContentEntity>> call() async {
    return repository.getTrendingContent();
  }
}
