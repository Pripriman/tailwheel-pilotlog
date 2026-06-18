import 'package:flutter/material.dart';
import '../theme/log_palette.dart';

class DocumentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final Border? border;
  final bool crest;

  const DocumentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.onTap,
    this.border,
    this.crest = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: color ?? LogPalette.sheet,
        borderRadius: BorderRadius.circular(10),
        border: border ?? Border.all(color: LogPalette.rule, width: 1),
        boxShadow: [
          BoxShadow(
            color: LogPalette.navyDeep.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (crest)
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [LogPalette.gold, LogPalette.goldSoft],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
