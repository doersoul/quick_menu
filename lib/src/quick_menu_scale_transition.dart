import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class QuickMenuScaleTransition extends StatefulWidget {
  final Animation<double> animation;
  final bool allowSnapshotting;
  final Widget? child;

  const QuickMenuScaleTransition({
    super.key,
    required this.animation,
    required this.allowSnapshotting,
    this.child,
  });

  @override
  State<StatefulWidget> createState() => _QuickMenuScaleTransitionState();
}

class _QuickMenuScaleTransitionState extends State<QuickMenuScaleTransition> {
  static final Animatable<double> _scaleTween = Tween<double>(
    begin: 1.0,
    end: 0.96,
  ).chain(CurveTween(curve: const Cubic(0.2, 0.0, 0.0, 1.0)));

  final SnapshotController _controller = SnapshotController();

  late Animation<double> _scaleAnimation;
  late _QuickMenuScalePainter _painter;

  @override
  void initState() {
    super.initState();

    _initAnimations();

    _controller.allowSnapshotting = widget.allowSnapshotting;
  }

  void _initAnimations() {
    _scaleAnimation = _scaleTween.animate(
      CurvedAnimation(parent: widget.animation, curve: Curves.linear),
    );

    _painter = _QuickMenuScalePainter(scaleAnimation: _scaleAnimation);
  }

  @override
  void didUpdateWidget(covariant QuickMenuScaleTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animation != widget.animation) {
      _painter.dispose();

      _initAnimations();
    }

    if (oldWidget.allowSnapshotting != widget.allowSnapshotting) {
      _controller.allowSnapshotting = widget.allowSnapshotting;
    }
  }

  @override
  void dispose() {
    _painter.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SnapshotWidget(
      controller: _controller,
      painter: _painter,
      mode: SnapshotMode.permissive,
      child: widget.child,
    );
  }
}

class _QuickMenuScalePainter extends SnapshotPainter {
  final Animation<double> scaleAnimation;

  _QuickMenuScalePainter({required this.scaleAnimation}) {
    scaleAnimation.addListener(notifyListeners);
  }

  @override
  void dispose() {
    scaleAnimation.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  void paintSnapshot(
    PaintingContext context,
    Offset offset,
    Size size,
    ui.Image image,
    Size sourceSize,
    double pixelRatio,
  ) {
    final double scale = scaleAnimation.value;
    if (scale <= 0.0) return;

    final Paint paint = Paint()..filterQuality = ui.FilterQuality.low;

    final double sw = image.width / pixelRatio;
    final double sh = image.height / pixelRatio;

    final Rect destRect = Rect.fromCenter(
      center: offset + Offset(sw / 2, sh / 2),
      width: sw * scale,
      height: sh * scale,
    );

    context.canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destRect,
      paint,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset,
    Size size,
    PaintingContextCallback painter,
  ) {
    final double scale = scaleAnimation.value;
    if (scale == 1.0) {
      painter(context, offset);
      return;
    }

    final Matrix4 transform = Matrix4.identity();
    final double dx = ((size.width * scale) - size.width) / 2;
    final double dy = ((size.height * scale) - size.height) / 2;

    transform.translateByDouble(-dx, -dy, 0.0, 1.0);
    transform.scaleByDouble(scale, scale, scale, 1.0);

    context.pushTransform(true, offset, transform, painter);
  }

  @override
  bool shouldRepaint(_QuickMenuScalePainter oldPainter) => true;
}
