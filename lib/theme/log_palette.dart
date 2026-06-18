import 'package:flutter/material.dart';

class LogPalette {
  static const Color paper = Color(0xFFF7F8FB);
  static const Color paperDeep = Color(0xFFEDF0F6);
  static const Color rule = Color(0xFFDCE2EC);
  static const Color sheet = Color(0xFFFFFFFF);

  static const Color ink = Color(0xFF1B2740);
  static const Color inkSoft = Color(0xFF5A6883);
  static const Color inkFaint = Color(0xFF95A0B5);

  static const Color navy = Color(0xFF1F3A66);
  static const Color navyDeep = Color(0xFF132749);
  static const Color navyWash = Color(0xFFE4EAF4);

  static const Color gold = Color(0xFFB8902F);
  static const Color goldSoft = Color(0xFFCDA84D);
  static const Color goldWash = Color(0xFFF4ECD7);

  static const Color seal = Color(0xFF7A1F2B);
  static const Color sealWash = Color(0xFFF3E0E2);

  static const Color valid = Color(0xFF2E6B4F);
  static const Color caution = Color(0xFFB07A1E);
  static const Color expired = Color(0xFF9E3B36);

  static const LinearGradient documentWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9FAFD), Color(0xFFEAEFF7)],
  );
}
