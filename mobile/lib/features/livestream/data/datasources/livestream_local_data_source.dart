import "dart:convert";
import "../../../../core/services/local_storage_service.dart";
import "../models/comment_model.dart";
import "../models/livestream_model.dart";

class LivestreamLocalDataSource {
  final LocalStorageService localStorage;
  LivestreamLocalDataSource(this.localStorage);

  Future<LivestreamModel?> getLivestream(String id) async {
    final json = localStorage.getString('livestream:$id');
    if (json == null) return null;
    return LivestreamModel.fromJson(jsonDecode(json));
  }

  Future<void> saveLivestream(LivestreamModel ls) async {
    await localStorage.setString(
      'livestream:${ls.id}',
      jsonEncode({'id': ls.id}),
    );
  }

  Future<List<CommentModel>> getComments(String id) async {
    final json = localStorage.getString('comments:$id');
    if (json == null) return [];
    final list = jsonDecode(json);
    return (list as List).map((c) => CommentModel.fromJson(c)).toList();
  }

  Future<void> saveComments(String id, List<CommentModel> comments) async {
    await localStorage.setString(
      'comments:$id',
      jsonEncode(comments.map((c) => c).toList()),
    );
  }
}
