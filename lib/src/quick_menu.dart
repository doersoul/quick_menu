import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_menu/src/quick_menu_page.dart';

typedef OverlayBuilder = Widget Function(Widget child);

class QuickMenu extends StatefulWidget {
  final Widget? menu;
  final Color barrierColor;
  final double? overlayRadius;
  final Color? overlayShadowColor;
  final double overlayScaleIncrement;
  final OverlayBuilder? overlayBuilder;
  final GestureTapDownCallback? onTapDown;
  final VoidCallback? onTapCancel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onCloseMenu;
  final VoidCallback? onMenuClosed;
  final VoidCallback? haptic;
  final Widget child;

  const QuickMenu({
    super.key,
    this.menu,
    this.barrierColor = Colors.black,
    this.overlayRadius = 16,
    this.overlayShadowColor = Colors.black,
    this.overlayScaleIncrement = -0.1,
    this.overlayBuilder,
    this.onTapDown,
    this.onTapCancel,
    this.onTap,
    this.onLongPress,
    this.onOpenMenu,
    this.onCloseMenu,
    this.onMenuClosed,
    this.haptic = HapticFeedback.mediumImpact,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _QuickMenuState();
}

class _QuickMenuState extends State<QuickMenu>
    with SingleTickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Durations.short3);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Rect? _getRect() {
    RenderBox? box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return null;
    }

    final Size size = box.size;
    final Offset position = box.localToGlobal(Offset.zero);

    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  void _showCustomMenu([_]) {
    final Rect? rect = _getRect();
    if (rect == null) {
      return;
    }

    widget.haptic?.call();

    widget.onOpenMenu?.call();

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (BuildContext ctx, _, _) {
          return QuickMenuPage(
            barrierColor: widget.barrierColor,
            childRadius: widget.overlayRadius,
            childShadowColor: widget.overlayShadowColor,
            childRect: rect,
            childScaleIncrement: widget.overlayScaleIncrement,
            onTap: widget.onTap,
            onCloseMenu: widget.onCloseMenu,
            menu: widget.menu!,
            child: widget.overlayBuilder?.call(widget.child) ?? widget.child,
          );
        },
      ),
    ).then((_) {
      widget.onMenuClosed?.call();
    });
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.reverse();

    widget.onTapCancel?.call();
  }

  void _onReverse([_]) {
    _controller.reverse();
  }

  void _onLongPress() {
    widget.onLongPress?.call();

    _controller.reverse().then(_showCustomMenu);
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: widget.onTapDown,
      onTap: widget.onTap,
      child: widget.child,
    );

    if (widget.menu == null) {
      return child;
    }

    return GestureDetector(
      key: _key,
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onReverse,
      onTapMove: _onReverse,
      onTapCancel: _onTapCancel,
      onLongPress: _onLongPress,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, _) {
          return Transform.scale(
            scale: 1 - widget.overlayScaleIncrement.abs() * _animation.value,
            child: child,
          );
        },
      ),
    );
  }
}
