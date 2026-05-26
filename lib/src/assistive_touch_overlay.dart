import 'package:flutter/material.dart';

/// Builder signature for the content rendered inside [AssistiveTouchOverlay].
///
/// [pulseAnimation] drives the scale pulse when [AssistiveTouchOverlay.isPulsing]
/// is true. Pass it to a [ScaleTransition] (or ignore it) as needed.
typedef AssistiveTouchOverlayBuilder = Widget Function(
  BuildContext context,
  Animation<double> pulseAnimation,
);

/// iOS-style floating bubble overlay.
///
/// Draggable around the screen and snaps to the nearest edge on drag end.
/// This widget renders an [AnimatedPositioned], so it must be placed under a
/// [Stack] or [Overlay].
class AssistiveTouchOverlay extends StatefulWidget {
  /// Creates an [AssistiveTouchOverlay].
  const AssistiveTouchOverlay({
    super.key,
    required this.builder,
    this.onTap,
    this.bubbleSize = 60.0,
    this.edgePadding = -20.0,
    this.initialPosition,
    this.isPulsing = false,
    this.snapDuration = const Duration(milliseconds: 300),
    this.snapCurve = Curves.easeOutCubic,
    this.pulseDuration = const Duration(milliseconds: 900),
    this.pulseBegin = 1.0,
    this.pulseEnd = 1.15,
  });

  /// Called to build the content of the bubble.
  final AssistiveTouchOverlayBuilder builder;

  /// Called when the bubble is tapped (without dragging).
  final VoidCallback? onTap;

  /// Diameter of the bubble in logical pixels.
  final double bubbleSize;

  /// Edge padding used for snap/clamp. Supports negative values (flush against
  /// edge like iOS).
  final double edgePadding;

  /// Defaults to `Offset(edgePadding, 200)`.
  final Offset? initialPosition;

  /// When true, the bubble built by [builder] should typically use the provided
  /// [pulseAnimation] (e.g. via [ScaleTransition]).
  final bool isPulsing;

  /// Duration of the snap-to-edge animation.
  final Duration snapDuration;

  /// Curve used for the snap-to-edge animation.
  final Curve snapCurve;

  /// Duration of one pulse cycle.
  final Duration pulseDuration;

  /// Scale value at which the pulse animation starts.
  final double pulseBegin;

  /// Scale value at which the pulse animation ends.
  final double pulseEnd;

  @override
  State<AssistiveTouchOverlay> createState() => _AssistiveTouchOverlayState();
}

class _AssistiveTouchOverlayState extends State<AssistiveTouchOverlay>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<Offset> _positionNotifier;

  bool _isDragging = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _positionNotifier = ValueNotifier<Offset>(
      widget.initialPosition ?? Offset(widget.edgePadding, 200.0),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );

    _pulseAnimation = Tween<double>(
      begin: widget.pulseBegin,
      end: widget.pulseEnd,
    ).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant AssistiveTouchOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
      } else {
        _pulseController
          ..stop()
          ..value = 0.0;
      }
    }
    if (widget.pulseDuration != oldWidget.pulseDuration) {
      _pulseController.duration = widget.pulseDuration;
      if (widget.isPulsing && _pulseController.isAnimating) {
        _pulseController
          ..reset()
          ..repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionNotifier.dispose();
    super.dispose();
  }

  void _snapToEdge() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final currentX = _positionNotifier.value.dx;
    final currentY = _positionNotifier.value.dy;

    final snapX = (currentX + widget.bubbleSize / 2) < screenWidth / 2
        ? widget.edgePadding
        : screenWidth - widget.bubbleSize - widget.edgePadding;

    final clampedY = currentY.clamp(
      widget.edgePadding,
      screenHeight - widget.bubbleSize - widget.edgePadding,
    );

    setState(() {
      _isDragging = false;
    });
    _positionNotifier.value = Offset(snapX, clampedY);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: _positionNotifier,
      builder: (context, position, child) {
        return AnimatedPositioned(
          duration: _isDragging ? Duration.zero : widget.snapDuration,
          curve: widget.snapCurve,
          left: position.dx,
          top: position.dy,
          child: child!,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          final current = _positionNotifier.value;
          _positionNotifier.value = Offset(
            current.dx + details.delta.dx,
            current.dy + details.delta.dy,
          );
        },
        onPanEnd: (_) => _snapToEdge(),
        child: widget.builder(context, _pulseAnimation),
      ),
    );
  }
}
