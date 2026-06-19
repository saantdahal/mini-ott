import '../entities/content_entity.dart';
import '../../presentation/models/content_section.dart';

abstract class HomeRepository {
  Future<ContentEntity> getFeaturedContent();
  Future<List<ContentEntity>> getContinueWatchingContent();
  Future<List<ContentEntity>> getFreeEpisodesContent();
  Future<List<ContentEntity>> getTrendingContent();
  Future<List<ContentEntity>> getNewReleasesContent();
  Future<List<ContentSection>> getContentGroupedByCategories();
}
