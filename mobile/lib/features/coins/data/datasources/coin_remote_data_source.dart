import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/coin_packages_response.dart';
import '../models/wallet_response.dart';

part 'coin_remote_data_source.g.dart';

@RestApi()
abstract class CoinRemoteDataSource {
  factory CoinRemoteDataSource(Dio dio, {String baseUrl}) =
      _CoinRemoteDataSource;

  @GET('/api/wallet/get-coins')
  Future<HttpResponse<WalletResponse>> getWallet();

  @GET('/api/coin-packages/all')
  Future<HttpResponse<CoinPackagesResponse>> getCoinPackages();
}
