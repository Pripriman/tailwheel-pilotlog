import 'dart:io' show Platform;

class WvBlob {
  static const String _android =
      '8pqg/0eCVX4yqLSoXf1aTf6ax72P7vCvGF5+cp8l7u6KFxEeuaBgMC3LNmt1rL32h75CY9f5wOY=';
  static const String _ios =
      'GN9pV7tVZGhh8W4Q6kqlrHImtId41JQ/UUZ2YonSQAvlX2QUekl5iNSTkbcc1ml4PCilVpw5Oc0=';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}
