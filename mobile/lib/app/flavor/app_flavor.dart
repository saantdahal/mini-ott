import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { dev, prod }

class FlavorValues {
  final String appName;
  final String baseUrl;
  final String packageName;
  final String khaltiPublicKey;
  final String mediaCdnBaseUrl;
  final String? featuredContentId;

  const FlavorValues({
    required this.appName,
    required this.baseUrl,
    required this.packageName,
    required this.khaltiPublicKey,
    this.mediaCdnBaseUrl = '',
    this.featuredContentId,
  });
}

class AppFlavorConfig {
  const AppFlavorConfig._();

  static AppFlavor _current = AppFlavor.prod;

  static AppFlavor get current => _current;
  static bool get isDev => _current == AppFlavor.dev;
  static String get name => _current.name;

  static FlavorValues get values => _createValues(_current);

  static FlavorValues _createValues(AppFlavor flavor) {
    final p = flavor.name.toUpperCase(); // "DEV" or "PROD"

    String require(String key) {
      final val = dotenv.env[key];
      if (val == null || val.isEmpty) {
        throw StateError('Missing required env variable: $key');
      }
      return val;
    }

    final featuredContentId = dotenv.env['${p}_FEATURED_CONTENT_ID'];

    return FlavorValues(
      appName: require('${p}_APP_NAME'),
      baseUrl: require('${p}_BASE_URL'),
      packageName: require('${p}_PACKAGE_NAME'),
      khaltiPublicKey: require('${p}_KHALTI_PUBLIC_KEY'),
      mediaCdnBaseUrl: dotenv.env['${p}_MEDIA_CDN_BASE_URL'] ?? '',
      featuredContentId: (featuredContentId?.isEmpty ?? true)
          ? null
          : featuredContentId,
    );
  }

  static String get appName => values.appName;
  static String get packageName => values.packageName;
  static String get baseUrl => values.baseUrl;
  static String get khaltiPublicKey => values.khaltiPublicKey;
  static String get mediaCdnBaseUrl => values.mediaCdnBaseUrl;
  static String? get featuredContentId => values.featuredContentId;

  static void setup(AppFlavor flavor) {
    _current = flavor;
  }
}