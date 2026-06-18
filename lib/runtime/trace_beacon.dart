import 'package:affise_attribution_lib/affise.dart';
import '../config/app_env.dart';

class TraceBeacon {
  static bool _started = false;

  static void boot() {
    if (_started || !AppEnv.hasAffise) return;
    try {
      Affise
          .settings(
            affiseAppId: AppEnv.affiseAppId,
            secretKey: AppEnv.affiseSecret,
          )
          .setProduction(true)
          .start();
      _started = true;
    } catch (_) {}
  }

  static void _emit(String name) {
    if (!_started) return;
    try {
      Affise.sendEvent(UserCustomEvent(eventName: name));
    } catch (_) {}
  }

  static void firstOpen() => _emit('first_open');
  static void registration() => _emit('registration');
  static void login() => _emit('login');
  static void contentOpen() => _emit('content_open');
}
