import 'package:flutter/widgets.dart';
import '../domain/logbook_repository.dart';

class LogbookScope extends InheritedNotifier<LogbookRepository> {
  const LogbookScope({
    super.key,
    required LogbookRepository repo,
    required super.child,
  }) : super(notifier: repo);

  static LogbookRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LogbookScope>();
    assert(scope != null, 'LogbookScope not found in context');
    return scope!.notifier!;
  }

  static LogbookRepository read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<LogbookScope>()
        ?.widget as LogbookScope?;
    return scope!.notifier!;
  }
}
