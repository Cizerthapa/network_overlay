import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../assistive_touch_overlay.dart';
import '../api_call_record.dart';
import '../api_inspector_controller.dart';
import 'api_calls_list_screen.dart';

/// Drop-in overlay that shows/hides based on [ApiInspectorController].
///
/// Usage (recommended):
/// ```dart
/// final controller = ApiInspectorController();
///
/// MaterialApp(
///   builder: (context, child) {
///     return Stack(
///       children: [
///         if (child != null) child,
///         ApiInspectorOverlay(controller: controller),
///       ],
///     );
///   },
/// )
/// ```
class ApiInspectorOverlay extends StatefulWidget {
  /// Creates an [ApiInspectorOverlay].
  const ApiInspectorOverlay({
    super.key,
    required this.controller,
    this.bubbleSize = 60.0,
    this.edgePadding = -20.0,
    this.showSecondsInLabel = true,
    this.showRequestCountInLabel = true,
    this.showDoneErrorCountInLabel = true,
    this.showRecordingBadge = true,
    this.showRecordingErrorCountInBadge = true,
    this.badgeDiameter = 16.0,
  });

  /// The controller that drives overlay visibility and state.
  final ApiInspectorController controller;

  /// Diameter of the floating bubble in logical pixels.
  final double bubbleSize;

  /// Edge padding passed to the underlying [AssistiveTouchOverlay].
  final double edgePadding;

  /// When true, the remaining-seconds countdown is shown inside the bubble
  /// while recording.
  final bool showSecondsInLabel;

  /// When true, the captured request count is shown inside the bubble while
  /// recording.
  final bool showRequestCountInLabel;

  /// When true, the error count is shown inside the bubble after recording
  /// finishes.
  final bool showDoneErrorCountInLabel;

  /// Shows a small badge while recording (top-right of the bubble).
  final bool showRecordingBadge;

  /// When recording, show error count inside the badge if > 0.
  final bool showRecordingErrorCountInBadge;

  /// Diameter of the recording badge in logical pixels.
  final double badgeDiameter;

  @override
  State<ApiInspectorOverlay> createState() => _ApiInspectorOverlayState();
}

class _ApiInspectorOverlayState extends State<ApiInspectorOverlay> {
  ApiInspectorState? _prevState;

  @override
  void initState() {
    super.initState();
    _prevState = widget.controller.stateListenable.value;
    widget.controller.stateListenable.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.controller.stateListenable.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    final prev = _prevState;
    final curr = widget.controller.stateListenable.value;
    _prevState = curr;
    if (prev is ApiInspectorRecording && curr is ApiInspectorDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => ApiCallsListScreen(
              controller: widget.controller,
              records: curr.records,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.overlayVisibleListenable,
      builder: (context, visible, _) {
        if (!visible) return const SizedBox.shrink();

        return ValueListenableBuilder<ApiInspectorState>(
          valueListenable: widget.controller.stateListenable,
          builder: (context, state, __) {
            final isRecording = state is ApiInspectorRecording;
            final isDone = state is ApiInspectorDone;

            final errorCount = switch (state) {
              final ApiInspectorRecording r => r.errorCount,
              final ApiInspectorDone d => d.errorCount,
              _ => 0,
            };

            final List<ApiCallRecord> doneRecords =
                state is ApiInspectorDone ? state.records : const [];
            final bool hasFatal = isDone &&
                doneRecords
                    .any((r) => r.statusCode == 0 || r.statusCode >= 500);

            final Color bg = isRecording
                ? Colors.red.shade600
                : isDone
                    ? (errorCount > 0
                        ? (hasFatal
                            ? Colors.red.shade600
                            : Colors.orange.shade700)
                        : Colors.green.shade600)
                    : const Color(0xFF2D2D3A);

            final String label = switch (state) {
              final ApiInspectorRecording r => _recordingLabel(r),
              final ApiInspectorDone d => _doneLabel(d),
              _ => '🔍',
            };

            return AssistiveTouchOverlay(
              bubbleSize: widget.bubbleSize,
              edgePadding: widget.edgePadding,
              initialPosition: widget.controller.initialPosition,
              isPulsing: isRecording,
              onTap: () => widget.controller.onBubbleTap(context),
              builder: (context, pulseAnimation) {
                final bubbleCore = _Bubble(
                  size: widget.bubbleSize,
                  bg: bg,
                  label: label,
                );

                Widget bubble = bubbleCore;
                if (widget.showRecordingBadge && isRecording) {
                  bubble = Stack(
                    clipBehavior: Clip.none,
                    children: [
                      bubbleCore,
                      Positioned(
                        right: -2,
                        top: -2,
                        child: _RecordingBadge(
                          diameter: widget.badgeDiameter,
                          errorCount: errorCount,
                          showErrorCount: widget.showRecordingErrorCountInBadge,
                          isFatal: hasFatal,
                        ),
                      ),
                    ],
                  );
                }

                if (isRecording) {
                  bubble =
                      ScaleTransition(scale: pulseAnimation, child: bubble);
                }
                return bubble;
              },
            );
          },
        );
      },
    );
  }

  String _recordingLabel(ApiInspectorRecording r) {
    final parts = <String>[];
    if (widget.showSecondsInLabel) {
      parts.add('${r.secondsLeft}s');
    }
    if (widget.showRequestCountInLabel) {
      parts.add('${r.count} req');
    }
    if (parts.isEmpty) {
      return 'REC';
    }
    return parts.join('\n');
  }

  String _doneLabel(ApiInspectorDone d) {
    if (widget.showDoneErrorCountInLabel && d.errorCount > 0) {
      return '⚠ ${d.errorCount}\n${d.records.length}';
    }
    return '✓ ${d.records.length}';
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.bg, required this.label});

  final double size;
  final Color bg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.88),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.45),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

class _RecordingBadge extends StatelessWidget {
  const _RecordingBadge({
    required this.diameter,
    required this.errorCount,
    required this.showErrorCount,
    required this.isFatal,
  });

  final double diameter;
  final int errorCount;
  final bool showErrorCount;
  final bool isFatal;

  @override
  Widget build(BuildContext context) {
    final shouldShowCount = showErrorCount && errorCount > 0;
    final bg = shouldShowCount
        ? (isFatal ? Colors.red.shade700 : Colors.orange.shade800)
        : Colors.red.shade700;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: shouldShowCount
          ? Text(
              errorCount > 99 ? '99+' : '$errorCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            )
          : const SizedBox.shrink(),
    );
  }
}
