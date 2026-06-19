import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khalti/khalti.dart';
// import 'package:device_preview/device_preview.dart';

import 'app/app.dart';
import 'app/flavor/app_flavor.dart';
import 'core/di/di.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: '.env');

  AppFlavorConfig.setup(flavor);
  await configureDependencies();
  await Khalti.init(
    publicKey: AppFlavorConfig.khaltiPublicKey,
    config: KhaltiConfig.platformOnly(),
    enabledDebugging: kDebugMode,
  );

  //final useDevicePreview = kDebugMode;

  // runApp(
  //   ProviderScope(
  //     child: useDevicePreview
  //         ? DevicePreview(
  //             enabled: true,
  //             builder: (context) => const App(),
  //             tools: const [...DevicePreview.defaultTools],
  //           )
  //         : const App(),
  //   ),
  // );

  runApp(ProviderScope(child: const App()));
}
