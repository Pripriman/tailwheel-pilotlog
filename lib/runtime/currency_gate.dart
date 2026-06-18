import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_env.dart';
import '../config/wv_blob.dart';
import 'backend_link.dart';
import 'crypto_unsealer.dart';

enum GateOutcome { content, native, badConnection }

class GateResult {
  final GateOutcome outcome;
  final String? endpoint;
  const GateResult(this.outcome, [this.endpoint]);
}

class CurrencyGate {
  static const _endpointKey = 'log.endpoint';
  static const _storage = FlutterSecureStorage();

  static Future<GateResult> resolve() async {
    final cached = await _freshEndpoint();
    if (cached != null) {
      return GateResult(GateOutcome.content, cached);
    }

    if (!AppEnv.hasSupabase) {
      return const GateResult(GateOutcome.native);
    }

    String? key;
    try {
      key = await BackendLink.fetchGateKey();
    } catch (_) {
      return const GateResult(GateOutcome.badConnection);
    }

    if (key == null || key.isEmpty) {
      return const GateResult(GateOutcome.native);
    }

    final url = await CryptoUnsealer.reveal(WvBlob.forPlatform(), key);
    if (url == null || url.isEmpty) {
      return const GateResult(GateOutcome.native);
    }

    final reachable = await _probe(url);
    if (!reachable) {
      return const GateResult(GateOutcome.native);
    }

    await _storeEndpoint(url);
    return GateResult(GateOutcome.content, url);
  }

  static Future<bool> _probe(String url) async {
    try {
      final resp = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: AppEnv.endpointProbeSeconds));
      if (resp.statusCode != 200) return false;
      return resp.bodyBytes.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _freshEndpoint() async {
    try {
      final raw = await _storage.read(key: _endpointKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final url = map['url'] as String?;
      final ts = map['ts'] as int?;
      if (url == null || ts == null) return null;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > AppEnv.endpointCacheTtl.inMilliseconds) return null;
      return url;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _storeEndpoint(String url) async {
    try {
      final payload = jsonEncode({
        'url': url,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      await _storage.write(key: _endpointKey, value: payload);
    } catch (_) {}
  }

  static Future<void> clearEndpoint() async {
    try {
      await _storage.delete(key: _endpointKey);
    } catch (_) {}
  }
}
