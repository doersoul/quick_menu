import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  ).chain(CurveTween(curve: Curves.linear));

  final SnapshotController _controller = SnapshotController();

  late _QuickMenuScalePainter _painter;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _updateAnimationAndPainter();

    widget.animation.addListener(_onAnimationValueChange);
    widget.animation.addStatusListener(_onAnimationStatusChange);
  }

  void _updateAnimationAndPainter() {
    _scaleAnimation = _scaleTween.animate(widget.animation);

    _painter = _QuickMenuScalePainter(scaleAnimation: _scaleAnimation);
  }

  @override
  void didUpdateWidget(covariant QuickMenuScaleTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(_onAnimationValueChange);
      oldWidget.animation.removeStatusListener(_onAnimationStatusChange);

      _painter.dispose();

      _updateAnimationAndPainter();

      widget.animation.addListener(_onAnimationValueChange);
      widget.animation.addStatusListener(_onAnimationStatusChange);
    }
  }

  void _onAnimationValueChange() {
    final bool shouldSnapshot =
        widget.animation.isAnimating &&
        widget.allowSnapshotting &&
        _scaleAnimation.value != 1.0;

    _controller.allowSnapshotting = shouldSnapshot;
  }

  void _onAnimationStatusChange(AnimationStatus status) {
    _controller.allowSnapshotting =
        status.isAnimating && widget.allowSnapshotting;
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onAnimationValueChange);
    widget.animation.removeStatusListener(_onAnimationStatusChange);

    _painter.dispose();

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SnapshotWidget(
      mode: SnapshotMode.permissive,
      autoresize: true,
      controller: _controller,
      painter: _painter,
      child: widget.child,
    );
  }
}

void _drawImageScaledAndCentered(
  PaintingContext context,
  ui.Image image,
  double scale,
  double pixelRatio,
  double opacity,
) {
  if (scale <= 0.0) {
    return;
  }

  final Paint paint = Paint()
    ..filterQuality = ui.FilterQuality.medium
    ..color = Color.fromRGBO(0, 0, 0, opacity);

  final double logicalWidth = image.width / pixelRatio;
  final double logicalHeight = image.height / pixelRatio;
  final double scaledLogicalWidth = logicalWidth * scale;
  final double scaledLogicalHeight = logicalHeight * scale;

  final double left = (logicalWidth - scaledLogicalWidth) / 2;
  final double top = (logicalHeight - scaledLogicalHeight) / 2;

  final Rect dst = Rect.fromLTWH(
    left,
    top,
    scaledLogicalWidth,
    scaledLogicalHeight,
  );

  context.canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    dst,
    paint,
  );
}

class _QuickMenuScalePainter extends SnapshotPainter {
  final Animation<double> scaleAnimation;

  _QuickMenuScalePainter({required this.scaleAnimation}) {
    scaleAnimation.addListener(notifyListeners);
    scaleAnimation.addStatusListener(_onStatusChange);
  }

  @override
  void dispose() {
    scaleAnimation.removeListener(notifyListeners);
    scaleAnimation.removeStatusListener(_onStatusChange);

    super.dispose();
  }

  @override
  bool shouldRepaint(covariant _QuickMenuScalePainter oldPainter) {
    return oldPainter.scaleAnimation.value != scaleAnimation.value;
  }

  @override
  void paintSnapshot(
    PaintingContext context,
    ui.Offset offset,
    ui.Size size,
    ui.Image image,
    ui.Size sourceSize,
    double pixelRatio,
  ) {
    _drawImageScaledAndCentered(
      context,
      image,
      scaleAnimation.value,
      pixelRatio,
      1.0,
    );
  }

  @override
  void paint(
    PaintingContext context,
    ui.Offset offset,
    ui.Size size,
    PaintingContextCallback painter,
  ) {
    final double scale = scaleAnimation.value;

    final Matrix4 transform = Matrix4.identity();
    if (scale != 1.0) {
      final double dx = ((size.width * scale) - size.width) / 2;
      final double dy = ((size.height * scale) - size.height) / 2;
      transform.translateByDouble(-dx, -dy, 0.0, 1.0);
      transform.scaleByDouble(scale, scale, scale, 1.0);
    }

    context.pushTransform(true, offset, transform, painter);
  }

  void _onStatusChange(AnimationStatus _) {
    notifyListeners();
  }
}
