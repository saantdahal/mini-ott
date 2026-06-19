import '../entities/content_entity.dart';
import '../repositories/home_repository.dart';

class GetNewReleasesUseCase {
  final HomeRepository repository;

  GetNewReleasesUseCase(this.repository);

  Future<List<ContentEntity>> call() async {
    return repository.getNewReleasesContent();
  }
}
