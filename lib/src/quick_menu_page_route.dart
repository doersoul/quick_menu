import 'package:flutter/material.dart';

class QuickMenuPageRoute<T> extends PageRouteBuilder<T> {
  final bool useDelegatedTransition;
  final double overlayScaleIncrement;
  final Color backgroundColor;

  QuickMenuPageRoute({
    this.useDelegatedTransition = true,
    required this.overlayScaleIncrement,
    required this.backgroundColor,
    required super.pageBuilder,
  }) : super(
         opaque: false,
         transitionDuration: Durations.short4,
         reverseTransitionDuration: Durations.short4,
       );

  @override
  DelegatedTransitionBuilder? get delegatedTransition {
    if (!useDelegatedTransition) {
      return null;
    }

    return _delegatedTransition;
  }

  Widget? _delegatedTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    bool allowSnapshotting,
    Widget? child,
  ) {
    final double increment = -overlayScaleIncrement.abs() / 2;

    return Stack(
      children: [
        Container(color: backgroundColor),
        AnimatedBuilder(
          animation: secondaryAnimation,
          builder: (_, _) {
            return Transform.scale(
              scale: 1 + secondaryAnimation.value * increment,
              child: child,
            );
          },
        ),
      ],
    );
  }
}
