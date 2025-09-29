import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_menu/src/quick_menu_controller.dart';
import 'package:quick_menu/src/quick_menu_page.dart';
import 'package:quick_menu/src/quick_menu_page_route.dart';

typedef OverlayBuilder = Widget Function(BuildContext context, Widget child);

typedef MenuBuilder = Widget? Function(BuildContext context, Rect childRect);

class QuickMenu extends StatefulWidget {
  final QuickMenuController? controller;
  final bool useDelegatedTransition;
  final Color delegatedBackgroundColor;
  final Color barrierColor;
  final double? overlayRadius;
  final bool overlayShadowEnable;
  final double overlayScaleIncrement;
  final MenuBuilder menuBuilder;
  final OverlayBuilder? overlayBuilder;
  final GestureTapDownCallback? onTapDown;
  final VoidCallback? onTapCancel;
  final VoidCallback? onTap;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onCloseMenu;
  final VoidCallback? onMenuClosed;
  final VoidCallback? haptic;
  final Widget child;

  const QuickMenu({
    super.key,
    this.controller,
    this.useDelegatedTransition = true,
    this.delegatedBackgroundColor = Colors.white,
    this.barrierColor = Colors.black,
    this.overlayRadius = 12,
    this.overlayShadowEnable = false,
    this.overlayScaleIncrement = -0.1,
    this.overlayBuilder,
    required this.menuBuilder,
    this.onTapDown,
    this.onTapCancel,
    this.onTap,
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

  final ValueNotifier<bool> _open = ValueNotifier(false);

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Durations.short4);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _initControllerListener();
  }

  @override
  void didUpdateWidget(QuickMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _disposeControllerListener(oldWidget);

      _initControllerListener();
    }
  }

  @override
  void dispose() {
    _open.dispose();

    _controller.dispose();

    _disposeControllerListener(widget);

    super.dispose();
  }

  void _initControllerListener() {
    widget.controller?.addListener(_controllerListener);
  }

  void _disposeControllerListener(QuickMenu quickMenu) {
    quickMenu.controller?.removeListener(_controllerListener);
  }

  void _controllerListener() {
    final bool open = widget.controller!.isOpen;
    if (open && !_open.value) {
      _openMenu();
    }
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

  void _openMenu() {
    final Rect? rect = _getRect();
    if (rect == null) {
      return;
    }

    final Widget? menu = widget.menuBuilder(context, rect);
    if (menu == null) {
      return;
    }

    Widget overlay = widget.child;
    if (widget.overlayBuilder != null) {
      overlay = widget.overlayBuilder!.call(context, widget.child);
    }

    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);

    final QuickMenuPageRoute<bool> route = QuickMenuPageRoute<bool>(
      useDelegatedTransition: widget.useDelegatedTransition,
      overlayScaleIncrement: widget.overlayScaleIncrement,
      backgroundColor: widget.delegatedBackgroundColor,
      pageBuilder: (_, Animation<double> animation, _) {
        return QuickMenuPage(
          controller: widget.controller,
          animation: animation,
          barrierColor: widget.barrierColor,
          childRadius: widget.overlayRadius,
          childShadowEnable: widget.overlayShadowEnable,
          childRect: rect,
          childScaleIncrement: widget.overlayScaleIncrement,
          onCloseMenu: widget.onCloseMenu,
          menu: menu,
          child: overlay,
        );
      },
    );

    _onOpenMenu();

    navigator.push(route).then((bool? result) {
      Future.delayed(Durations.short4, () {
        if (result != null && result) {
          widget.onTap?.call();
        }

        _onMenuClosed();
      });
    });
  }

  void _onOpenMenu() {
    _open.value = true;

    widget.onOpenMenu?.call();
  }

  void _onMenuClosed([_]) {
    if (mounted) {
      _open.value = false;
    }

    widget.onMenuClosed?.call();
  }

  void _onTapDown(TapDownDetails details) {
    widget.onTapDown?.call(details);

    _controller.forward().whenComplete(() {
      widget.haptic?.call();

      _controller.reverse();
    });
  }

  void _onTapCancel() {
    _controller.reverse();

    widget.onTapCancel?.call();
  }

  void _onReverse([_]) {
    _controller.reverse();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _openMenu();
  }

  @override
  Widget build(BuildContext context) {
    final double increment = widget.overlayScaleIncrement.abs() / 2;

    return GestureDetector(
      key: _key,
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onReverse,
      onTapMove: _onReverse,
      onTapCancel: _onTapCancel,
      onLongPressStart: _onLongPressStart,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, Widget? cld) {
          return Transform.scale(
            scale: 1 - increment * _animation.value,
            child: cld,
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap,
          child: ValueListenableBuilder<bool>(
            valueListenable: _open,
            builder: (_, bool open, _) {
              return Visibility.maintain(visible: !open, child: widget.child);
            },
          ),
        ),
      ),
    );
  }
}
