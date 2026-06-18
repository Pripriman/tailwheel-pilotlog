import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'access/access_screen.dart';
import 'home/logbook_deck_shell.dart';
import 'intro/intro_flow.dart';

enum _Stage { boot, intro, access, home }

class NativeRoot extends StatefulWidget {
  const NativeRoot({super.key});

  @override
  State<NativeRoot> createState() => _NativeRootState();
}

class _NativeRootState extends State<NativeRoot> {
  static const _introKey = 'log.introDone';
  _Stage _stage = _Stage.boot;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final introDone = prefs.getBool(_introKey) ?? false;
    if (!mounted) return;
    setState(() => _stage = introDone ? _Stage.home : _Stage.intro);
  }

  Future<void> _finishIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introKey, true);
    if (!mounted) return;
    setState(() => _stage = _Stage.access);
  }

  void _finishAccess() => setState(() => _stage = _Stage.home);

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _Stage.boot:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case _Stage.intro:
        return IntroFlow(onDone: _finishIntro);
      case _Stage.access:
        return AccessScreen(onDone: _finishAccess);
      case _Stage.home:
        return const LogbookDeckShell();
    }
  }
}
