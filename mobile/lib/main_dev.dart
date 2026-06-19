import 'app/flavor/app_flavor.dart';
import 'bootstrap.dart';

Future<void> main() async {
  await bootstrap(AppFlavor.dev);
}
