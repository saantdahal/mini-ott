import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../features/auth/data/models/login_request_model.dart';
import '../../../features/content_catalog/data/models/content_catalog_dtos.dart';
import '../../../shared/models/health_response.dart';
import '../../../shared/models/me_response.dart';
import '../../../shared/models/refresh_tokens_response.dart';
import '../../../shared/models/register_response.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET('/health')
  Future<HealthResponse> health();

  @POST('/api/auth/login')
  Future<HttpResponse<RegisterResponse>> login(@Body() LoginRequestModel body);

  @POST('/api/auth/refresh')
  Future<HttpResponse<RefreshTokensResponse>> refresh(
    @Body() Map<String, dynamic> body,
  );

  @GET('/api/auth/me')
  Future<HttpResponse<MeResponse>> me();

  @POST('/api/auth/logout')
  Future<HttpResponse<dynamic>> logout();

  @POST('/api/auth/register')
  @MultiPart()
  Future<HttpResponse<RegisterResponse>> register({
    @Part(name: 'full_name') required String fullName,
    @Part(name: 'email') required String email,
    @Part(name: 'password') required String password,
    @Part(name: 'auth_provider') String authProvider = 'email',
    @Part(name: 'phone') String? phone,
    @Part(name: 'country') String? country,
    @Part(name: 'gender') String? gender,
    @Part(name: 'date_of_birth') String? dateOfBirth,
    @Part(name: 'avatar') MultipartFile? avatar,
  });

  @POST('/api/auth/verify-otp')
  Future<HttpResponse<dynamic>> verifyEmailOtp({
    @Body() required Map<String, dynamic> data,
  });

  @POST('/api/auth/resend-otp')
  Future<HttpResponse<dynamic>> resendEmailOtp({
    @Body() required Map<String, dynamic> data,
  });

  @POST('/api/auth/forgot-password')
  Future<HttpResponse<dynamic>> forgotPassword({
    @Body() required Map<String, dynamic> data,
  });

  @POST('/api/auth/verify-reset-otp')
  Future<HttpResponse<dynamic>> verifyResetOtp({
    @Body() required Map<String, dynamic> data,
  });

  @POST('/api/auth/reset-password')
  Future<HttpResponse<dynamic>> resetPassword({
    @Body() required Map<String, dynamic> data,
  });

  @POST('/api/auth/google/mobile-login')
  Future<HttpResponse<RegisterResponse>> googleLogin({
    @Body() required Map<String, dynamic> data,
  });

  @POST('/api/auth/apple/mobile-login')
  Future<HttpResponse<RegisterResponse>> appleLogin({
    @Body() required Map<String, dynamic> data,
  });

  // ─── Content catalog (public reads) ───────────────────────────────

  @GET('/api/content/categories')
  Future<HttpResponse<CategoriesListEnvelope>> listCategories();

  @GET('/api/content/categories/{id}')
  Future<HttpResponse<CategorySingleEnvelope>> getCategory(
    @Path('id') String id,
  );

  @GET('/api/content/genres')
  Future<HttpResponse<GenresListEnvelope>> listGenres();

  @GET('/api/content/genres/{id}')
  Future<HttpResponse<GenreSingleEnvelope>> getGenre(@Path('id') String id);

  @GET('/api/content/contents')
  Future<HttpResponse<ContentListEnvelope>> listContents({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('content_type') String? contentType,
    @Query('status') String? status,
    @Query('access_type') String? accessType,
    @Query('category_id') String? categoryId,
    @Query('genre_id') String? genreId,
  });

  @GET('/api/content/contents/{id}')
  Future<HttpResponse<ContentSingleEnvelope>> getContent(@Path('id') String id);

  @GET('/api/content/contents/{contentId}/seasons')
  Future<HttpResponse<SeasonsListEnvelope>> listSeasonsForContent(
    @Path('contentId') String contentId,
  );

  @GET('/api/content/seasons/{id}')
  Future<HttpResponse<SeasonSingleEnvelope>> getSeason(@Path('id') String id);

  @GET('/api/content/contents/{contentId}/episodes')
  Future<HttpResponse<EpisodesListEnvelope>> listEpisodesForContent(
    @Path('contentId') String contentId,
  );

  @GET('/api/content/seasons/{seasonId}/episodes')
  Future<HttpResponse<EpisodesListEnvelope>> listEpisodesForSeason(
    @Path('seasonId') String seasonId,
  );

  @GET('/api/content/episodes/{id}')
  Future<HttpResponse<EpisodeSingleEnvelope>> getEpisode(@Path('id') String id);

  /// Signed HLS manifest URL. Server currently requires admin JWT.
  @GET('/api/stream/{videoUploadId}/hls')
  Future<HttpResponse<HlsPlaybackEnvelope>> getHlsPlaybackParams(
    @Path('videoUploadId') String videoUploadId,
  );

  // Profile endpoints
  @PUT('/api/users/me')
  @MultiPart()
  Future<HttpResponse<MeResponse>> updateProfile({
    @Part(name: 'full_name') String? fullName,
    @Part(name: 'phone') String? phone,
    @Part(name: 'gender') String? gender,
    @Part(name: 'date_of_birth') String? dateOfBirth,
    @Part(name: 'country') String? country,
    @Part(name: 'avatar') MultipartFile? avatar,
  });

  @POST('/api/auth/change-password')
  Future<HttpResponse<dynamic>> changePassword({
    @Body() required Map<String, dynamic> data,
  });

  @DELETE('/api/users/account')
  Future<HttpResponse<dynamic>> deleteAccount({
    @Body() required Map<String, dynamic> data,
  });
}
