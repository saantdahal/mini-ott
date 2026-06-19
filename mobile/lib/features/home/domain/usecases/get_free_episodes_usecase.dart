import '../entities/content_entity.dart';
import '../repositories/home_repository.dart';

class GetFreeEpisodesUseCase {
  final HomeRepository repository;

  GetFreeEpisodesUseCase(this.repository);

  Future<List<ContentEntity>> call() async {
    return repository.getFreeEpisodesContent();
  }
}
