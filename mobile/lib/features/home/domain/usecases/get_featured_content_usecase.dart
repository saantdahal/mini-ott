import '../entities/content_entity.dart';
import '../repositories/home_repository.dart';

class GetFeaturedContentUseCase {
  final HomeRepository repository;

  GetFeaturedContentUseCase(this.repository);

  Future<ContentEntity> call() async {
    return repository.getFeaturedContent();
  }
}
