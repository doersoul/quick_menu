import 'package:flutter/material.dart';
import 'package:quick_menu/src/quick_menu_scale_transition.dart';

class QuickMenuPageRoute<T> extends PageRouteBuilder<T> {
  final bool enableDelegatedTransition;
  final Color delegatedBackgroundColor;

  QuickMenuPageRoute({
    required this.enableDelegatedTransition,
    required this.delegatedBackgroundColor,
    required super.pageBuilder,
  }) : super(
         opaque: false,
         transitionDuration: Durations.short4,
         reverseTransitionDuration: Durations.short4,
       );

  @override
  DelegatedTransitionBuilder? get delegatedTransition {
    if (!enableDelegatedTransition) {
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
    return Stack(
      children: [
        Container(color: delegatedBackgroundColor),
        // AnimatedBuilder(
        //   animation: secondaryAnimation,
        //   builder: (_, _) {
        //     return Transform.scale(
        //       scale: 1 + secondaryAnimation.value * -0.04,
        //       child: child,
        //     );
        //   },
        // ),
        QuickMenuScaleTransition(
          animation: secondaryAnimation,
          allowSnapshotting: allowSnapshotting,
          child: child,
        ),
      ],
    );
  }
}
