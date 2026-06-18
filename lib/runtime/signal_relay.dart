import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/app_env.dart';

class SignalRelay {
  static bool _started = false;

  static Future<void> boot() async {
    if (_started || !AppEnv.hasOneSignal) return;
    try {
      OneSignal.initialize(AppEnv.oneSignalAppId);
      _started = true;
    } catch (_) {}
  }

  static Future<void> askPermission() async {
    if (!_started) return;
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (_) {}
  }

  static Future<void> bindUser(String externalId) async {
    if (!_started) return;
    try {
      await OneSignal.login(externalId);
    } catch (_) {}
  }

  static Future<void> unbindUser() async {
    if (!_started) return;
    try {
      await OneSignal.logout();
    } catch (_) {}
  }
}
