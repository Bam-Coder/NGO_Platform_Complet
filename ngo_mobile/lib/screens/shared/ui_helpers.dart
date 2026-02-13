import 'package:flutter/material.dart';

EdgeInsets screenPadding(BuildContext context) {
  final compact = MediaQuery.sizeOf(context).width < 360;
  return EdgeInsets.all(compact ? 12 : 16);
}

class AnimatedPageEntrance extends StatelessWidget {
  final Widget child;

  const AnimatedPageEntrance({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: animatedChild,
          ),
        );
      },
    );
  }
}
