import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/di.dart';
import '../../livestream/data/datasources/livestream_local_data_source.dart';
import '../../livestream/data/datasources/livestream_remote_data_source.dart';
import '../../livestream/data/repositories/livestream_repository_impl.dart';
import '../../livestream/domain/repositories/livestream_repository.dart';
import '../../livestream/domain/usecases/get_comments_usecase.dart';
import '../../livestream/domain/usecases/get_livestream_usecase.dart';
import '../../livestream/domain/usecases/get_voting_candidates_usecase.dart';
import '../../livestream/domain/usecases/send_comment_usecase.dart';
import '../../livestream/domain/usecases/vote_usecase.dart';

final getLivestreamProvider = Provider<GetLivestream>((ref) => getIt<GetLivestream>());
final getCommentsProvider = Provider<GetComments>((ref) => getIt<GetComments>());
final sendCommentProvider = Provider<SendComment>((ref) => getIt<SendComment>());
final getVotingCandidatesProvider = Provider<GetVotingCandidates>(
  (ref) => getIt<GetVotingCandidates>(),
);
final voteProvider = Provider<Vote>((ref) => getIt<Vote>());

class LivestreamDI {
  static void setup() {
    if (!getIt.isRegistered<LivestreamRemoteDataSource>()) {
      getIt.registerLazySingleton<LivestreamRemoteDataSource>(
        () => LivestreamRemoteDataSource(getIt<Dio>()),
      );
    }

    if (!getIt.isRegistered<LivestreamLocalDataSource>()) {
      getIt.registerLazySingleton<LivestreamLocalDataSource>(
        () => LivestreamLocalDataSource(getIt()),
      );
    }

    if (!getIt.isRegistered<LivestreamRepository>()) {
      getIt.registerLazySingleton<LivestreamRepository>(
        () => LivestreamRepositoryImpl(
          remoteDataSource: getIt<LivestreamRemoteDataSource>(),
          localDataSource: getIt<LivestreamLocalDataSource>(),
        ),
      );
    }

    if (!getIt.isRegistered<GetLivestream>()) {
      getIt.registerLazySingleton<GetLivestream>(
        () => GetLivestream(getIt<LivestreamRepository>()),
      );
    }

    if (!getIt.isRegistered<GetComments>()) {
      getIt.registerLazySingleton<GetComments>(
        () => GetComments(getIt<LivestreamRepository>()),
      );
    }

    if (!getIt.isRegistered<SendComment>()) {
      getIt.registerLazySingleton<SendComment>(
        () => SendComment(getIt<LivestreamRepository>()),
      );
    }

    if (!getIt.isRegistered<GetVotingCandidates>()) {
      getIt.registerLazySingleton<GetVotingCandidates>(
        () => GetVotingCandidates(getIt<LivestreamRepository>()),
      );
    }

    if (!getIt.isRegistered<Vote>()) {
      getIt.registerLazySingleton<Vote>(
        () => Vote(getIt<LivestreamRepository>()),
      );
    }
  }
}
