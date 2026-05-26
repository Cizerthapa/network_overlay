import 'api_call_record.dart';

/// Holds recorded [ApiCallRecord]s during a capture session.
///
/// Record accumulation is guarded by [isRecording] so there is minimal overhead
/// when the inspector is not active.
class ApiInspectorService {
  bool _isRecording = false;
  int _sessionId = 0;
  final List<ApiCallRecord> _records = [];

  /// Whether a capture session is currently active.
  bool get isRecording => _isRecording;

  /// Active session id, or `null` when not recording.
  int? get activeSessionId => _isRecording ? _sessionId : null;

  /// Immutable view of captured records.
  List<ApiCallRecord> get records => List.unmodifiable(_records);

  /// Starts a new recording session and clears any previously captured records.
  void startRecording() {
    _sessionId++;
    _isRecording = true;
    _records.clear();
  }

  /// Stops the current recording session without clearing records.
  void stopRecording() {
    _isRecording = false;
  }

  /// Clears all captured records.
  void clear() {
    _records.clear();
  }

  /// No-ops instantly if [isRecording] is false.
  ///
  /// If [sessionId] is supplied, records from that session are still accepted
  /// even after [stopRecording] is called. This ensures in-flight requests
  /// started during capture are not dropped.
  void record(ApiCallRecord record, {int? sessionId}) {
    final shouldRecordByLiveState = _isRecording;
    final shouldRecordBySession = sessionId != null && sessionId == _sessionId;
    if (!shouldRecordByLiveState && !shouldRecordBySession) {
      return;
    }
    _records.add(record);
  }
}
