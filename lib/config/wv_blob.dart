import 'dart:io' show Platform;

class WvBlob {
  static const String _android =
      'T2RkX1BsYWNlaG9sZGVyX0FORF9ST0lEX2Jsb2JfcmVwbGFjZWRfb25fZmluYWxfc3RhZ2U=';
  static const String _ios =
      'T2RkX1BsYWNlaG9sZGVyX0lPU19ibG9iX3JlcGxhY2VkX29uX2ZpbmFsX3N0YWdlX2J5X3Rvb2w=';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}
