import '../entities/livestream.dart';
import '../repositories/livestream_repository.dart';

class GetLivestream {
  final LivestreamRepository repository;
  GetLivestream(this.repository);
  Future<Livestream> call(String livestreamId) =>
      repository.getLivestream(livestreamId);
}
