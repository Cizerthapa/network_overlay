import 'dart:async';

import 'package:flutter/material.dart';

import 'api_call_record.dart';
import 'api_inspector_service.dart';
import 'ui/api_calls_list_screen.dart';

/// Base type for API inspector UI state.
sealed class ApiInspectorState {
  const ApiInspectorState();
}

/// Inspector is idle (not recording and no completed results).
class ApiInspectorIdle extends ApiInspectorState {
  /// Creates an [ApiInspectorIdle] state.
  const ApiInspectorIdle();
}

/// Inspector is currently recording calls for a limited time window.
class ApiInspectorRecording extends ApiInspectorState {
  /// Creates an [ApiInspectorRecording] state.
  const ApiInspectorRecording({
    required this.secondsLeft,
    required this.count,
    required this.errorCount,
  });

  /// Seconds remaining in the current capture window.
  final int secondsLeft;

  /// Number of calls captured so far in this session.
  final int count;

  /// Number of error responses (status 0 or >= 400) captured so far.
  final int errorCount;
}

/// Inspector has finished recording and has captured [records].
class ApiInspectorDone extends ApiInspectorState {
  /// Creates an [ApiInspectorDone] state with the given [records].
  const ApiInspectorDone(this.records, {required this.errorCount});

  /// All calls captured during the completed session.
  final List<ApiCallRecord> records;

  /// Number of error responses (status 0 or >= 400) in [records].
  final int errorCount;
}

/// Coordinates the API inspector capture window and navigation to the UI.
///
/// This controller is UI-framework-friendly (ValueNotifiers) and intentionally
/// light on dependencies. Pair it with:
/// - [ApiInspectorService] as the in-memory store
/// - [ApiInspectorInterceptor] to collect Dio traffic
/// - [ApiInspectorOverlay] to render the floating bubble
class ApiInspectorController {
  /// Creates an [ApiInspectorController].
  ///
  /// [service] defaults to a new [ApiInspectorService] when omitted.
  ApiInspectorController({
    ApiInspectorService? service,
    this.recordingDurationSeconds = 20,
    this.tickInterval = const Duration(seconds: 1),
    bool overlayVisible = false,
    this.initialPosition = const Offset(-20, 200),
  })  : _service = service ?? ApiInspectorService(),
        overlayVisibleListenable = ValueNotifier<bool>(overlayVisible),
        stateListenable =
            ValueNotifier<ApiInspectorState>(const ApiInspectorIdle());

  final ApiInspectorService _service;

  /// How many seconds a capture session lasts before auto-stopping.
  final int recordingDurationSeconds;

  /// How often the recording state is updated with elapsed time / call counts.
  final Duration tickInterval;

  /// Initial position of the floating overlay bubble.
  final Offset initialPosition;

  /// Notifies listeners when overlay visibility changes.
  final ValueNotifier<bool> overlayVisibleListenable;

  /// Notifies listeners when the inspector state transitions.
  final ValueNotifier<ApiInspectorState> stateListenable;

  Timer? _timer;
  int _secondsLeft = 0;
  int _remainingMs = 0;

  /// Whether a capture session is currently active.
  bool get isRecording => _service.isRecording;

  /// Immutable snapshot of all captured records.
  List<ApiCallRecord> get records => _service.records;

  /// Disposes the controller and cancels internal timers.
  void dispose() {
    _timer?.cancel();
    overlayVisibleListenable.dispose();
    stateListenable.dispose();
  }

  /// Controls whether the overlay bubble is visible.
  void setOverlayVisible(bool value) {
    overlayVisibleListenable.value = value;
  }

  /// Toggles overlay bubble visibility.
  void toggleOverlayVisible() {
    overlayVisibleListenable.value = !overlayVisibleListenable.value;
  }

  /// Starts a capture when idle/done, and stops a capture when recording.
  void toggleCapture() {
    final state = stateListenable.value;
    if (state is ApiInspectorIdle || state is ApiInspectorDone) {
      _startRecording();
    } else if (state is ApiInspectorRecording) {
      _stopRecording();
    }
  }

  /// Stops capture (if any) and returns to idle.
  void reset() {
    _timer?.cancel();
    _service.stopRecording();
    stateListenable.value = const ApiInspectorIdle();
  }

  /// Recommended handler for bubble tap.
  ///
  /// - If capture is done, opens the calls list screen.
  /// - Otherwise, toggles capture. Auto-navigation on Recording→Done is
  ///   handled by [ApiInspectorOverlay]'s state listener (covers both
  ///   manual stop and timer-based auto-stop).
  void onBubbleTap(BuildContext context) {
    final state = stateListenable.value;
    if (state is ApiInspectorDone) {
      _openCallsScreen(context, state.records);
      return;
    }
    toggleCapture();
  }

  void _startRecording() {
    _service.startRecording();
    _remainingMs = recordingDurationSeconds * 1000;
    _secondsLeft = recordingDurationSeconds;
    _emitRecording();

    _timer?.cancel();
    _timer = Timer.periodic(tickInterval, (_) {
      final tickMs =
          tickInterval.inMilliseconds <= 0 ? 1 : tickInterval.inMilliseconds;
      _remainingMs -= tickMs;
      if (_remainingMs < 0) {
        _remainingMs = 0;
      }
      _secondsLeft = (_remainingMs / 1000).ceil();
      if (_secondsLeft <= 0) {
        _stopRecording();
      } else {
        _emitRecording();
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _service.stopRecording();
    stateListenable.value = ApiInspectorDone(
      _service.records,
      errorCount: _countErrors(_service.records),
    );
  }

  void _emitRecording() {
    final records = _service.records;
    stateListenable.value = ApiInspectorRecording(
      secondsLeft: _secondsLeft,
      count: records.length,
      errorCount: _countErrors(records),
    );
  }

  int _countErrors(List<ApiCallRecord> records) {
    return records
        .where((r) => r.statusCode == 0 || r.statusCode >= 400)
        .length;
  }

  void _openCallsScreen(BuildContext context, List<ApiCallRecord> records) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => ApiCallsListScreen(controller: this, records: records),
      ),
    );
  }
}
