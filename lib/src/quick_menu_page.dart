import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quick_menu/src/quick_menu_controller.dart';

class QuickMenuPage extends StatefulWidget {
  final QuickMenuController? controller;
  final Color barrierColor;
  final double? childRadius;
  final bool childShadowEnable;
  final Rect childRect;
  final double childScaleIncrement;
  final VoidCallback? onTap;
  final VoidCallback? onCloseMenu;
  final Widget menu;
  final Widget child;

  const QuickMenuPage({
    super.key,
    this.controller,
    required this.barrierColor,
    this.childRadius,
    required this.childShadowEnable,
    required this.childRect,
    required this.childScaleIncrement,
    this.onTap,
    this.onCloseMenu,
    required this.menu,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _QuickMenuPageState();
}

class _QuickMenuPageState extends State<QuickMenuPage>
    with TickerProviderStateMixin {
  final GlobalKey _menuKey = GlobalKey();

  late AnimationController _controller;
  late Animation<double> _animation;

  late double _screenWidth;
  late double _screenHeight;

  Size? _menuSize;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Durations.short4);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _initControllerListener();

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Size size = MediaQuery.sizeOf(context);
    final EdgeInsets padding = MediaQuery.paddingOf(context);

    _screenWidth = size.width;
    _screenHeight = size.height - padding.bottom;
  }

  @override
  void didUpdateWidget(QuickMenuPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _disposeControllerListener(oldWidget);

      _initControllerListener();
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    _disposeControllerListener(widget);

    super.dispose();
  }

  void _initControllerListener() {
    widget.controller?.addListener(_controllerListener);
  }

  void _disposeControllerListener(QuickMenuPage quickMenuPage) {
    quickMenuPage.controller?.removeListener(_controllerListener);
  }

  void _controllerListener() {
    final bool open = widget.controller!.isOpen;
    if (!open) {
      _close();
    }
  }

  Size? _getMenuSize() {
    if (_menuSize != null) {
      return _menuSize;
    }

    RenderBox? box = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return null;
    }

    _menuSize = box.size;

    return _menuSize;
  }

  void _close([VoidCallback? callback]) {
    widget.onCloseMenu?.call();

    final NavigatorState navigator = Navigator.of(context);

    _controller.reverse().then((_) {
      if (navigator.canPop()) {
        navigator.pop();
      }

      callback?.call();
    });
  }

  void _onPop() {
    _close();
  }

  void _onTap() {
    _close(widget.onTap);
  }

  void _onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) {
      return;
    }

    _close();
  }

  @override
  Widget build(BuildContext context) {
    final double increment =
        (widget.childScaleIncrement * widget.childRect.width) / 2;

    final double incrementHeight =
        (widget.childScaleIncrement * widget.childRect.height) / 2;

    final double space = (increment.abs() + incrementHeight).abs();

    final double childBottom = widget.childRect.top + widget.childRect.height;

    final Widget barrier = GestureDetector(
      onTap: _onPop,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, _) {
          final double sigma = 10 * _animation.value;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: Container(
              color: widget.barrierColor.withAlpha(
                (16 * _animation.value).toInt(),
              ),
            ),
          );
        },
      ),
    );

    final Widget menu = AnimatedBuilder(
      animation: _animation,
      builder: (_, _) {
        final double animateIncrement = -increment * _animation.value;
        final double animateSpace = space.abs() * _animation.value;
        final Size? menuSize = _getMenuSize();

        Alignment alignment = Alignment.topLeft;
        double? left;
        double? right;
        double top;

        if (menuSize == null) {
          left = animateIncrement;
          top = childBottom + animateIncrement;
        } else {
          final double menuWidth = menuSize.width;
          final double menuHeight = menuSize.height;

          final bool overWidth =
              -increment + widget.childRect.left + menuWidth > _screenWidth;

          final bool overHeight =
              space + childBottom + menuHeight > _screenHeight;

          if (overWidth) {
            right = _screenWidth - widget.childRect.right + animateIncrement;

            if (overHeight) {
              top = widget.childRect.top - menuSize.height - animateSpace;

              alignment = Alignment.bottomRight;
            } else {
              top = childBottom + animateSpace;

              alignment = Alignment.topRight;
            }
          } else {
            left = widget.childRect.left + animateIncrement;

            if (overHeight) {
              top = widget.childRect.top - menuSize.height - animateSpace;

              alignment = Alignment.bottomLeft;
            } else {
              top = childBottom + animateSpace;

              alignment = Alignment.topLeft;
            }
          }
        }

        return Positioned(
          left: left,
          right: right,
          top: top,
          child: Opacity(
            opacity: _animation.value,
            child: Transform.scale(
              alignment: alignment,
              scale: _animation.value,
              child: Container(key: _menuKey, child: widget.menu),
            ),
          ),
        );
      },
    );

    final Widget overlay = Positioned(
      top: widget.childRect.top,
      left: widget.childRect.left,
      width: widget.childRect.width,
      height: widget.childRect.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext ctx, Widget? cld) {
          BorderRadiusGeometry? borderRadius;
          List<BoxShadow>? boxShadow;
          if (widget.childRadius != null) {
            final double radius = widget.childRadius! * _animation.value;

            borderRadius = BorderRadius.circular(radius);

            if (widget.childShadowEnable) {
              final double shadowRadius = 8 * _animation.value;

              boxShadow = [
                BoxShadow(
                  spreadRadius: shadowRadius,
                  blurRadius: shadowRadius,
                  color: widget.barrierColor.withAlpha(
                    (16 * _animation.value).toInt(),
                  ),
                ),
              ];
            }

            cld = ClipRRect(borderRadius: borderRadius, child: cld);
          }

          return Transform.scale(
            scale: 1 + widget.childScaleIncrement * _animation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: boxShadow,
              ),
              child: cld,
            ),
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _onTap,
          child: widget.child,
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [barrier, menu, overlay]),
      ),
    );
  }
}
